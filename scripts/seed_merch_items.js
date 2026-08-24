const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, FieldValue } = require('firebase-admin/firestore');
const path = require('path');
const fs = require('fs');

const rootKeyPath = path.join(__dirname, '..', 'techniche-269b1-firebase-adminsdk-fbsvc-0986ba1ba6.json');
const localKeyPath = path.join(__dirname, 'serviceAccountKey.json');

let serviceAccount;
if (fs.existsSync(rootKeyPath)) {
  serviceAccount = require(rootKeyPath);
} else if (fs.existsSync(localKeyPath)) {
  serviceAccount = require(localKeyPath);
} else {
  console.error('❌ Service account key JSON file not found.');
  process.exit(1);
}

try {
  initializeApp({ credential: cert(serviceAccount) });
  console.log('✅ Firebase Admin SDK initialized.');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:', error.message);
  process.exit(1);
}

const db = getFirestore();

// ─── UPDATE THESE imageUrl FIELDS WITH YOUR GOOGLE DRIVE LINKS ───────────────
// Format: https://drive.google.com/file/d/FILE_ID/view?usp=sharing
// The app will auto-convert them to direct image URLs.
const merchItems = [
  {
    id: 'glitched_gameboy',
    title: 'Glitched GameBoy',
    imageUrl: 'https://drive.google.com/file/d/1YYuZnQO8qE_1URvyFYDDhDUfwHDZRjwl/view?usp=sharing',
    price: '₹449',
    badge: 'Limited Edition',
  },
  {
    id: 'glorified_goodboy',
    title: 'Glorified GoodBoy',
    imageUrl: '',  // ← Paste your Google Drive link here
    price: '₹399',
    badge: 'Official Drop',
  },
];
// ─────────────────────────────────────────────────────────────────────────────

async function seedMerchItems() {
  console.log('\n🚀 Seeding merch_items collection...');
  const batch = db.batch();

  for (const item of merchItems) {
    const { id, ...data } = item;
    const ref = db.collection('merch_items').doc(id);
    batch.set(ref, {
      ...data,
      updatedAt: FieldValue.serverTimestamp(),
    }, { merge: true });
    console.log(`  ➕ ${id}: imageUrl="${data.imageUrl || '(empty — update later)'}"`);
  }

  // Seed app_config/merch — controls sold-out status and order form URL
  const configRef = db.collection('app_config').doc('merch');
  batch.set(configRef, {
    isSoldOut: false,                                        // ← flip to true to show SOLD OUT
    orderFormUrl: 'https://forms.gle/87Zf6bjNXU8hwwAdA',   // ← update to change the form link
    updatedAt: FieldValue.serverTimestamp(),
  }, { merge: true });
  console.log('\n  ➕ app_config/merch: isSoldOut=false, orderFormUrl set');

  await batch.commit();
  console.log('\n🎉 Done! To update:\n  • app_config/merch → isSoldOut / orderFormUrl\n  • merch_items/{id} → imageUrl (Google Drive link)\n');
  process.exit(0);
}

seedMerchItems().catch(e => {
  console.error('❌ Failed:', e);
  process.exit(1);
});

const { initializeApp, cert } = require('firebase-admin/app');
const { getFirestore, Timestamp, FieldValue } = require('firebase-admin/firestore');
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
  initializeApp({
    credential: cert(serviceAccount)
  });
  console.log('✅ Firebase Admin SDK initialized successfully.');
} catch (error) {
  console.error('❌ Error initializing Firebase Admin SDK:', error.message);
  process.exit(1);
}

const db = getFirestore();
const COLLECTION_NAME = 'home_featured_events';

// 2. Initial 5 Featured Events Data
const initialEvents = [
  {
    id: 'robowars_2026',
    title: 'Robowars',
    category: 'Robotics',
    date: '28th August 2026',
    venue: 'Gymkhana Grounds, IIT Guwahati',
    imageUrl: '',
    fallbackAsset: 'assets/robo.png',
    order: 1,
    isActive: true,
    tag: 'LIVE NOW',
    targetEventId: 'robowars',
    startTimestamp: Timestamp.fromDate(new Date('2026-08-28T09:00:00+05:30')),
    endTimestamp: Timestamp.fromDate(new Date('2026-08-28T18:00:00+05:30'))
  },
  {
    id: 'aquawars_2026',
    title: 'Aquawars',
    category: 'Robotics',
    date: '29th - 30th August 2026',
    venue: 'Swimming Pool Area, IIT Guwahati',
    imageUrl: '',
    fallbackAsset: 'assets/robotics.jpeg',
    order: 2,
    isActive: true,
    tag: 'UPCOMING',
    targetEventId: 'aquawars',
    startTimestamp: Timestamp.fromDate(new Date('2026-08-29T10:00:00+05:30')),
    endTimestamp: Timestamp.fromDate(new Date('2026-08-30T17:00:00+05:30'))
  },
  {
    id: 'escalade_2026',
    title: 'Escalade',
    category: 'Competitions',
    date: '28th - 29th August 2026',
    venue: 'Auditorium Complex, IIT Guwahati',
    imageUrl: '',
    fallbackAsset: 'assets/escalade.png',
    order: 3,
    isActive: true,
    tag: 'FEATURED',
    targetEventId: 'escalade',
    startTimestamp: Timestamp.fromDate(new Date('2026-08-28T11:00:00+05:30')),
    endTimestamp: Timestamp.fromDate(new Date('2026-08-29T16:00:00+05:30'))
  },
  {
    id: 'track_titans_2026',
    title: 'Track Titans',
    category: 'Robotics',
    date: '29th August 2026',
    venue: 'Sac Building, IIT Guwahati',
    imageUrl: '',
    fallbackAsset: 'assets/robotics.jpeg',
    order: 4,
    isActive: true,
    tag: 'POPULAR',
    targetEventId: 'track_titans',
    startTimestamp: Timestamp.fromDate(new Date('2026-08-29T09:30:00+05:30')),
    endTimestamp: Timestamp.fromDate(new Date('2026-08-29T15:30:00+05:30'))
  },
  {
    id: 'linequest_2026',
    title: 'LineQuest',
    category: 'Robotics',
    date: '29th August 2026',
    venue: 'Core 1 Hall, IIT Guwahati',
    imageUrl: '',
    fallbackAsset: 'assets/micro.png',
    order: 5,
    isActive: true,
    tag: 'UPCOMING',
    targetEventId: 'linequest',
    startTimestamp: Timestamp.fromDate(new Date('2026-08-29T14:00:00+05:30')),
    endTimestamp: Timestamp.fromDate(new Date('2026-08-29T18:00:00+05:30'))
  }
];

// 3. Seed function using Firestore Batch write
async function seedHomeEvents() {
  console.log(`🚀 Starting seeding process into Firestore collection: '${COLLECTION_NAME}'...`);
  const batch = db.batch();

  initialEvents.forEach((eventData) => {
    const { id, ...dataToSave } = eventData;
    const docRef = db.collection(COLLECTION_NAME).doc(id);
    batch.set(docRef, {
      ...dataToSave,
      createdAt: FieldValue.serverTimestamp(),
      updatedAt: FieldValue.serverTimestamp()
    }, { merge: true });
    console.log(` ➕ Staged record: ${id} (${eventData.title})`);
  });

  try {
    await batch.commit();
    console.log(`\n🎉 Successfully seeded ${initialEvents.length} events into '${COLLECTION_NAME}' collection!`);
    process.exit(0);
  } catch (error) {
    console.error('❌ Batch write commit failed:', error);
    process.exit(1);
  }
}

seedHomeEvents();


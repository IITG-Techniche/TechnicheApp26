class TeamMember {
  final String name;
  final String role;
  final String imageUrl;

  const TeamMember({
    required this.name,
    required this.role,
    required this.imageUrl,
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'imageUrl': imageUrl,
      };
}

class HeadMember {
  final String name;
  final String designation;
  final String imageUrl;
  final String linkedinUrl;

  const HeadMember({
    required this.name,
    required this.designation,
    required this.imageUrl,
    required this.linkedinUrl,
  });

  factory HeadMember.fromJson(Map<String, dynamic> json) => HeadMember(
        name: json['name'] ?? '',
        designation: json['designation'] ?? '',
        imageUrl: json['imageUrl'] ?? '',
        linkedinUrl: json['linkedinUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'designation': designation,
        'imageUrl': imageUrl,
        'linkedinUrl': linkedinUrl,
      };
}

const List<TeamMember> kDevTeamMembers = [
  TeamMember(
    name: 'Dhruv',
    role: 'DevOps Head',
    imageUrl: 'assets/dhruv-app.jpg',
  ),
  TeamMember(
    name: 'Arya',
    role: 'DevOps Head',
    imageUrl: 'assets/arya-app.jpg',
  ),
  TeamMember(
    name: 'Ayush',
    role: 'Core Developer',
    imageUrl: 'assets/ayush-app.jpg',
  ),
  TeamMember(
    name: 'Divyansh',
    role: 'Developer (Organizer)',
    imageUrl: 'assets/divyansh-app.jpg',
  ),
];

const List<HeadMember> kFestHeads = [
  HeadMember(
    name: 'Rachit Shah',
    designation: 'Convenor',
    imageUrl: 'assets/rachit-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/rachit-shah-b5a597255/',
  ),
  HeadMember(
    name: 'Divyanshu Tiwari',
    designation: 'Finance Head',
    imageUrl: 'assets/tiwari-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/divyanshu-tiwari-925556256/',
  ),
  HeadMember(
    name: 'Aditya Damani',
    designation: 'Marketing Head',
    imageUrl: 'assets/damani-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/aditya-damani-418302262/',
  ),
  HeadMember(
    name: 'Yashvardhan Jaiswal',
    designation: 'Marketing Head',
    imageUrl: 'assets/vardhan-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/yashvardhanjaiswal/',
  ),
  HeadMember(
    name: 'Aarav Chanani',
    designation: 'Events Head',
    imageUrl: 'assets/aarav-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/aarav-chanani218/',
  ),
  HeadMember(
    name: 'Puja Kumari',
    designation: 'Events Head',
    imageUrl: 'assets/puja-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/puja-kumari-544667260/',
  ),
  HeadMember(
    name: 'Veenas Jaiswal',
    designation: 'Events Head',
    imageUrl: 'assets/veenas-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/veenas-jaiswal-93ab70259/',
  ),
  HeadMember(
    name: 'Rushikesh Pinge',
    designation: 'Public Relations Head',
    imageUrl: 'assets/rushi-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/rushikesh-pinge-aa1b33268/',
  ),
  HeadMember(
    name: 'Aileen Jess',
    designation: 'Media & Branding Head',
    imageUrl: 'assets/aileen-app.png',
    linkedinUrl: 'https://www.linkedin.com/in/aileen-jess-1a018b369/',
  ),
  HeadMember(
    name: 'Sanskriti Verma',
    designation: 'Media & Branding Head',
    imageUrl: 'assets/sanskriti-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/sanskriti-verma-15781525b/',
  ),
  HeadMember(
    name: 'Arya Pandey',
    designation: 'Development Operations Head',
    imageUrl: 'assets/arya-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/arya-pandey-265204257/',
  ),
  HeadMember(
    name: 'Dhruv Gupta',
    designation: 'Development Operations Head',
    imageUrl: 'assets/dhruv-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/dhruvgupta21iitg/',
  ),
  HeadMember(
    name: 'Amol Satheesh',
    designation: 'Creatives Head',
    imageUrl: 'assets/amol-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/amol-reach/',
  ),
];

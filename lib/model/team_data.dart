class TeamMember {
  final String name;
  final String role;
  final String teamName;
  final String imageUrl;
  final String linkedinUrl;

  const TeamMember({
    required this.name,
    required this.role,
    this.teamName = 'APP DEV TEAM',
    required this.imageUrl,
    this.linkedinUrl = '',
  });

  factory TeamMember.fromJson(Map<String, dynamic> json) => TeamMember(
        name: json['name'] ?? '',
        role: json['role'] ?? '',
        teamName: json['teamName'] ?? 'APP DEV TEAM',
        imageUrl: json['imageUrl'] ?? '',
        linkedinUrl: json['linkedinUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'role': role,
        'teamName': teamName,
        'imageUrl': imageUrl,
        'linkedinUrl': linkedinUrl,
      };
}

class HeadMember {
  final String name;
  final String designation;
  final String teamName;
  final String imageUrl;
  final String linkedinUrl;

  const HeadMember({
    required this.name,
    required this.designation,
    this.teamName = 'HEAD',
    required this.imageUrl,
    required this.linkedinUrl,
  });

  factory HeadMember.fromJson(Map<String, dynamic> json) => HeadMember(
        name: json['name'] ?? '',
        designation: json['designation'] ?? '',
        teamName: json['teamName'] ?? 'HEAD',
        imageUrl: json['imageUrl'] ?? '',
        linkedinUrl: json['linkedinUrl'] ?? '',
      );

  Map<String, dynamic> toJson() => {
        'name': name,
        'designation': designation,
        'teamName': teamName,
        'imageUrl': imageUrl,
        'linkedinUrl': linkedinUrl,
      };
}

const List<TeamMember> kDevTeamMembers = [
  TeamMember(
    name: 'Ayush',
    role: 'DevOps Head',
    teamName: 'DEVOPS HEAD',
    imageUrl: 'assets/ayush-app.jpg',
    linkedinUrl: '',
  ),
  TeamMember(
    name: 'Divyansh',
    role: 'Senior Developer',
    teamName: 'SENIOR DEVELOPER',
    imageUrl: 'assets/divyansh-app.jpg',
    linkedinUrl: '',
  ),
  TeamMember(
    name: 'Sanjay',
    role: 'Senior Developer',
    teamName: 'SENIOR DEVELOPER',
    imageUrl: 'assets/hero/meetheads/sanjay.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/sanjay-saini18/',
  ),
  TeamMember(
    name: 'Hasini',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: 'assets/hero/meetheads/hasini.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/hasini-r-161954376?utm_source=share_via&utm_content=profile&utm_medium=member_ios',
  ),
  TeamMember(
    name: 'Vitika',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: '',
    linkedinUrl: '',
  ),
  TeamMember(
    name: 'Sahaj',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: '',
    linkedinUrl: '',
  ),
];

const List<HeadMember> kFestHeads = [
  HeadMember(
    name: 'Rachit Shah',
    designation: 'Convenor',
    teamName: 'CONVENOR',
    imageUrl: 'assets/rachit-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/rachit-shah-b5a597255/',
  ),
  HeadMember(
    name: 'Divyanshu Tiwari',
    designation: 'Finance Head',
    teamName: 'FINANCE TEAM',
    imageUrl: 'assets/tiwari-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/divyanshu-tiwari-925556256/',
  ),
  HeadMember(
    name: 'Aditya Damani',
    designation: 'Marketing Head',
    teamName: 'MARKETING TEAM',
    imageUrl: 'assets/damani-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/aditya-damani-418302262/',
  ),
  HeadMember(
    name: 'Yashvardhan Jaiswal',
    designation: 'Marketing Head',
    teamName: 'MARKETING TEAM',
    imageUrl: 'assets/vardhan-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/yashvardhanjaiswal/',
  ),
  HeadMember(
    name: 'Aarav Chanani',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/aarav-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/aarav-chanani218/',
  ),
  HeadMember(
    name: 'Puja Kumari',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/puja-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/puja-kumari-544667260/',
  ),
  HeadMember(
    name: 'Veenas Jaiswal',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/veenas-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/veenas-jaiswal-93ab70259/',
  ),
  HeadMember(
    name: 'Rushikesh Pinge',
    designation: 'Public Relations Head',
    teamName: 'PR TEAM',
    imageUrl: 'assets/rushi-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/rushikesh-pinge-aa1b33268/',
  ),
  HeadMember(
    name: 'Aileen Jess',
    designation: 'Media & Branding Head',
    teamName: 'MEDIA TEAM',
    imageUrl: 'assets/aileen-app.png',
    linkedinUrl: 'https://www.linkedin.com/in/aileen-jess-1a018b369/',
  ),
  HeadMember(
    name: 'Sanskriti Verma',
    designation: 'Media & Branding Head',
    teamName: 'MEDIA TEAM',
    imageUrl: 'assets/sanskriti-app.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/sanskriti-verma-15781525b/',
  ),
  HeadMember(
    name: 'Arya Pandey',
    designation: 'Development Operations Head',
    teamName: 'DEVOPS TEAM',
    imageUrl: 'assets/arya-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/arya-pandey-265204257/',
  ),
  HeadMember(
    name: 'Dhruv Gupta',
    designation: 'Development Operations Head',
    teamName: 'DEVOPS TEAM',
    imageUrl: 'assets/dhruv-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/dhruvgupta21iitg/',
  ),
  HeadMember(
    name: 'Amol Satheesh',
    designation: 'Creatives Head',
    teamName: 'CREATIVES TEAM',
    imageUrl: 'assets/amol-app.jpg',
    linkedinUrl: 'https://www.linkedin.com/in/amol-reach/',
  ),
];

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
    name: 'Uday',
    designation: 'Convenor',
    teamName: 'CONVENOR',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Raghav',
    designation: 'Finance Head',
    teamName: 'FINANCE TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Hardik',
    designation: 'Marketing Head',
    teamName: 'MARKETING TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Loshanya',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Ritik',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Savi',
    designation: 'Media & Branding Head',
    teamName: 'MEDIA TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Shraddhan',
    designation: 'PR & Branding Head',
    teamName: 'PR & BRANDING TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Vaibhav',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Asmi',
    designation: 'Resi Head',
    teamName: 'RESI TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Nancy',
    designation: 'Creatives Head',
    teamName: 'CREATIVES TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Shreya',
    designation: 'Creatives Head',
    teamName: 'CREATIVES TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
  HeadMember(
    name: 'Ayush',
    designation: 'Development Operations Head',
    teamName: 'DEVOPS TEAM',
    imageUrl: '',
    linkedinUrl: '',
  ),
];

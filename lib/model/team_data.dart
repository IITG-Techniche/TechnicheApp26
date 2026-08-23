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
    name: 'Sanjay Saini',
    role: 'Senior Developer',
    teamName: 'SENIOR DEVELOPER',
    imageUrl: 'assets/hero/meetheads/sanjay.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/sanjay-saini18/',
  ),
  TeamMember(
    name: 'Divyansh',
    role: 'Senior Developer',
    teamName: 'SENIOR DEVELOPER',
    imageUrl: 'assets/divyansh-app.jpg',
    linkedinUrl: '',
  ),
  TeamMember(
    name: 'Hasini R',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: 'assets/hero/meetheads/hasini.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/hasini-r-161954376',
  ),
  TeamMember(
    name: 'Sahaj Aneja',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: 'assets/hero/meetheads/sahaj.png',
    linkedinUrl: 'https://www.linkedin.com/in/sahaj-aneja-5904a636a/',
  ),
  TeamMember(
    name: 'Vitika',
    role: 'Junior Developer',
    teamName: 'JUNIOR DEVELOPER',
    imageUrl: '',
    linkedinUrl: '',
  ),
];

const List<HeadMember> kFestHeads = [
  HeadMember(
    name: 'Uday Ingle',
    designation: 'Convenor',
    teamName: 'CONVENOR',
    imageUrl: 'assets/hero/meetheads/._convenor.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/uday-ingle-7a43a4280',
  ),
  HeadMember(
    name: 'Raghav Kapoor',
    designation: 'Finance Head',
    teamName: 'FINANCE TEAM',
    imageUrl: 'assets/hero/meetheads/._Fh_raghav_techniche.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/raghav-kapoor-6647971b6',
  ),
  HeadMember(
    name: 'Hardik Jain',
    designation: 'Marketing Head',
    teamName: 'MARKETING TEAM',
    imageUrl: 'assets/hero/meetheads/._marketing_hardik.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/hardik-jain-1a5296214',
  ),
  HeadMember(
    name: 'Loshanya Sasapu',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/hero/meetheads/._EVENT_HEAD_LOSHANYANAIDU.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/loshanya-sasapu-11303929b',
  ),
  HeadMember(
    name: 'Ritik Singh',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/hero/meetheads/._event_head_ritik.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/ritik-singh-974342362',
  ),
  HeadMember(
    name: 'Vaibhav Bivesh',
    designation: 'Events Head',
    teamName: 'EVENTS TEAM',
    imageUrl: 'assets/hero/meetheads/._event_head_vaibhav.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/vaibhav-bivesh-robo',
  ),
  HeadMember(
    name: 'Savi Kanse',
    designation: 'Media & Branding Head',
    teamName: 'MEDIA TEAM',
    imageUrl: 'assets/aileen-app.png',
    linkedinUrl: 'https://www.linkedin.com/in/savi-kanse-7a2114300',
  ),
  HeadMember(
    name: 'Shraddhan Singhai',
    designation: 'Public Relations Head',
    teamName: 'PR & BRANDING TEAM',
    imageUrl: 'assets/hero/meetheads/._PRB HEAD_SHRADDHAN.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/shraddhan-singhai-b11786282',
  ),
  HeadMember(
    name: 'Asmi Basak',
    designation: 'Design Head',
    teamName: 'DESIGN TEAM',
    imageUrl: 'assets/hero/meetheads/._resi_head_asmi.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/asmi-basak',
  ),
  HeadMember(
    name: 'Nancy Kumari',
    designation: 'Creatives Head',
    teamName: 'CREATIVES TEAM',
    imageUrl: 'assets/hero/meetheads/._creative_head_nancy.jpeg',
    linkedinUrl: 'https://www.linkedin.com/in/nancy-kumari-181743238',
  ),
  HeadMember(
    name: 'Shreya B',
    designation: 'Creatives Head',
    teamName: 'CREATIVES TEAM',
    imageUrl: 'assets/hero/meetheads/._creative_head_shreya.png',
    linkedinUrl: 'https://www.linkedin.com/in/shreya-b-007674313/',
  ),
];

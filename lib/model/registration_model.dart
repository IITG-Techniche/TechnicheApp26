class TecnoTeamRegistration {
  String name1;
  String dob1;
  String email1;
  String confirmEmail1;
  String contact1;
  String school1;
  String class1;

  String name2;
  String dob2;
  String email2;
  String confirmEmail2;
  String contact2;
  String school2;
  String class2;

  String squad;
  String language;
  String mode;
  String country;
  String state;
  String zone;
  String city;
  String view;

  TecnoTeamRegistration({
    this.name1 = "",
    this.dob1 = "",
    this.email1 = "",
    this.confirmEmail1 = "",
    this.contact1 = "",
    this.school1 = "",
    this.class1 = "",
    this.name2 = "",
    this.dob2 = "",
    this.email2 = "",
    this.confirmEmail2 = "",
    this.contact2 = "",
    this.school2 = "",
    this.class2 = "",
    this.squad = "",
    this.language = "",
    this.mode = "online",
    this.country = "",
    this.state = "",
    this.zone = "",
    this.city = "",
    this.view = "",
  });

  Map<String, dynamic> toJson() {
    return {
      'name1': name1,
      'dob1': dob1,
      'email1': email1,
      'confirmEmail1': confirmEmail1,
      'contact1': contact1,
      'school1': school1,
      'class1': class1,
      'name2': name2,
      'dob2': dob2,
      'email2': email2,
      'confirmEmail2': confirmEmail2,
      'contact2': contact2,
      'school2': school2,
      'class2': class2, // Assuming backend expects class2 for student 2
      'squad': squad,
      'language': language,
      'mode': mode,
      'country': country,
      'state': state,
      'zone': zone,
      'city': city,
      'view': view,
    };
  }
}

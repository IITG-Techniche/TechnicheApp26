class TechnoPaperModel {
  final String year;
  final String language;
  final String name;
  final String? url;
  final String squad;
  final String category;

  TechnoPaperModel({
    required this.year,
    required this.language,
    required this.name,
    required this.url,
    required this.squad,
    required this.category,
  });

  factory TechnoPaperModel.fromJson(Map<String, dynamic> json) {
    return TechnoPaperModel(
      year: json['year'],
      language: json['language'],
      name: json['name'],
      url: json['url'],
      squad: json['squad'],
      category: json['category'],
    );
  }
}

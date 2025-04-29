class Poet {
  final String id;
  final String name;
  final String birthDate;
  final String deathDate;
  final String biography;
  final String imageUrl;
  final List<String> periods;
  final List<String> styles;
  final List<String> notableWorks;
  final String birthPlace;
  final String deathPlace;
  final List<String> influences;
  final List<String> influencedBy;

  Poet({
    required this.id,
    required this.name,
    required this.birthDate,
    required this.deathDate,
    required this.biography,
    required this.imageUrl,
    required this.periods,
    required this.styles,
    required this.notableWorks,
    required this.birthPlace,
    required this.deathPlace,
    required this.influences,
    required this.influencedBy,
  });

  // Get poem count from notableWorks
  int get poemCount => notableWorks.length;

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'birthDate': birthDate,
      'deathDate': deathDate,
      'biography': biography,
      'imageUrl': imageUrl,
      'periods': periods,
      'styles': styles,
      'notableWorks': notableWorks,
      'birthPlace': birthPlace,
      'deathPlace': deathPlace,
      'influences': influences,
      'influencedBy': influencedBy,
    };
  }

  factory Poet.fromJson(Map<String, dynamic> json) {
    return Poet(
      id: json['id'] as String,
      name: json['name'] as String,
      birthDate: json['birthDate'] as String,
      deathDate: json['deathDate'] as String,
      biography: json['biography'] as String,
      imageUrl: json['imageUrl'] as String,
      periods: List<String>.from(json['periods'] as List),
      styles: List<String>.from(json['styles'] as List),
      notableWorks: List<String>.from(json['notableWorks'] as List),
      birthPlace: json['birthPlace'] as String,
      deathPlace: json['deathPlace'] as String,
      influences: List<String>.from(json['influences'] as List),
      influencedBy: List<String>.from(json['influencedBy'] as List),
    );
  }
}

class Poet {
  final String id;
  final String name;
  final String about;
  final String image;
  final int poemCount;

  // For backward compatibility
  String get biography => about;
  String get imageUrl => image;
  String get birthDate => ""; // No equivalent in new model
  String get deathDate => ""; // No equivalent in new model
  List<String> get styles => []; // No equivalent in new model

  Poet({
    required this.id,
    required this.name,
    required this.about,
    required this.image,
    required this.poemCount,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'about': about,
      'image': image,
      'poemCount': poemCount,
    };
  }

  factory Poet.fromJson(Map<String, dynamic> json) {
    String image = json['image'] as String? ?? '';

    // Fix the image URL - if it's a local asset and doesn't start with 'assets/'
    if (image.isNotEmpty &&
        !image.startsWith('http') &&
        !image.startsWith('assets/')) {
      image = 'assets/$image';
    }

    return Poet(
      id: json['id'] as String,
      name: json['name'] as String,
      about: json['about'] as String? ?? '',
      image: image,
      poemCount: json['poemCount'] as int? ?? 0,
    );
  }
}

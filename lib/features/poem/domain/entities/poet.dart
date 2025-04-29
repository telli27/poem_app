class Poet {
  final String id;
  final String name;
  final String? bio;
  final String? imageUrl;
  final int? birthYear;
  final int? deathYear;
  final List<String>? poemIds;

  Poet({
    required this.id,
    required this.name,
    this.bio,
    this.imageUrl,
    this.birthYear,
    this.deathYear,
    this.poemIds,
  });
}

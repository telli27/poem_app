class Poet {
  final String id;
  final String name;
  final int? birthYear;
  final int? deathYear;
  final int poemCount;
  final String? biography;
  final String? imageUrl;

  const Poet({
    required this.id,
    required this.name,
    this.birthYear,
    this.deathYear,
    required this.poemCount,
    this.biography,
    this.imageUrl,
  });
}

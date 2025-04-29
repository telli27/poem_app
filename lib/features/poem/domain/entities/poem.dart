class Poem {
  final String id;
  final String title;
  final String content;
  final String poetId;
  final String? poetName;
  final int? year;
  final int? likes;
  final List<String>? tags;

  Poem({
    required this.id,
    required this.title,
    required this.content,
    required this.poetId,
    this.poetName,
    this.year,
    this.likes,
    this.tags,
  });
}

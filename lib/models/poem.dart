class Poem {
  final String id;
  final String poetId;
  final String title;
  final String content;
  final String author;
  final String? year;
  final List<String> tags;
  final bool isFavorite;
  final String? imageUrl;
  final List<String>? themes;
  final int? readingTime;

  Poem({
    required this.id,
    required this.poetId,
    required this.title,
    required this.content,
    required this.author,
    this.year,
    required this.tags,
    this.isFavorite = false,
    this.imageUrl,
    this.themes,
    this.readingTime,
  });

  Poem copyWith({
    String? id,
    String? poetId,
    String? title,
    String? content,
    String? author,
    String? year,
    List<String>? tags,
    bool? isFavorite,
    String? imageUrl,
    List<String>? themes,
    int? readingTime,
  }) {
    return Poem(
      id: id ?? this.id,
      poetId: poetId ?? this.poetId,
      title: title ?? this.title,
      content: content ?? this.content,
      author: author ?? this.author,
      year: year ?? this.year,
      tags: tags ?? this.tags,
      isFavorite: isFavorite ?? this.isFavorite,
      imageUrl: imageUrl ?? this.imageUrl,
      themes: themes ?? this.themes,
      readingTime: readingTime ?? this.readingTime,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poetId': poetId,
      'title': title,
      'content': content,
      'author': author,
      'year': year,
      'tags': tags,
      'isFavorite': isFavorite,
      'imageUrl': imageUrl,
      'themes': themes,
      'readingTime': readingTime,
    };
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'] as String,
      poetId: json['poetId'] as String,
      title: json['title'] as String,
      content: json['content'] as String,
      author: json['author'] as String,
      year: json['year'] as String?,
      tags: List<String>.from(json['tags'] as List),
      isFavorite: json['isFavorite'] as bool? ?? false,
      imageUrl: json['imageUrl'] as String?,
      themes: json['themes'] != null
          ? List<String>.from(json['themes'] as List)
          : null,
      readingTime: json['readingTime'] as int?,
    );
  }
}

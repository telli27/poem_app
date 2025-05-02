class Poem {
  final String id;
  final String poetId;
  final String name;
  final String content;
  final bool isFavorite;
  final String? year;
  final List<String> tags;

  // For compatibility with existing code
  String get title => name;
  String get author => poetId; // This is not ideal, but maintains compatibility

  Poem({
    required this.id,
    required this.poetId,
    required this.name,
    required this.content,
    this.isFavorite = false,
    this.year,
    this.tags = const [],
  });

  Poem copyWith({
    String? id,
    String? poetId,
    String? name,
    String? content,
    bool? isFavorite,
    String? year,
    List<String>? tags,
  }) {
    return Poem(
      id: id ?? this.id,
      poetId: poetId ?? this.poetId,
      name: name ?? this.name,
      content: content ?? this.content,
      isFavorite: isFavorite ?? this.isFavorite,
      year: year ?? this.year,
      tags: tags ?? this.tags,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'poetId': poetId,
      'name': name,
      'content': content,
      'isFavorite': isFavorite,
      'year': year,
      'tags': tags,
    };
  }

  factory Poem.fromJson(Map<String, dynamic> json) {
    return Poem(
      id: json['id'] as String,
      poetId: json['poetId'] as String,
      name: json['name'] as String,
      content: json['content'] as String,
      isFavorite: json['isFavorite'] as bool? ?? false,
      year: json['year'] as String?,
      tags: json['tags'] != null
          ? List<String>.from(json['tags'] as List)
          : const [],
    );
  }
}

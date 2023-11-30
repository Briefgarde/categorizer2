class WordTag {
  final String description;
  final double score;
  final double topicality;

  WordTag({required this.description, required this.score, required this.topicality});

  factory WordTag.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'description': String keyword,
        'score': double confidence,
        'topicality': double topicality
      } =>
        WordTag(
          description: keyword,
          score: confidence,
          topicality: topicality,
        ),
      _ => throw const FormatException('Failed to load tag.'),
    };
  }
  // make a toJson method usable by jsonEncode
  Map<String, dynamic> toJson() => {
    'description': description,
    'score': score,
    'topicality': topicality,
  };
}
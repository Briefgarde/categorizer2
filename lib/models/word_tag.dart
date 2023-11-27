import 'package:google_vision/google_vision.dart';

class WordTag {
  final String keyword;
  final double confidence;
  final double topicality;

  WordTag({required this.keyword, required this.confidence, required this.topicality});

  factory WordTag.fromJson(Map<String, dynamic> json) {
    return switch (json) {
      {
        'description': String keyword,
        'score': double confidence,
        'topicality': double topicality
      } =>
        WordTag(
          keyword: keyword,
          confidence: confidence,
          topicality: topicality,
        ),
      _ => throw const FormatException('Failed to load tag.'),
    };
  }
  // make a toJson method usable by jsonEncode
  Map<String, dynamic> toJson() => {
    'keyword': keyword,
    'confidence': confidence,
    'topicality': topicality,
  };
}
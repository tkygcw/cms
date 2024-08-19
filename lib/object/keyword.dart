class Keyword {
  int? keywordId;
  String? requirement;
  String? keyword;
  String? targetUrl;

  Keyword({this.keywordId, this.requirement, this.keyword, this.targetUrl});

  factory Keyword.fromJson(Map<String, dynamic> json) {
    return Keyword(
        keywordId: json['keyword_id'] as int,
        requirement: json['requirement'],
        keyword: json['keyword'],
        targetUrl: json['target_url']);
  }

  static List<Keyword> fromJsonList(List list) {
    return list.map((item) => Keyword.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String keywordToString() {
    return '$keyword';
  }

  @override
  String toString() => keyword!;

// Map toJson() => {'Keyword_id': KeywordId, 'sequence': sequence};
}

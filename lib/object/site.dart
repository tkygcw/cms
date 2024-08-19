class Site {
  int? siteId;
  String? companyName;
  String? domain;
  String? username;
  String? password;

  Site({this.siteId, this.companyName, this.domain, this.username, this.password});

  factory Site.fromJson(Map<String, dynamic> json) {
    return Site(
        siteId: json['site_id'] as int,
        companyName: json['company_name'] as String,
        domain: json['domain'],
        username: json['username'],
        password: json['password']);
  }

  static List<Site> fromJsonList(List list) {
    return list.map((item) => Site.fromJson(item)).toList();
  }

  ///this method will prevent the override of toString
  String siteToString() {
    return '$domain';
  }

  @override
  String toString() => domain!;

// Map toJson() => {'site_id': siteId, 'sequence': sequence};
}

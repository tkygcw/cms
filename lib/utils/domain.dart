import 'dart:convert';

import 'package:cms/object/keyword.dart';
import 'package:cms/object/media.dart';
import 'package:cms/object/site.dart';
import 'package:http/http.dart' as http;

class Domain {
  static var domain = 'https://www.chatgpt.lkmng.com/';

  static Uri site = Uri.parse('${domain}site/index.php');
  static Uri keyword = Uri.parse('${domain}keyword/index.php');
  static Uri post = Uri.parse('${domain}post/generate_post.php');

  static Uri media = Uri.parse('${domain}media/index.php');
  static Uri mediaPath = Uri.parse('${domain}media/image/');

  fetchSite() async {
    var response = await http.post(Domain.site, body: {
      'read': '1',
    });
    return jsonDecode(response.body);
  }

  fetchKeyword(Site site) async {
    var response = await http.post(Domain.keyword, body: {
      'read': '1',
      'site_id': site.siteId.toString(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }

  fetchMediaByKeyword(Keyword keyword) async {
    var response = await http.post(Domain.keyword, body: {
      'read_media': '1',
      'keyword_id': keyword.keywordId.toString(),
    });
    return jsonDecode(response.body);
  }

  fetchMedia(Site? site) async {
    var response = await http.post(Domain.media, body: {
      'read': '1',
      'site_id': site != null ? site.siteId.toString() : '-1',
    });
    return jsonDecode(response.body);
  }

  fetchPosts(Site site) async {
    final response = await http.get(Uri.parse('${site.domain}/wp-json/wp/v2/posts'));

    if (response.statusCode == 200) {
      return json.decode(response.body);
    } else {
      throw Exception('Failed to load posts');
    }
  }

  generatePost(Site site, Keyword keyword, restriction) async {
    var response = await http.post(Domain.post, body: {
      'site_id': site.siteId.toString(),
      'keyword': keyword.keyword,
      'requirement': keyword.requirement,
      'restriction': restriction,
      'keyword_id': keyword.keywordId.toString(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }

  addKeyword(keyword, Site site) async {
    var response = await http.post(Domain.keyword, body: {
      'create': '1',
      'keyword': keyword,
      'site_id': site.siteId.toString(),
    });
    return jsonDecode(response.body);
  }

  uploadMedia(Site site, Media media) async {
    var response = await http.post(Domain.media, body: {
      'create': '1',
      'site_id': site.siteId.toString(),
      'image_code': media.imageCode,
    });
    return jsonDecode(response.body);
  }

  // else if (isset($_POST['insert_keyword_media']) && isset($_POST['keyword_id']) && isset($_POST['media_id'])) {
  updateKeywordMedia(Keyword keyword, Media media) async {
    var response = await http.post(Domain.media, body: {
      'insert_keyword_media': '1',
      'keyword_id': keyword.keywordId.toString(),
      'media_id': media.mediaId.toString(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }

  deleteMedia(Media media, Site site) async {
    var response = await http.post(Domain.media, body: {
      'delete': '1',
      'media_id': media.mediaId.toString(),
      'image_name': media.imageName,
      'site_id': site.siteId.toString(),
    });
    return jsonDecode(response.body);
  }

  deleteKeywordMedia(Keyword keyword) async {
    var response = await http.post(Domain.media, body: {
      'delete_keyword_media': '1',
      'keyword_id': keyword.keywordId.toString(),
    });
    return jsonDecode(response.body);
  }

  deleteSingleKeywordMedia(Media media) async {
    var response = await http.post(Domain.media, body: {
      'delete_keyword_media': '1',
      'keyword_link_media': media.keywordLinkMedia.toString(),
    });
    print(response.body);
    return jsonDecode(response.body);
  }
}

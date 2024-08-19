import 'package:flutter/cupertino.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

class Media {
  int? mediaId;
  String? imageName;
  String? imageCode;
  String? size;
  ImageProvider? imageProvider;
  XFile? imageAsset;
  int? siteId;
  int? status;
  int? keywordLinkMedia;

  Media(
      {this.size,
      this.mediaId,
      this.imageName,
      this.imageCode,
      this.imageProvider,
      this.imageAsset,
      this.siteId,
      this.status,
      this.keywordLinkMedia});

  factory Media.fromJson(dynamic json) {
    return Media(
        size: json['size'],
        mediaId: json['media_id'],
        siteId: json['site_id'],
        imageName: json['name'] as String,
        status: 0,
        keywordLinkMedia: json['keyword_link_media']);
  }

  static String getImageName() {
    DateTime now = DateTime.now();
    DateFormat formatter = DateFormat('ymdHmsS');
    return ('${formatter.format(now)}.png');
  }

  Map toJson() => {'image': imageName, 'image_file': imageCode};
}

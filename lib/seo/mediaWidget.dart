import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:cms/object/media.dart';
import 'package:cms/object/site.dart';
import 'package:cms/share_widget/progress_bar.dart';
import 'package:cms/utils/domain.dart';
import 'package:cms/utils/snack_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_image_compress/flutter_image_compress.dart';
import 'package:image_compression_flutter/image_compression_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart' as path_provider;

class MediaWidget extends StatefulWidget {
  const MediaWidget({Key? key}) : super(key: key);

  @override
  State<MediaWidget> createState() => _MediaWidgetState();
}

class _MediaWidgetState extends State<MediaWidget> {
  Site? site;

  List<Media> bannerList = [];
  List<XFile> selectedImages = [];
  String error = 'No Error Detected';
  int bannerLimit = 5;
  bool processingImage = false;
  bool uploadingImage = false;
  bool deletingImage = false;
  bool allowUpload = false;

  late StreamController imageStateStream;
  final picker = ImagePicker();
  var compressedFileSource;

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              selectSitePart(),
              const SizedBox(
                width: 10,
              ),
              Container(
                  alignment: Alignment.centerRight,
                  child: ButtonBar(
                    children: [
                      Visibility(
                        visible: !showDeleteButton(),
                        child: ElevatedButton(
                            onPressed: () => showDeleteMediaDialog(),
                            child: Padding(
                              padding: const EdgeInsets.all(8),
                              child: uploadingImage
                                  ? const CircularProgressIndicator(
                                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                    )
                                  : const Text('Remove Media'),
                            )),
                      ),
                      ElevatedButton(
                          onPressed: !allowUpload ? null : () => uploadMedia(context),
                          child: Padding(
                            padding: const EdgeInsets.all(8),
                            child: uploadingImage
                                ? const CircularProgressIndicator(
                                    valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                  )
                                : const Text('Upload Media'),
                          )),
                    ],
                  )),
              const SizedBox(
                width: 10,
              ),
              Container(
                height: calculateBannerHeight(),
                child: !processingImage
                    ? GridView.count(
                        crossAxisSpacing: 0,
                        mainAxisSpacing: 0,
                        shrinkWrap: true,
                        physics: const NeverScrollableScrollPhysics(),
                        crossAxisCount: !kIsWeb ? 3 : 5,
                        children: bannerList.asMap().map((index, imageGallery) => MapEntry(index, banner(imageGallery, index))).values.toList(),
                      )
                    : const CustomProgressBar(),
              ),
            ],
          )),
    );
  }

  double calculateBannerHeight() {
    try {
      int level = (bannerList.length / (!kIsWeb ? 3 : 5)).ceil();
      return ((!kIsWeb ? 120 : 310) * level).toDouble();
    } catch (e) {
      return !kIsWeb ? 120 : 310;
    }
  }

  Widget banner(Media imageGallery, int position) {
    print(imageGallery.imageName!);
    return Stack(
      key: Key(imageGallery.imageName!),
      children: <Widget>[
        Container(
          color: imageGallery.status == 3 ? Colors.red : Colors.grey[100],
          width: !kIsWeb ? 200 : 320,
          height: !kIsWeb ? 200 : 320,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5.0),
          child: InkWell(
              onTap: () {
                if (position == 0) pickMultipleImages();
              },
              child: getImageView(imageGallery, position)),
        ),
        if (position != 0)
          Positioned.fill(
              child: Container(
            padding: const EdgeInsets.all(8.0),
            child: Align(
                alignment: Alignment.topRight,
                child: InkWell(
                  onTap: () => deleteMedia(position),
                  child: const Icon(
                    Icons.close,
                    color: Colors.grey,
                    size: 20,
                  ),
                )),
          )),
      ],
    );
  }

  deleteMedia(int position) {
    setState(() {
      if (bannerList[position].status == null || bannerList[position].status == 0) {
        bannerList[position].status = 3; // Set status to 3 if it's not already 3
      } else {
        bannerList[position].status = 0; // Set status to 0 if it's already 3
      }
    });
  }

  showDeleteButton() {
    for (int i = 0; i < bannerList.length; i++) {
      if (bannerList[i].status == 3) return false;
    }
    return true;
  }

  Widget selectSitePart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Select Website'),
        SizedBox(
          height: 60,
          child: DropdownSearch<Site>(
            popupProps: const PopupProps.modalBottomSheet(
                showSearchBox: true,
                title: Text(
                  'Merchant Site',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
            asyncItems: (String? filter) => getSiteData(),
            itemAsString: (Site? u) => u!.siteToString(),
            selectedItem: site,
            onChanged: (Site? data) => setState(() {
              site = data;
              getMedia();
            }),
            clearButtonProps: ClearButtonProps(
                isVisible: true,
                icon: const Icon(Icons.clear),
                iconSize: 20,
                color: Colors.blueGrey,
                onPressed: () {
                  setState(() {
                    site = null;
                  });
                }),
            dropdownDecoratorProps: const DropDownDecoratorProps(
              dropdownSearchDecoration: InputDecoration(
                hintText: 'Select Site',
                enabledBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.black12)),
                focusedBorder: UnderlineInputBorder(borderSide: BorderSide(color: Colors.redAccent)),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<List<Site>> getSiteData() async {
    Map data = await Domain().fetchSite();
    List<Site> models = [];
    if (data['status'] == '1') {
      models = Site.fromJsonList(data['site']);
    }
    return models;
  }

  Future getMedia() async {
    Map data = await Domain().fetchMedia(site!);
    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['media'];
        bannerList.addAll(responseJson.map((jsonObject) => Media.fromJson(jsonObject)).toList());
      });
    }
    setGalleryButton(true);
  }

  Future uploadMedia(context) async {
    bool finishUpload = false;
    for (int i = 0; i < bannerList.length; i++) {
      if (bannerList[i].status == 1) {
        setState(() {
          uploadingImage = true;
        });
        Map data = await Domain().uploadMedia(site!, bannerList[i]);
        if (data['status'] == '1') {
          bannerList[i].status = null;
          finishUpload = true;
        }
      }
    }
    if (finishUpload) {
      CustomSnackBar.show(context, 'Upload Successfully!');
    }
    setUploadButton();
  }

  Widget getImageView(Media imageGallery, position) {
    String imagePath = '${Domain.mediaPath.toString()}${site!.siteId.toString()}/';

    if (imageGallery.status == null || imageGallery.status == 0 || imageGallery.imageProvider == null) {
      if (position != 0) {
        return FadeInImage(
            fit: BoxFit.contain,
            image: NetworkImage(imagePath + imageGallery.imageName!),
            imageErrorBuilder: (BuildContext context, Object exception, StackTrace? stackTrace) {
              return Container(
                  width: 120,
                  alignment: Alignment.center,
                  child: const Icon(
                    Icons.error_outline,
                    color: Colors.redAccent,
                    size: 40,
                  ));
            },
            placeholder: const AssetImage('drawable/no-image-found.png'));
      } else {
        return Container(
          padding: const EdgeInsets.all(20.0),
          width: 120,
          child: Image.asset('drawable/add-gallery-icon.png', width: 120, fit: BoxFit.contain),
        );
      }
    } else {
      return Image(
        fit: BoxFit.contain,
        image: imageGallery.imageProvider!,
      );
    }
  }

  Future<void> pickMultipleImages() async {
    List<XFile> resultList = [];
    try {
      ImagePicker picker = ImagePicker();
      resultList = await picker.pickMultiImage(maxHeight: kIsWeb ? 1500 : null, maxWidth: kIsWeb ? 1500 : null);
    } catch (e) {
      print(e);
    }

    if (!mounted) return;
    if (resultList.isEmpty) return;
    processingImage = true;
    error = error;
    selectedImages = resultList;
    setGalleryButton(false);

    for (XFile image in resultList) {
      //reach banner limit}
      ImageProvider provider;
      String imageCode;
      if (!kIsWeb) {
        provider = await compressImage(File(image.path));
        imageCode = base64.encode(compressedFileSource);
      } else {
        Uint8List gallery = await image.readAsBytes();
        compressedFileSource = await compressWebImage(await image.asImageFile);
        provider = MemoryImage(compressedFileSource.rawBytes);
        imageCode = base64.encode(gallery);
      }
      bannerList.add(Media(imageProvider: provider, imageCode: imageCode, imageAsset: image, status: 1, imageName: Media.getImageName()));
    }
    processingImage = false;
    setGalleryButton(true);
    setUploadButton();
  }

  setUploadButton() {
    setState(() {
      for (int i = 0; i < bannerList.length; i++) {
        if (bannerList[i].status == 1) {
          allowUpload = true;
          break;
        }
      }
      uploadingImage = false;
    });
  }

  setGalleryButton(bool add) {
    setState(() {
      if (add) {
        List<Media> newList = List.from(bannerList);
        newList.insert(0, Media(imageName: 'add-gallery-icon.png', status: 0));
        bannerList = newList;
      } else {
        bannerList.removeAt(0);
      }
    });
  }

  getImageGalleryName() {
    List<Media> imageGallery = [];
    for (int i = 0; i < bannerList.length - 1; i++) {
      imageGallery.add(Media(imageName: bannerList[i].imageName!));
    }
    return jsonEncode(imageGallery);
  }

  getImageGalleryFile() {
    List<Media> tempList = [];
    for (int i = 0; i < bannerList.length - 1; i++) {
      if (bannerList[i].status == 1) tempList.add(Media(imageName: bannerList[i].imageName, imageCode: bannerList[i].imageCode));
    }
    return jsonEncode(tempList);
  }

  updateGalleryStatusAfterUpload() {
    for (int i = 0; i < bannerList.length; i++) {
      bannerList[i].status = 0;
    }
  }

  Future<ImageProvider> compressImage(File image) async {
    ByteData data = Uint8List.fromList(image.readAsBytesSync()).buffer.asByteData();
    final dir = await path_provider.getTemporaryDirectory();

    File file = createFile("${dir.absolute.path}/test.png");
    file.writeAsBytesSync(data.buffer.asUint8List());

    compressedFileSource = await compressFile(file);
    ImageProvider provider = MemoryImage(compressedFileSource);
    return provider;
  }

  File createFile(String path) {
    final file = File(path);
    if (!file.existsSync()) {
      file.createSync(recursive: true);
    }
    return file;
  }

  Future<ImageFile> compressWebImage(ImageFile input) async {
    Configuration config = Configuration(
      outputType: ImageOutputType.webpThenJpg,
      useJpgPngNativeCompressor: false,
      quality: countQuality(input.sizeInBytes),
    );
    final param = ImageFileConfiguration(input: input, config: config);
    return await compressor.compress(param);
  }

  countQuality(int quality) {
    if (quality <= 100) {
      return 60;
    } else if (quality > 100 && quality < 500) {
      return 25;
    } else {
      return 20;
    }
  }

  Future<Uint8List?> compressFile(File file) async {
    final result = await FlutterImageCompress.compressWithFile(
      file.absolute.path,
      quality: countQuality(file.lengthSync()),
    );
    return result;
  }

//delete gallery from cloud
  showDeleteMediaDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: const Text("Delete Media"),
          content: const Text("Are you sure that you want to delete these media?"),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text(
                'Confirm',
                style: TextStyle(color: Colors.red),
              ),
              onPressed: () async {
                await deleteMediaFromCloud(context);
              },
            ),
          ],
        );
      },
    );
  }

  deleteMediaFromCloud(context) async {
    for (int i = 0; i < bannerList.length; i++) {
      if (bannerList[i].status == 3) {
        await Domain().deleteMedia(bannerList[i], site!);
        bannerList.removeAt(i); // Remove the item from the list after deleting media
        i--; // Since you removed an item, decrement i to check the next item in the list
      }
    }
    Navigator.of(context).pop();
    CustomSnackBar.show(context, 'Delete Successfully!');
    setState(() {});
  }

  deleteFromList(position) {
    setState(() {
      for (int j = 0; j < selectedImages.length; j++) {
        if (bannerList[position].imageAsset == selectedImages[j]) selectedImages.removeAt(j);
      }
      bannerList.removeAt(position);
    });
  }
}


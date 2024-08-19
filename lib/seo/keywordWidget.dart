import 'package:cms/dialog/select_media_dialog.dart';
import 'package:cms/object/media.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:cms/dialog/add_keyword_dialog.dart';
import 'package:cms/dialog/check_post_dialog.dart';
import 'package:cms/object/keyword.dart';
import 'package:cms/object/site.dart';
import 'package:cms/utils/domain.dart';
import 'package:cms/utils/snack_bar.dart';

import 'package:dropdown_search/dropdown_search.dart';

class KeywordWidget extends StatefulWidget {
  const KeywordWidget({Key? key}) : super(key: key);

  @override
  State<KeywordWidget> createState() => _KeywordWidgetState();
}

class _KeywordWidgetState extends State<KeywordWidget> {
  Site? site;
  Keyword? keyword;
  late String restrictionData;
  bool _isLoading = false;

  late TextEditingController keywordText = TextEditingController();
  late TextEditingController requirement = TextEditingController();
  late TextEditingController restriction = TextEditingController();

  List<Media> mediaList = [];

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      child: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(child: selectSitePart()),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(child: selectKeywordPart()),
                ],
              ),
              const SizedBox(
                height: 20,
              ),
              if (site != null && keyword != null) detailPart(),
            ],
          )),
    );
  }

  Widget detailPart() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.end,
      children: [
        TextField(
          controller: keywordText,
          minLines: 1,
          maxLines: 100,
          maxLength: 60,
          decoration: const InputDecoration(
            labelText: 'Focus Keyword', // Your label here
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(onPressed: () => addMediaDialog(context, site!), child: Text('Select Media')),
        SingleChildScrollView(
            child: GridView.count(
          crossAxisSpacing: 0,
          mainAxisSpacing: 0,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          crossAxisCount: !kIsWeb ? 3 : 5,
          children: mediaList.asMap().map((index, imageGallery) => MapEntry(index, banner(imageGallery, index))).values.toList(),
        )),
        const SizedBox(
          height: 10,
        ),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: TextField(
                controller: requirement,
                minLines: 10,
                maxLines: 100,
                decoration: const InputDecoration(
                  labelText: 'Requirement', // Your label here
                ),
              ),
            ),
            const SizedBox(
              width: 10,
            ),
            Expanded(
              child: TextField(
                controller: restriction,
                minLines: 10,
                maxLines: 100,
                decoration: const InputDecoration(
                  labelText: 'Restriction', // Your label here
                ),
              ),
            ),
          ],
        ),
        const SizedBox(
          height: 10,
        ),
        ElevatedButton(
            onPressed: () => _isLoading ? null : createPost(context),
            child: Padding(
              padding: const EdgeInsets.all(8),
              child: _isLoading
                  ? const CircularProgressIndicator(
                      valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                    )
                  : const Text('Create Post'),
            ))
      ],
    );
  }

  Widget banner(Media imageGallery, int position) {
    return Stack(
      key: Key(imageGallery.imageName!),
      children: <Widget>[
        Container(
          color: imageGallery.status == 3 ? Colors.red : Colors.grey[100],
          width: !kIsWeb ? 200 : 320,
          height: !kIsWeb ? 200 : 320,
          alignment: Alignment.center,
          margin: const EdgeInsets.all(5.0),
          child: getImageView(imageGallery),
        ),
        Positioned.fill(
            child: Container(
          padding: const EdgeInsets.all(8.0),
          child: Align(
              alignment: Alignment.topRight,
              child: InkWell(
                onTap: () => showDeleteMediaDialog(imageGallery),
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

  Widget getImageView(Media imageGallery) {
    String imagePath = site != null
        ? '${Domain.mediaPath.toString()}${site!.siteId.toString()}/'
        : '${Domain.mediaPath.toString()}${imageGallery.siteId.toString()}/';

    return FadeInImage(
      fit: BoxFit.contain,
      image: NetworkImage(imagePath + imageGallery.imageName!),
      imageErrorBuilder: (context, error, stackTrace) => Container(
        width: 120,
        alignment: Alignment.center,
        child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
      ),
      placeholder: const AssetImage('drawable/no-image-found.png'),
    );
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
        ElevatedButton(onPressed: () => addPostDialog(context, site!), child: const Text('Check Posts'))
      ],
    );
  }

  Widget selectKeywordPart() {
    return site != null
        ? Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text('Select Keyword'),
              SizedBox(
                height: 60,
                child: DropdownSearch<Keyword>(
                  popupProps: const PopupProps.modalBottomSheet(
                      showSearchBox: true,
                      title: Text(
                        'Keyword',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      )),
                  asyncItems: (String? filter) => getKeywordData(),
                  itemAsString: (Keyword? u) => u!.keywordToString(),
                  selectedItem: keyword,
                  onChanged: (Keyword? data) => setState(() {
                    keyword = data;
                    keywordText.text = keyword!.keyword!;
                    requirement.text = keyword!.requirement!;
                    getKeywordMedia();
                  }),
                  clearButtonProps: ClearButtonProps(
                      isVisible: true,
                      icon: const Icon(Icons.clear),
                      iconSize: 20,
                      color: Colors.blueGrey,
                      onPressed: () {
                        setState(() {
                          keyword = null;
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
              ElevatedButton(onPressed: () => addKeywordDialog(context, site!), child: const Text('Add Keyword'))
            ],
          )
        : Container();
  }

  Future<List<Keyword>> getKeywordData() async {
    Map data = await Domain().fetchKeyword(site!);
    var models;
    if (data['status'] == '1') {
      models = Keyword.fromJsonList(data['keyword']);
      restriction.text = data['restriction'][0]['restriction'];
    }
    return models;
  }

  Future getKeywordMedia() async {
    mediaList.clear();
    Map data = await Domain().fetchMediaByKeyword(keyword!);

    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['media'];
        mediaList.addAll(responseJson.map((jsonObject) => Media.fromJson(jsonObject)).toList());
      });
    }
  }

  Future<List<Site>> getSiteData() async {
    Map data = await Domain().fetchSite();
    var models;
    if (data['status'] == '1') {
      models = Site.fromJsonList(data['site']);
    }
    return models;
  }

  createPost(context) async {
    setState(() {
      _isLoading = true;
    });
    try {
      keyword!.requirement = requirement.text;
      keyword!.keyword = keywordText.text;
      Map data = await Domain().generatePost(site!, keyword!, restriction.text);

      if (data['status'] == '1') {
        CustomSnackBar.show(context, 'Post is created successfully!');
      } else {
        CustomSnackBar.show(context, data['message']);
      }
    } catch (e) {
      print(e);
      CustomSnackBar.show(context, '$e');
      setState(() {
        _isLoading = false;
      });
    }

    setState(() {
      _isLoading = false;
    });
  }

/*
    * update add keyword
    * */
  addKeywordDialog(mainContext, Site site) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return AddKeywordDialog(
          callBack: () async {
            CustomSnackBar.show(context, 'Keyword is created successfully!');
            await Future.delayed(const Duration(milliseconds: 500));
          },
          site: site,
        );
      },
    );
  }

/*
    * check posts
    * */
  addPostDialog(mainContext, Site site) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return CheckPostDialog(
          site: site,
        );
      },
    );
  }

/*
    * check media
    * */
  addMediaDialog(mainContext, Site site) {
    // flutter defined function
    showDialog(
      context: mainContext,
      builder: (BuildContext context) {
        // return alert dialog object
        return SelectMediaDialog(
            keyword: keyword!,
            selectedMediaList: mediaList,
            site: site,
            callBack: (list) {
              setState(() {
                mediaList = list;
              });
            });
      },
    );
  }

//delete gallery from cloud
  showDeleteMediaDialog(Media media) async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        // return alert dialog object
        return AlertDialog(
          title: const Text("Delete Media"),
          content: const Text("Are you sure that you want to remove this media?"),
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
                await deleteMediaFromCloud(context, media);
              },
            ),
          ],
        );
      },
    );
  }

  Future deleteMediaFromCloud(context, Media media) async {
    Map data = await Domain().deleteSingleKeywordMedia(media);
    if (data['status'] == '1') {
      CustomSnackBar.show(context, 'Delete Successfully!');
      setState(() {
        mediaList.remove(media);
      });
    } else {
      CustomSnackBar.show(context, 'Something weng wrong!');
    }
    Navigator.of(context).pop();
  }
}

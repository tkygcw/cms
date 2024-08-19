import 'package:cms/object/keyword.dart';
import 'package:cms/object/media.dart';
import 'package:cms/object/site.dart';
import 'package:cms/share_widget/progress_bar.dart';
import 'package:cms/utils/domain.dart';
import 'package:cms/utils/snack_bar.dart';
import 'package:dropdown_search/dropdown_search.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class SelectMediaDialog extends StatefulWidget {
  final Site site;
  final List<Media> selectedMediaList;
  final Keyword keyword;
  final Function(List<Media>) callBack;

  const SelectMediaDialog({super.key, required this.site, required this.callBack, required this.selectedMediaList, required this.keyword});

  @override
  _SelectMediaDialogState createState() => _SelectMediaDialogState();
}

class _SelectMediaDialogState extends State<SelectMediaDialog> {
  List<Media> mediaList = [];
  List<Media> selectedMediaList = [];

  bool isLoading = false;

  Site? site;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    site = widget.site;
    selectedMediaList.addAll(widget.selectedMediaList);
    getMedia();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
        title: const Text('Media'),
        actions: <TextButton>[
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Close'),
          ),
          TextButton(
            onPressed: selectedMediaList.isNotEmpty
                ? () async {
                    updateKeywordMedia(context);
                  }
                : null,
            child: Text(
              'Add',
              style: TextStyle(color: selectedMediaList.isNotEmpty ? Colors.green : Colors.blueGrey),
            ),
          ),
        ],
        content: SingleChildScrollView(
            child: Column(
          children: [
            selectSitePart(),
            SizedBox(
              height: calculateBannerHeight(),
              width: 300,
              child: !isLoading
                  ? GridView.count(
                      crossAxisSpacing: 0,
                      mainAxisSpacing: 0,
                      shrinkWrap: false,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: !kIsWeb ? 3 : 5,
                      children: mediaList
                          .asMap()
                          .map((index, imageGallery) => MapEntry(index, banner(imageGallery, index, isSelectedMedia(imageGallery))))
                          .values
                          .toList(),
                    )
                  : const CustomProgressBar(),
            ),
          ],
        )));
  }

  isSelectedMedia(Media media) {
    for (int i = 0; i < selectedMediaList.length; i++) {
      if (selectedMediaList[i].mediaId == media.mediaId) return true;
    }
    return false;
  }

  Widget banner(Media imageGallery, int position, bool isSelected) {
    return Container(
      color: isSelected ? Colors.red : Colors.grey[100],
      width: !kIsWeb ? 200 : 320,
      height: !kIsWeb ? 200 : 320,
      alignment: Alignment.center,
      margin: const EdgeInsets.all(5.0),
      child: getImageView(imageGallery),
    );
  }

  Widget getImageView(Media imageGallery) {
    String imagePath = site != null
        ? '${Domain.mediaPath.toString()}${site!.siteId.toString()}/'
        : '${Domain.mediaPath.toString()}${imageGallery.siteId.toString()}/';

    return InkWell(
      onTap: () {
        setState(() {
          bool found = false;
          for (int i = 0; i < selectedMediaList.length; i++) {
            if (selectedMediaList[i].mediaId == imageGallery.mediaId) {
              found = true;
              selectedMediaList.removeAt(i);
            }
          }
          if (!found) selectedMediaList.add(imageGallery);
        });
      },
      child: FadeInImage(
        fit: BoxFit.contain,
        image: NetworkImage(imagePath + imageGallery.imageName!),
        imageErrorBuilder: (context, error, stackTrace) => Container(
          width: 120,
          alignment: Alignment.center,
          child: const Icon(Icons.error_outline, color: Colors.redAccent, size: 40),
        ),
        placeholder: const AssetImage('drawable/no-image-found.png'),
      ),
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
                  style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
                  textAlign: TextAlign.center,
                )),
            asyncItems: (String? filter) => getSiteData(),
            itemAsString: (Site? u) => u!.siteToString(),
            selectedItem: site,
            onChanged: (Site? data) => setState(() {
              site = data!;
              getMedia();
            }),
            clearButtonProps: ClearButtonProps(
                isVisible: true,
                icon: const Icon(Icons.clear),
                iconSize: 15,
                color: Colors.blueGrey,
                onPressed: () {
                  setState(() {
                    site = null;
                    getMedia();
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

  double calculateBannerHeight() {
    try {
      int level = (mediaList.length / (!kIsWeb ? 3 : 5)).ceil();
      return ((!kIsWeb ? 120 : 310) * level).toDouble();
    } catch (e) {
      return !kIsWeb ? 120 : 310;
    }
  }

  Future getMedia() async {
    mediaList.clear();
    Map data = await Domain().fetchMedia(site);
    if (data['status'] == '1') {
      setState(() {
        List responseJson = data['media'];
        mediaList.addAll(responseJson.map((jsonObject) => Media.fromJson(jsonObject)).toList());
      });
    }
  }

  Future<List<Site>> getSiteData() async {
    Map data = await Domain().fetchSite();
    List<Site> models = [];
    if (data['status'] == '1') {
      models = Site.fromJsonList(data['site']);
    }
    return models;
  }

  Future updateKeywordMedia(context) async {
    Map data = await Domain().deleteKeywordMedia(widget.keyword);
    if (data['status'] == '1') {
      for (int i = 0; i < selectedMediaList.length; i++) {
        Map data = await Domain().updateKeywordMedia(widget.keyword, selectedMediaList[i]);
        if (data['status'] == '1') {
          selectedMediaList[i].status = 0;
        }
      }
      widget.callBack(selectedMediaList);
      Navigator.of(context).pop();
    } else {
      CustomSnackBar.show(context, 'Something Went Wrong!');
    }
  }
}

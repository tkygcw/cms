import 'package:cms/seo/keywordWidget.dart';
import 'package:cms/seo/mediaWidget.dart';
import 'package:flutter/material.dart';

class SEO extends StatefulWidget {
  const SEO({Key? key}) : super(key: key);

  @override
  State<SEO> createState() => _SEOState();
}

class _SEOState extends State<SEO> {
  int selectedMenu = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('SEO'),
        ),
        body: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
                child: Container(
              color: Colors.black54,
              child: Column(
                children: [
                  customListTile('Setup Post', 0),
                  const Divider(
                    color: Colors.black12,
                    height: 0.014,
                  ),
                  customListTile('Media', 1),
                ],
              ),
            )),
            Expanded(flex: 10, child: contentPart())
          ],
        ));
  }

  Widget customListTile(title, position) {
    return ListTile(
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      onTap: () {
        setState(() {
          selectedMenu = position;
        });
      },
    );
  }

  contentPart() {
    switch (selectedMenu) {
      case 0:
        return const KeywordWidget();
      default:
        return const MediaWidget();
    }
  }
}

import 'package:cms/object/site.dart';
import 'package:cms/utils/domain.dart';
import 'package:cms/utils/snack_bar.dart';
import 'package:flutter/material.dart';

class CheckPostDialog extends StatefulWidget {
  final Site site;

  const CheckPostDialog({super.key, required this.site});

  @override
  _CheckPostDialogState createState() => _CheckPostDialogState();
}

class _CheckPostDialogState extends State<CheckPostDialog> {
  var keyword = TextEditingController();
  List<dynamic> posts = [];

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchPost();
  }

  @override
  Widget build(BuildContext context) {
    Size screenSize = MediaQuery.of(context).size;
    return AlertDialog(
      title: const Text('Add Keyword'),
      actions: <Widget>[
        TextButton(
          child: const Text('Close'),
          onPressed: () {
            Navigator.of(context).pop();
          },
        ),
      ],
      content: SizedBox(
        width: screenSize.width / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            // ElevatedButton(onPressed: () => fetchPost(context), child: const Text('Check All Posts')),
            ListView.builder(
              itemCount: posts.length,
              shrinkWrap: true,
              itemBuilder: (BuildContext context, int index) {
                final post = posts[index];
                return ListTile(
                  title: Text(post['title']['rendered']),
                  subtitle: Text(post['excerpt']['rendered']),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  fetchPost() async {
    try {
      posts = await Domain().fetchPosts(widget.site);
      setState(() {});
    } catch (e) {}
  }
}

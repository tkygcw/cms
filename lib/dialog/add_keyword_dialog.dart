import 'package:cms/object/site.dart';
import 'package:cms/utils/domain.dart';
import 'package:cms/utils/snack_bar.dart';
import 'package:flutter/material.dart';

class AddKeywordDialog extends StatefulWidget {
  final Function() callBack;
  final Site site;

  const AddKeywordDialog({super.key, required this.site, required this.callBack});

  @override
  _AddKeywordDialogState createState() => _AddKeywordDialogState();
}

class _AddKeywordDialogState extends State<AddKeywordDialog> {
  var keyword = TextEditingController();

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
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
        TextButton(
          child: const Text(
            'Add',
            style: TextStyle(color: Colors.red),
          ),
          onPressed: () {
            if (keyword.text.isNotEmpty) {
              addKeyword(context);
            } else {
              CustomSnackBar.show(context, 'Keyword is missing');
            }
          },
        ),
      ],
      content: SizedBox(
        width: screenSize.width / 3,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
                keyboardType: TextInputType.text,
                controller: keyword,
                textAlign: TextAlign.start,
                minLines: 1,
                maxLines: 100,
                maxLength: 60,
                decoration: const InputDecoration(
                  labelText: 'Focus Keyword',
                  labelStyle: TextStyle(fontSize: 16, color: Colors.blueGrey, fontWeight: FontWeight.bold),
                  hintText: 'Focused Keyword',
                  border: OutlineInputBorder(borderSide: BorderSide(color: Colors.teal)),
                )),
          ],
        ),
      ),
    );
  }

  addKeyword(context) async {
    try {
      Map data = await Domain().addKeyword(keyword.text, widget.site);
      if (data['status'] == '1') {
        widget.callBack();
        Navigator.of(context).pop();
      } else {
        CustomSnackBar.show(context, data['message']);
      }
    } catch (e) {
      CustomSnackBar.show(context, '$e');
    }
  }
}

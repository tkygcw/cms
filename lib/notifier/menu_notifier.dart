import 'package:flutter/cupertino.dart';

class MenuNotifier extends ChangeNotifier {
  String selectedMenu = 'SEO';

  MenuNotifier();

  void initialLoad() async {}

  void setSelectedMenu(String menu) {
    selectedMenu = menu;
    notifyListeners();
  }
}

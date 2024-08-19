import 'package:cms/notifier/hosting_checker.dart';
import 'package:cms/notifier/menu_notifier.dart';
import 'package:cms/seo/seo.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  const Home({Key? key}) : super(key: key);

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late MenuNotifier menuNotifier;
  int _selectedIndex = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    menuNotifier = context.read<MenuNotifier>();
  }

  Widget customListTile(IconData icon, title, subtitle, position) {
    return ListTile(
      contentPadding: const EdgeInsets.fromLTRB(10, 0, 0, 0),
      leading: Icon(
        icon,
        color: Colors.white,
      ),
      title: Text(
        title,
        style: const TextStyle(color: Colors.white),
      ),
      // subtitle: Text(subtitle),
      onTap: () {
        menuNotifier.setSelectedMenu(title);
        _onItemTapped(position);
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SafeArea(
      child: Row(mainAxisAlignment: MainAxisAlignment.start, children: [
        Expanded(
            flex: 2,
            child: Container(
              color: Colors.black,
              child: Column(
                children: [
                  customListTile(Icons.search_off, 'SEO', 'nothing', 0),
                  const Padding(
                    padding: EdgeInsets.fromLTRB(20, 0, 20, 0),
                    child: Divider(
                      color: Colors.blueGrey,
                    ),
                  ),
                  customListTile(Icons.dns, 'DNS', 'nothing', 1),
                ],
              ),
            )),
        Expanded(
          flex: 10,
          child: Consumer<MenuNotifier>(builder: (context, MenuNotifier menu, child) {
            switch (menu.selectedMenu) {
              case 'SEO':
                return const SEO();
              default:
                return const HostingChecker();
            }
          }),
        ),
      ]),
    ));
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
}

import 'dart:ui';

import 'package:cms/home.dart';
import 'package:cms/notifier/menu_notifier.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
        providers: [
          ChangeNotifierProvider<MenuNotifier>(
            create: (_) => MenuNotifier(),
          ),
        ],
        child: MaterialApp(
          onGenerateTitle: (BuildContext context) {
            return 'CMS';
          },
          scrollBehavior: const MaterialScrollBehavior().copyWith(
            dragDevices: {PointerDeviceKind.mouse, PointerDeviceKind.touch},
          ),
          debugShowCheckedModeBanner: false,
          theme: ThemeData(
              appBarTheme: const AppBarTheme(
                backgroundColor: Colors.white,
                titleTextStyle: TextStyle(color: Colors.black),
                iconTheme: IconThemeData(color: Colors.orange), //
              ),
              primarySwatch: Colors.deepOrange,
              inputDecorationTheme: const InputDecorationTheme(
                focusColor: Colors.black,
                labelStyle: TextStyle(
                  color: Colors.black54,
                ),
                enabledBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.black26,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderSide: BorderSide(
                    color: Colors.orangeAccent,
                    width: 2.0,
                  ),
                ),
              )),
          routes: {'/': (context) => Home()},
        ));
  }
}

import 'package:flutter/material.dart';

class CustomSnackBar {
  final String message;

  const CustomSnackBar({
    required this.message,
  });

  static show(
    BuildContext context,
    String message,
  ) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        elevation: 0.0,
        //behavior: SnackBarBehavior.floating,
        content: Text(message),
        duration: const Duration(seconds: 2),
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.only(topLeft: Radius.circular(1.0), topRight: Radius.circular(1.0)),
        ),
        //backgroundColor: Colors.redAccent,
        action: SnackBarAction(
          textColor: const Color(0xFFFAF2FB),
          label: 'Okay',
          onPressed: () {},
        ),
      ),
    );
  }
}

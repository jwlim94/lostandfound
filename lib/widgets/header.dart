import 'package:flutter/material.dart';

AppBar header(
  context, {
  bool isAppTitle = false,
  String titleText = 'default',
  removeBackButton = false,
}) {
  return AppBar(
    // automaticallyImplyLeading: removeBackButton ? false : true,
    leading: removeBackButton
        ? const Text('')
        : const BackButton(
            color: Colors.black,
          ),
    title: Text(
      isAppTitle ? "Lost & Found" : titleText,
      style: TextStyle(
        color: Colors.black,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
      overflow: TextOverflow.ellipsis,
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
  );
}

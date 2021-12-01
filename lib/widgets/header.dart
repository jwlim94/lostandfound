import 'package:flutter/material.dart';

AppBar header(
  context, {
  bool isAppTitle = false,
  String titleText = 'default',
  removeBackButton = false,
}) {
  return AppBar(
    automaticallyImplyLeading: removeBackButton ? false : true,
    title: Text(
      isAppTitle ? "Lost & Found" : titleText,
      style: TextStyle(
        color: Colors.black,
        fontFamily: isAppTitle ? 'Signatra' : '',
        fontSize: isAppTitle ? 50.0 : 22.0,
      ),
    ),
    centerTitle: true,
    backgroundColor: Colors.white,
  );
}

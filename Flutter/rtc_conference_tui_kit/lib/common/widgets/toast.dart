import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:rtc_conference_tui_kit/common/index.dart';

Future<bool?> makeToast({
  required String msg,
  Color backgroundColor = RoomColors.toastBlack,
  Color textColor = Colors.white,
}) {
  return Fluttertoast.showToast(
    msg: msg,
    toastLength: Toast.LENGTH_SHORT,
    gravity: ToastGravity.CENTER,
    timeInSecForIosWeb: 1,
    backgroundColor: backgroundColor,
    textColor: textColor,
    fontSize: 16,
  );
}

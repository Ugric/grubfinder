import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

void showToast(FToast fToast, String message) {
  fToast.showToast(
    child: Container(
      padding: const EdgeInsets.symmetric(
          horizontal: 24.0, vertical: 12.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(25.0),
        color: Colors.white,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 12.0,
          ),
          Text(
            message,
            style: TextStyle(color: Colors.black),
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    ),
    gravity: ToastGravity.BOTTOM,
    toastDuration: Duration(seconds: 5),
  );
}
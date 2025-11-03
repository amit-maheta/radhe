import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class AppConstants {
  static String authID = '';
  static String userID = '';
  static String fcmKey = '';
  static String WEB_URL = '';
  static String LOGIN_USER_NAME = '';
  static String LOGIN_USER_CONTACT_NUMBER = '';
  static String LOGIN_USER_EMAIL = '';
  static String LOGIN_USER_IS_ADMIN = '';
  static String LOGIN_TOKEN = '';
}

//shared preference
const userId = "user_id";
const userEmail = "user_email";
const userName = "user_name";
const isAdmin = "is_admin";
const loginToken = "loginToken";

Future<void> showLoadingDialog(
  BuildContext context,
  GlobalKey _key,
  String message,
) async {
  const shadowGray = Color.fromRGBO(102, 78, 190, 0.161);
  const yellowDark = Color.fromARGB(255, 116, 111, 207);

  return Future.delayed(Duration.zero, () {
    showDialog(
      barrierDismissible: false,
      context: context,
      builder: (BuildContext context) {
        final width = MediaQuery.of(context).size.width;
        final height = MediaQuery.of(context).size.height;
        return Container(
          key: _key,
          height: height,
          width: width,
          color: shadowGray,
          child: Center(child: CircularProgressIndicator(color: yellowDark)),
        );
      },
    );
  });
}

void showSnakeBar(
  BuildContext context,
  String msg, {
  Color? backgroundColor,
  Duration duration = const Duration(seconds: 3),
}) {
  ScaffoldMessenger.of(context).showSnackBar(
    SnackBar(
      content: Text(
        msg,
        style: const TextStyle(
          color: Colors.white,
          fontSize: 14,
          fontWeight: FontWeight.bold,
        ),
      ),
      backgroundColor: backgroundColor ?? Colors.red,
      elevation: 10,
      behavior: SnackBarBehavior.floating,
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      duration: duration,
    ),
  );
}

String formatDate(String? isoDateString) {
  if (isoDateString == null || isoDateString.isEmpty) {
    return "";
  }

  try {
    // Parse the ISO 8601 UTC date string to DateTime object
    DateTime dateTimeUtc = DateTime.parse(isoDateString);

    // Convert to local time
    DateTime dateTimeLocal = dateTimeUtc.toLocal();

    // Format to a readable string
    // 12-hour format with AM/PM
    return DateFormat('dd-MM-yyyy').format(dateTimeLocal);
  } catch (e) {
    // If parsing fails, return empty string
    return "";
  }
}

String formatTime(String? isoDateString) {
  if (isoDateString == null || isoDateString.isEmpty) {
    return "";
  }

  try {
    // Parse the ISO 8601 UTC date string to DateTime object
    DateTime dateTimeUtc = DateTime.parse(isoDateString);

    // Convert to local time
    DateTime dateTimeLocal = dateTimeUtc.toLocal();

    // Format to a readable string
    // 12-hour format with AM/PM
    return DateFormat('hh:mm a').format(dateTimeLocal);
  } catch (e) {
    // If parsing fails, return empty string
    return "";
  }
}

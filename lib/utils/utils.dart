import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';


class Utils {
  static TimeOfDay? convertTime(String inputTime) {
    TimeOfDay? time;
    try {
      List<String> timeParts = inputTime.split(':');
      if (timeParts.length != 2) {
        throw const FormatException('Invalid time format. Expected HH:MM.');
      }

      int hour = int.parse(timeParts[0]);
      int minute = int.parse(timeParts[1]);

      if (hour < 0 || hour > 23 || minute < 0 || minute > 59) {
        throw const FormatException(
            'Invalid time values. Hours must be between 0 and 23, minutes between 0 and 59.');
      }
      time = TimeOfDay(hour: hour, minute: minute);
    } catch (e) {
      time = null;

      Fluttertoast.showToast(
          msg: "'Error: ${e.toString()}.",
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.CENTER,
          timeInSecForIosWeb: 1,
          backgroundColor: Colors.grey,
          textColor: Colors.black,
          fontSize: 16.0
      );
    }
    return time;
  }
}

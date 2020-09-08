import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IntlHelper {
  static String format(DateTime dt, {String formatStr = "dd/MM/yyyy"}) {
    var dateStr = DateFormat(formatStr).format(dt);
    return dateStr;
  }

  static Duration parseDuration(String timeStr) {
    int hours = int.parse(timeStr.split(':')[0]);
    int minutes = int.parse(timeStr.split(':')[1]);
    return Duration(hours: hours, minutes: minutes);
  }

  static TimeOfDay convertDurationToTimeOfDay(Duration dur) {
    return parseTimeOfDay(dur.inHours.toString() +
        ":" +
        (dur.inMinutes - dur.inHours * 60).toString());
  }

  static DateTime parseDateTime(String s,
      {String formatStr = "dd/MM/yyyy HH:mm"}) {
    return DateFormat(formatStr).parse(s);
  }

  static TimeOfDay parseTimeOfDay(String s) {
    int hour = int.parse(s.split(':')[0]);
    int minute = int.parse(s.split(':')[1].split(' ')[0]);
    if (s.contains('PM')) {
      if (hour != 12) {
        hour += 12;
      }
    } else if (s.contains('AM')) {
      if (hour == 12) {
        hour = 0;
      }
    }
    return TimeOfDay(hour: hour, minute: minute);
  }

  static String formatTimeOfDay(TimeOfDay timeOfDay) {
    if (timeOfDay == null) {
      return null;
    } else {
      int hour = timeOfDay.hour;
      int minute = timeOfDay.minute;
      return (hour < 10 ? '0' + hour.toString() : hour.toString()) +
          ':' +
          (minute < 10 ? '0' + minute.toString() : minute.toString());
    }
  }

  static int compareTimeOfDay(TimeOfDay t1, TimeOfDay t2) {
    int t1InSecs = t1.hour * 60 + t1.minute;
    int t2InSecs = t2.hour * 60 + t2.minute;
    return t1InSecs - t2InSecs;
  }
}

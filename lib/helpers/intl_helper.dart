import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

class IntlHelper {
  static String format(DateTime dt, {String formatStr = "dd/MM/yyyy"}) {
    var dateStr = DateFormat(formatStr).format(dt);
    return dateStr;
  }

  static DateTime parseDateTime(String s, {String formatStr = "dd/MM/yyyy HH:mm"}){
    return DateFormat(formatStr).parse(s);
  }

  static TimeOfDay parseTimeOfDay(String s) {
    return TimeOfDay(
        hour: int.parse(s.split(":")[0]), minute: int.parse(s.split(":")[1]));
  }

  static int compareTimeOfDay(TimeOfDay t1, TimeOfDay t2) {
    int t1InSecs = t1.hour * 60 + t1.minute;
    int t2InSecs = t2.hour * 60 + t2.minute;
    return t1InSecs - t2InSecs;
  }
}

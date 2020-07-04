import 'package:intl/intl.dart';

class IntlHelper {
  static String format(DateTime dt, {String formatStr = "dd/MM/yyyy"}) {
    var dateStr = DateFormat(formatStr).format(dt);
    return dateStr;
  }
}

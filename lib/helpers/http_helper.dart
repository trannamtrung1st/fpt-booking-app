import 'package:fptbooking_app/contexts/login_context.dart';

class HttpHelper {
  static Map<String, String> commonHeaders(
      {List<MapEntry> entries, bool hasBody = false}) {
    var map = <String, String>{};
    if (LoginContext.accessToken != null)
      map['Authorization'] = 'Bearer ' + LoginContext.accessToken;
    if (hasBody) map['Content-Type'] = 'application/json';
    if (entries != null) for (MapEntry e in entries) map[e.key] = e.value;
    return map;
  }
}

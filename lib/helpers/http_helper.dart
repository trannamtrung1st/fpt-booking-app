import 'package:fptbooking_app/contexts/login_context.dart';
import 'package:http/http.dart' as http;

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

extension HttpExtension on http.Response {
  bool isSuccess() {
    return this.statusCode >= 200 && this.statusCode <= 204;
  }
}

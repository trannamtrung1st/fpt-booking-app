import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fptbooking_app/app/refreshable.dart';

class PageContext extends ChangeNotifier {
  Map<Type, Refreshable> _refreshableMap = {};

  void setRefreshable(Type t, Refreshable r) {
    _refreshableMap[t] = r;
  }

  void markAsNeedRefresh(Type t) {
    if (_refreshableMap.containsKey(t)) {
      var r = _refreshableMap[t];
      r.needRefresh = true;
    }
  }

  void refreshIfNeeded(Type t) {
    if (_refreshableMap.containsKey(t)) {
      var r = _refreshableMap[t];
      if (r.needRefresh) {
        r.refresh();
      }
    }
  }
}

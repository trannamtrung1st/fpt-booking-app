import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:fptbooking_app/app/refreshable.dart';

class PageContext extends ChangeNotifier {
  Map<Type, Refreshable> _refreshableMap = {};
  Type currentTabWidgetType;

  void setRefreshable(Type t, Refreshable r) {
    _refreshableMap[t] = r;
  }

  void markAsNeedRefresh(Type t) {
    if (_refreshableMap.containsKey(t)) {
      var r = _refreshableMap[t];
      r.needRefresh = true;
      r.updateKeepAlive();
    }
  }

  void refreshIfNeeded(Type t, {dynamic refreshParam}) {
    if (_refreshableMap.containsKey(t)) {
      var r = _refreshableMap[t];
      if (r.needRefresh) {
        r.refresh(refreshParam: refreshParam);
      }
    }
  }
}

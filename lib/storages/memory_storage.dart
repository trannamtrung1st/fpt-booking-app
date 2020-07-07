class MemoryStorage {
  static final Map<String, dynamic> _data = {};

  static dynamic get(String key) {
    return _data[key];
  }

  static void set(String key, dynamic val) {
    _data[key] = val;
  }

  static Map<String, dynamic> roomTypesMap;
}

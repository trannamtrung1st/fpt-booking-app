class MemoryStorage {
  static final Map<String, dynamic> _data = {};

  static dynamic get(String key) {
    return _data[key];
  }

  static void set(String key, dynamic val) {
    _data[key] = val;
  }

  static List<dynamic> bookingServices;

  static Map<String, dynamic> roomTypesMap;

  static final List<MapEntry<String, String>> statuses =
      <MapEntry<String, String>>[
    MapEntry("", "All"),
    MapEntry("Processing", "Processing"),
    MapEntry("Valid", "Valid"),
    MapEntry("Approved", "Approved"),
    MapEntry("Denied", "Denied"),
    MapEntry("Finished", "Finished"),
    MapEntry("Aborted", "Aborted")
  ];
}

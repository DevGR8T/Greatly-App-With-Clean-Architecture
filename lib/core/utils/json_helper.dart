class JsonHelper {
  static dynamic getNestedValue(
    Map<String, dynamic>? json,
    List<String> keys,
  ) {
    dynamic current = json;
    for (final key in keys) {
      if (current is Map<String, dynamic> && current.containsKey(key)) {
        current = current[key];
      } else {
        return null; // Key not found
      }
    }
    return current;
  }
}

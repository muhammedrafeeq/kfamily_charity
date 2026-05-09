/// Converts a snake_case key to camelCase.
String _toCamel(String key) {
  return key.replaceAllMapped(
    RegExp(r'_([a-z])'),
    (m) => m.group(1)!.toUpperCase(),
  );
}

/// Recursively converts all keys in a JSON map from snake_case to camelCase.
Map<String, dynamic> snakeToCamel(Map<String, dynamic> json) {
  return json.map((key, value) {
    final camelKey = _toCamel(key);
    final converted = value is Map<String, dynamic>
        ? snakeToCamel(value)
        : value;
    return MapEntry(camelKey, converted);
  });
}

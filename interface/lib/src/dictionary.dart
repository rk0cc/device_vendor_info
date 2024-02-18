import 'dart:async';

/// Emulated [String]-[String] key-value pair object for accessing entities of
/// hardware information.
///
/// This interface has similar features from unmodifiable [Map]
/// that it follows the identical workflow for accessing
/// value disregard mechanism of fetching data.
abstract interface class DeviceVendorInfoDictionary {
  /// Counts the total pairs stored in this dictionary.
  Future<int> get length;

  /// Determine this dictionary contains nothing.
  Future<bool> get isEmpty;

  /// Determine at least one pairs availabled in this
  /// dictionary.
  Future<bool> get isNotEmpty;

  /// The keys of dictionary.
  Stream<String> get keys;

  /// The values of dictionary.
  Stream<String> get values;

  /// Wrap pairs of [keys] and [values] into [MapEntry]
  /// and [Stream] them.
  Stream<MapEntry<String, String>> get entries;

  /// Find the given [key] contains in [keys].
  Future<bool> containsKey(String key);

  /// Find the given [value] contains in [values].
  Future<bool> containsValue(String value);

  /// Apply [action] for each pairs.
  Future<void> forEach(void Function(String key, String value) action);

  /// Return value which paired with [key].
  ///
  /// If the given key is not assigned with any [values],
  /// it returns `null`.
  Future<String?> operator [](String key);
}

/// Additional features for converting [DeviceVendorInfoDictionary]
/// to [Map] object.
extension DeviceVendorInfoDictionaryMapConversion
    on DeviceVendorInfoDictionary {
  /// Resemble [DeviceVendorInfoDictionary] into unmodifiable [Map] model
  /// with same keys and values.
  Future<Map<String, String>> toMap() async =>
      Map.unmodifiable(Map.fromEntries(await entries.toList()));
}

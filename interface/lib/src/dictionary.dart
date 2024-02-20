import 'dart:async';

import 'package:meta/meta.dart';

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
  Stream<Object> get values;

  /// Wrap pairs of [keys] and [values] into [MapEntry]
  /// and [Stream] them.
  Stream<MapEntry<String, Object>> get entries;

  /// Find the given [key] contains in [keys].
  Future<bool> containsKey(String key);

  /// Find the given [value] contains in [values].
  Future<bool> containsValue(String value);

  /// Apply [action] for each pairs.
  Future<void> forEach(void Function(String key, Object value) action);

  TypedDeviceVendorInfoDictionary<V> map<V extends Object>(
      MapEntry<String, V> Function(MapEntry<String, Object> entry) convert);

  DeviceVendorInfoDictionary where(
      bool Function(MapEntry<String, Object> entry) condition);

  /// Return value which paired with [key].
  ///
  /// If the given key is not assigned with any [values],
  /// it returns `null`.
  Future<Object?> operator [](String key);
}

/// Pre-defined behaviour of [DeviceVendorInfoDictionary] which
/// rest of functions are relied on [entries].
abstract base mixin class EntryBasedDeviceVendorInfoDictionary
    implements DeviceVendorInfoDictionary {
  @override
  Future<Object?> operator [](String key) async {
    try {
      return await entries
          .singleWhere((element) => element.key == key)
          .then((value) => value.value);
    } on StateError {
      return null;
    }
  }

  @override
  Future<bool> containsKey(String key) {
    return entries.any((element) => element.key == key);
  }

  @override
  Future<bool> containsValue(String value) {
    return entries.any((element) => element.value == value);
  }

  @override
  Future<void> forEach(void Function(String key, Object value) action) {
    return entries.forEach((element) => action(element.key, element.value));
  }

  @override
  TypedDeviceVendorInfoDictionary<V> map<V extends Object>(
      MapEntry<String, V> Function(MapEntry<String, Object> entry) convert) {
    return DelegatedDeviceVendorInfoDictionary(entries.map(convert));
  }

  @override
  DeviceVendorInfoDictionary where(
      bool Function(MapEntry<String, Object> entry) condition) {
    return DelegatedDeviceVendorInfoDictionary(entries.where(condition));
  }

  @override
  Future<bool> get isEmpty => entries.isEmpty;

  @override
  Future<bool> get isNotEmpty async => !await isEmpty;

  @override
  Stream<String> get keys => entries.map((event) => event.key);

  @override
  Future<int> get length => entries.length;

  @override
  Stream<Object> get values => entries.map((event) => event.value);
}

abstract final class TypedDeviceVendorInfoDictionary<V extends Object>
    implements DeviceVendorInfoDictionary {
  const TypedDeviceVendorInfoDictionary._();

  @mustBeOverridden
  @override
  Future<V?> operator [](String key);

  @mustBeOverridden
  @override
  Stream<MapEntry<String, V>> get entries;

  @mustBeOverridden
  @override
  Stream<V> get values;
}

@doNotStore
@optionalTypeArgs
final class DelegatedDeviceVendorInfoDictionary<V extends Object>
    extends EntryBasedDeviceVendorInfoDictionary
    implements TypedDeviceVendorInfoDictionary<V> {
  @override
  final Stream<MapEntry<String, V>> entries;

  DelegatedDeviceVendorInfoDictionary(this.entries);

  @override
  Future<V?> operator [](String key) async {
    try {
      return await entries
          .singleWhere((element) => element.key == key)
          .then((value) => value.value);
    } on StateError {
      return null;
    }
  }

  @override
  Stream<V> get values => entries.map((event) => event.value);
}

final class _ValueTypeCastedDeviceVendorInfoDictionary<V extends Object>
    extends EntryBasedDeviceVendorInfoDictionary
    implements TypedDeviceVendorInfoDictionary<V> {
  final DeviceVendorInfoDictionary _original;

  _ValueTypeCastedDeviceVendorInfoDictionary._(this._original);

  factory _ValueTypeCastedDeviceVendorInfoDictionary(
          DeviceVendorInfoDictionary original) =>
      _ValueTypeCastedDeviceVendorInfoDictionary._(
          original is _ValueTypeCastedDeviceVendorInfoDictionary
              ? original._original
              : original);

  @override
  Future<V?> operator [](String key) async {
    try {
      return await entries
          .singleWhere((element) => element.key == key)
          .then((value) => value.value);
    } on StateError {
      return null;
    }
  }

  @override
  Stream<MapEntry<String, V>> get entries async* {
    await for (var kv in _original.entries) {
      yield MapEntry(kv.key, kv.value as V);
    }
  }

  @override
  Stream<V> get values => entries.map((event) => event.value);
}

/// Additional features for converting [DeviceVendorInfoDictionary]
/// to [Map] object.
extension DeviceVendorInfoDictionaryMapConversion
    on DeviceVendorInfoDictionary {
  /// Resemble [DeviceVendorInfoDictionary] into unmodifiable [Map] model
  /// with same keys and values.
  Future<Map<String, Object>> toMap() async =>
      Map.unmodifiable(Map.fromEntries(await entries.toList()));
}

extension DeviceVendorInfoDictionaryTypesExtension
    on DeviceVendorInfoDictionary {
  TypedDeviceVendorInfoDictionary<V> castValue<V extends Object>() =>
      _ValueTypeCastedDeviceVendorInfoDictionary<V>(this);

  TypedDeviceVendorInfoDictionary<V> whereValueType<V extends Object>() =>
      DelegatedDeviceVendorInfoDictionary(entries
          .where((event) => event.value is V)
          .cast<MapEntry<String, V>>());
}

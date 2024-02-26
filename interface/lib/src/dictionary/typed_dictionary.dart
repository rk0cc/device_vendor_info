part of '../dictionary.dart';

/// A notation for returning [String] value of [TypedDeviceVendorInfoDictionary].
typedef StringifiedValuesDeviceVendorInfoDictionary
    = TypedDeviceVendorInfoDictionary<String>;

/// Type guarded [values] of [DeviceVendorInfoDictionary] that
/// all [values] become [V] instead of [Object] (if specified).
abstract interface class TypedDeviceVendorInfoDictionary<V extends Object>
    implements DeviceVendorInfoDictionary {
  const TypedDeviceVendorInfoDictionary._();

  @override
  Future<V?> operator [](String key);

  @override
  Stream<MapEntry<String, V>> get entries;

  @override
  Stream<V> get values;

  @override
  Future<void> forEach(void Function(String key, V value) action);
}

abstract mixin class EntryBasedTypedDeviceVendorInfoDictionary<V extends Object>
    implements
        TypedDeviceVendorInfoDictionary<V>,
        EntryBasedDeviceVendorInfoDictionary {
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
  Future<bool> containsKey(String key) {
    return entries.any((element) => element.key == key);
  }

  @override
  Future<bool> containsValue(String value) {
    return entries.any((element) => element.value == value);
  }

  @override
  Future<void> forEach(void Function(String key, V value) action) {
    return entries.forEach((element) => action(element.key, element.value));
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
  Stream<V> get values => entries.map((event) => event.value);
}

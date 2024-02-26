part of '../dictionary.dart';

/// Emulated [String] key pair object for accessing entities of
/// hardware information.
///
/// This interface has similar features from unmodifiable [Map]
/// that it follows the identical workflow for accessing
/// value disregard mechanism of fetching data.
abstract interface class DeviceVendorInfoDictionary {
  /// Wrap [DeviceVendorInfoDictionary] to notate [values] as
  /// [String].
  ///
  /// Normally, every [values] will be converted to [String] via
  /// [Object.toString]. Unless when handling a [List] of [int]
  /// with [TypedData] implemented, which denoted as bytes data that
  /// it will converted depending on current setting
  /// of [BytesStringify].
  ///
  /// This method should be call once, and the returned dictionary
  /// cannot reapply into [stringify] again. Otherwise, it throws
  /// [SameNestedDictionaryTypeError].
  @factory
  static StringifiedValuesDeviceVendorInfoDictionary stringify(
      DeviceVendorInfoDictionary dictionary,
      {BytesStringify bytesStringify = BytesStringify.hex}) {
    if (dictionary is _StringifiedValuesDeviceVendorInfoDictionary) {
      throw SameNestedDictionaryTypeError<
          StringifiedValuesDeviceVendorInfoDictionary>._();
    }

    return _StringifiedValuesDeviceVendorInfoDictionary(
        dictionary, bytesStringify);
  }

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

  /// Return value which paired with [key].
  ///
  /// If the given key is not assigned with any [values],
  /// it returns `null`.
  Future<Object?> operator [](String key);
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

/// Provides additional [DeviceVendorInfoDictionary] methods which have tha
/// same behaviours for all dictionaries.
extension AdvanceDeviceVendorInfoDictionaryMethodsExtension
    on DeviceVendorInfoDictionary {
  /// Cast all [values] to [V] and return [TypedDeviceVendorInfoDictionary],
  /// no matter the [values] is compatible with [V] or not.
  ///
  /// This method is equivalent to [Map.cast].
  TypedDeviceVendorInfoDictionary<V> castValues<V extends Object>() =>
      _ValueTypeCastedDeviceVendorInfoDictionary<V>(this);

  /// Change the original [values] to [V] which may modified during
  /// [convert].
  ///
  /// This method is equivalent to [Iterable.map] since any modification
  /// of [keys] is forbidden. Therefore, it does not based on [Map.map].
  TypedDeviceVendorInfoDictionary<V> map<V extends Object>(
          V Function(Object value) convert) =>
      _DelegatedDeviceVendorInfoDictionary(entries.map(
          (event) => MapEntry<String, V>(event.key, convert(event.value))));

  /// Perform a [test] and filter the valid [entries] into another
  /// [DeviceVendorInfoDictionary].
  ///
  /// This method is equivalent to [Iterable.where].
  DeviceVendorInfoDictionary where(
          bool Function(String key, Object value) test) =>
      _DelegatedDeviceVendorInfoDictionary(
          entries.where((event) => test(event.key, event.value)));

  /// Filter [values] with [V] type.
  ///
  /// This method is equivalent to [Iterable.whereType].
  TypedDeviceVendorInfoDictionary<V> whereTypeOfValues<V extends Object>() =>
      _ValueTypeSelectorDeviceVendorInfoDictionary<V>(this);
}

/// Pre-defined behaviour of [DeviceVendorInfoDictionary] which
/// rest of functions are relied on [entries].
abstract mixin class EntryBasedDeviceVendorInfoDictionary
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

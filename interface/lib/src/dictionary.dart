import 'dart:async';
import 'dart:io';

import 'package:flutter/foundation.dart' show TargetPlatform;
import 'package:meta/meta.dart';

@optionalTypeArgs
abstract class DeviceVendorInfoDictionaryError<
    T extends DeviceVendorInfoDictionary> extends Error {
  final String message;

  DeviceVendorInfoDictionaryError([this.message = ""]);

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf.write("DeviceVendorInfoDictionaryError");

    if (message.isNotEmpty) {
      buf
        ..write(": ")
        ..writeln(message);
    }

    buf
      ..write("Dictionary type: ")
      ..writeln(T);

    return buf.toString();
  }
}

/// [TypeError] based that the same [DeviceVendorInfoDictionary] cannot be
/// accepted as nested dictionary.
final class SameNestedDictionaryTypeError<T extends DeviceVendorInfoDictionary>
    extends DeviceVendorInfoDictionaryError<T> implements TypeError {
  SameNestedDictionaryTypeError._()
      : super("It does not accept exact same type as nested dictionary.");
}

/// Indicate the [DeviceVendorInfoDictionary] cannot be constucted
/// in [currentPlatform].
class UnsupportedDictionaryPlatformException<
    T extends DeviceVendorInfoDictionary> implements IOException {
  /// Current [TargetPlatform] when this exception thrown.
  final TargetPlatform currentPlatform;
  
  /// The eligable [TargetPlatform]s that [DeviceVendorInfoDictionary]
  /// can be constructed.
  final Iterable<TargetPlatform> appliedPlatform;

  /// Construct [UnsupportedDictionaryPlatformException] to prevent
  /// [DeviceVendorInfoDictionary] in unsupported platform.
  UnsupportedDictionaryPlatformException(this.currentPlatform,
      {bool linux = false, bool macOS = false, bool windows = false})
      : appliedPlatform = List.unmodifiable([
          if (linux) TargetPlatform.linux,
          if (macOS) TargetPlatform.macOS,
          if (windows) TargetPlatform.windows
        ]);

  @override
  String toString() {
    final StringBuffer buf = StringBuffer();

    buf
      ..write("UnsupportedDictionaryPlatformException: ")
      ..write("This dictionary only support in ")
      ..write(appliedPlatform.map((e) => e.name).join(", "))
      ..write(". But it constructed in ")
      ..write(currentPlatform.name)
      ..writeln(".");

    if (T != DeviceVendorInfoDictionary) {
      buf
        ..write("Dictionary type: ")
        ..writeln(T);
    }

    return buf.toString();
  }
}

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
  /// This method should be call once, and the returned dictionary
  /// cannot reapply into [stringify] again. Otherwise, it throws
  /// [SameNestedDictionaryTypeError].
  static StringifiedValuesDeviceVendorInfoDictionary stringify(
      DeviceVendorInfoDictionary dictionary) {
    if (dictionary is _StringifiedValuesDeviceVendorInfoDictionary) {
      throw SameNestedDictionaryTypeError<
          StringifiedValuesDeviceVendorInfoDictionary>._();
    }

    return _StringifiedValuesDeviceVendorInfoDictionary(dictionary);
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

/// Type guarded [values] of [DeviceVendorInfoDictionary] that
/// all [values] become [V] instead of [Object] (if specified).
abstract final class TypedDeviceVendorInfoDictionary<V extends Object>
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

abstract base mixin class _EntryBasedTypedDeviceVendorInfoDictionary<
        V extends Object>
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

final class _DelegatedDeviceVendorInfoDictionary<V extends Object>
    extends _EntryBasedTypedDeviceVendorInfoDictionary<V> {
  @override
  final Stream<MapEntry<String, V>> entries;

  _DelegatedDeviceVendorInfoDictionary(this.entries);
}

final class _ValueTypeCastedDeviceVendorInfoDictionary<V extends Object>
    extends _EntryBasedTypedDeviceVendorInfoDictionary<V> {
  final DeviceVendorInfoDictionary _origin;

  _ValueTypeCastedDeviceVendorInfoDictionary(DeviceVendorInfoDictionary origin)
      : _origin = origin is _ValueTypeCastedDeviceVendorInfoDictionary
            ? origin._origin
            : origin;

  @override
  Stream<MapEntry<String, V>> get entries async* {
    await for (var kv in _origin.entries) {
      yield MapEntry(kv.key, kv.value as V);
    }
  }
}

final class _ValueTypeSelectorDeviceVendorInfoDictionary<V extends Object>
    extends _EntryBasedTypedDeviceVendorInfoDictionary<V> {
  final _DelegatedDeviceVendorInfoDictionary<Object> _origin;

  _ValueTypeSelectorDeviceVendorInfoDictionary(
      DeviceVendorInfoDictionary origin)
      : _origin = _DelegatedDeviceVendorInfoDictionary(origin.entries);

  @override
  Stream<MapEntry<String, V>> get entries async* {
    await for (var kv in _origin.entries) {
      if (kv.value is V) {
        yield MapEntry(kv.key, kv.value as V);
      }
    }
  }
}

/// A notation for returned type of [DeviceVendorInfoDictionary.stringify].
@internal
typedef StringifiedValuesDeviceVendorInfoDictionary
    = TypedDeviceVendorInfoDictionary<String>;

final class _StringifiedValuesDeviceVendorInfoDictionary
    extends _EntryBasedTypedDeviceVendorInfoDictionary<String> {
  final DeviceVendorInfoDictionary _origin;

  _StringifiedValuesDeviceVendorInfoDictionary(this._origin)
      : assert(_origin is! _StringifiedValuesDeviceVendorInfoDictionary);

  @override
  Stream<MapEntry<String, String>> get entries =>
      _origin.entries.map((event) => MapEntry(event.key, "${event.value}"));
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

import 'dart:collection';

import 'package:meta/meta.dart';

import '../../bytes_conversion.dart';
import '../async/dictionary.dart';
import '../exceptions.dart';
import '../typedef.dart';
import 'adapter.dart';
import 'mock.dart';

abstract final class SyncedVendorDictionary<V> implements Map<String, V> {
  // ignore: unused_element
  const SyncedVendorDictionary._();

  factory SyncedVendorDictionary(VendorDictionary<V> dictionary) =
      VendorDictionarySyncAdapter;

  @visibleForTesting
  factory SyncedVendorDictionary.mockData(Map<String, V> mockData) =
      MockVendorDictionary;

  @override
  V operator [](Object? key);

  String toStringWithStringifyBytes(StringifyBytes method);
}

abstract base class SyncedVendorDictionaryBase<V>
    extends UnmodifiableMapBase<String, V>
    implements SyncedVendorDictionary<V> {
  SyncedVendorDictionaryBase();

  @nonVirtual
  @override
  V operator [](Object? key) {
    if (key is! String) {
      throw DictionaryKeyTypeMismatchError.singleType(String);
    }

    try {
      return entries.singleWhere((element) => element.key == key).value;
    } on StateError {
      throw UndefinedDictionaryKeyError(key);
    }
  }

  @mustBeOverridden
  @override
  Iterable<DictionaryEntry<V>> get entries;

  @override
  Iterable<String> get keys => entries.map((e) => e.key);

  @override
  Iterable<V> get values => entries.map((e) => e.value);

  @nonVirtual
  @override
  String toStringWithStringifyBytes(StringifyBytes method) {
    final Iterable<String> pair = entries.map((e) {
      var DictionaryEntry(key: k, value: v) = e;

      final StringBuffer buf = StringBuffer()
        ..write(k)
        ..write(": ");

      if (v is List<int>) {
        buf.write(v.toStringifyBytes(method));
      } else {
        buf.write(v);
      }

      return buf.toString();
    });

    return "{${pair.join(", ")}}";
  }

  @override
  String toString() {
    return toStringWithStringifyBytes(StringifyBytes.upperHexadecimal);
  }
}

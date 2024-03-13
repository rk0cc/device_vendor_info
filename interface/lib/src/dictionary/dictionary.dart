import 'dart:collection';
import 'dart:io';
import 'dart:typed_data';

import 'cast.dart';
import 'exceptions.dart';
import 'map.dart';
import 'selector.dart';
import 'stream.dart';
import 'typedef.dart';

/// Concurrent structures with [Map]-liked API that to obtains
/// device vendor informations.
///
/// The guideline of [values] type [V] should be followed in this list:
///
/// * If some [values] represents as binary, please assign them with
///   [TypedData] implemented data type.
/// * The ideal [values] type should be Dart's primitive type (e.g. [int],
///   [String] and [bool]) along with [List].
abstract interface class VendorDictionary<V> {
  /// Construct *ad hoc* [VendorDictionary] that relys on [generator]
  /// for one uses purpose.
  factory VendorDictionary.instant(EntriesStreamGenerator<V> generator) =
      _InstantVendorDictionary;

  /// Emulate [VendorDictionary] behaviours from [Map] by simply
  /// creating [VendorDictionary.instant] and yield all [Map.entries]
  /// contents.
  factory VendorDictionary.fromMap(Map<String, V> map) =>
      VendorDictionary.instant(() async* {
        for (var DictionaryEntry(key: k, value: v) in map.entries) {
          yield (k, v);
        }
      });

  /// A collection of [DictionaryEntry] contains in this
  /// dictionary.
  VendorDictionaryEntriesStream<V> get entries;

  /// Streaming all available keys from [entries].
  Stream<String> get keys;

  /// Streaming all values stores in [entries], which
  /// can be duplicated.
  Stream<V> get values;

  /// Length of [DictionaryEntry] stored in this dictionary.
  Future<int> get length;

  /// Determine this dictionary contains nothing.
  Future<bool> get isEmpty;

  /// Determine at least one elements stored in this dictionary.
  Future<bool> get isNotEmpty;

  /// Find at least one [entries] satisified [condition].
  Future<bool> any(bool Function(String key, V value) condition);

  /// Cast value type [V] to [RV], whatever the [values] is associate
  /// or not.
  VendorDictionary<RV> cast<RV>();

  /// Determine it has **unique** record of the [key].
  ///
  /// It returns `false` if no [key] assigned or found with
  /// duplicated [entries].
  Future<bool> containsKey(String key);

  /// Determine at least one [value] found in [entries].
  Future<bool> containsValue(V value);

  /// Find every [entries] is satified [condition].
  Future<bool> every(bool Function(String key, V value) condition);

  /// Apply [action] to execute every [entries].
  Future<void> forEach(void Function(String key, V value) action);

  /// [convert] each [values] to [RV] as well as modifying [keys].
  VendorDictionary<RV> map<RV>(
      DictionaryEntry<RV> Function(String key, V value) convert);

  /// Filter [entries] with matched [condition].
  VendorDictionary<V> where(bool Function(String key, V value) condition);

  /// Filter [entries] if [values] type is [RV].
  VendorDictionary<RV> whereValueType<RV>();

  /// Obtains [values] associated with [key].
  ///
  /// If the given [key] causes [containsKey] returns
  /// `false`, it must throws [InvalidDictionaryKeyError].
  Future<V> operator [](String key);
}

/// Predefined functions of [VendorDictionary] that it only requires
/// to implement [entries].
abstract base class VendorDictionaryBase<V> implements VendorDictionary<V> {
  const VendorDictionaryBase();

  @override
  Stream<String> get keys => entries.map((event) => event.key);

  @override
  Stream<V> get values => entries.map((event) => event.value);

  @override
  Future<bool> get isEmpty async => await length == 0;

  @override
  Future<bool> get isNotEmpty async => await length != 0;

  @override
  Future<int> get length => entries.length;

  @override
  Future<bool> any(bool Function(String key, V value) condition) {
    return entries.any((element) => condition(element.key, element.value));
  }

  @override
  Future<bool> containsKey(String key) async {
    try {
      await entries.singleWhere((element) => element.key == key);
      return true;
    } on StateError {
      return false;
    }
  }

  @override
  Future<bool> containsValue(V value) {
    return any((k, v) => v == value);
  }

  @override
  Future<bool> every(bool Function(String key, V value) condition) {
    return entries.every((element) => condition(element.key, element.value));
  }

  @override
  Future<void> forEach(void Function(String key, V value) action) async {
    await for (var DictionaryEntry(key: k, value: v) in entries) {
      action(k, v);
    }
  }

  @override
  VendorDictionary<RV> cast<RV>() {
    return CastVendorDictionary<V, RV>(this);
  }

  @override
  VendorDictionary<RV> map<RV>(
      DictionaryEntry<RV> Function(String key, V value) convert) {
    return MapVendorDictionary<V, RV>(this, convert);
  }

  @override
  VendorDictionary<V> where(bool Function(String key, V value) condition) {
    return VendorDictionarySelector(this, condition);
  }

  @override
  VendorDictionary<RV> whereValueType<RV>() {
    return VendorDictionaryTypedSelector<RV>(this);
  }

  @override
  Future<V> operator [](String key) async {
    await for (DictionaryEntry<V> de in entries) {
      if (de.key == key) {
        return de.value;
      }
    }

    throw InvalidDictionaryKeyError(
        key, "No corresponded entry found with associated key.");
  }
}

final class _InstantVendorDictionary<V> extends VendorDictionaryBase<V> {
  @override
  final VendorDictionaryEntriesStream<V> entries;

  _InstantVendorDictionary(EntriesStreamGenerator<V> generator)
      : entries = VendorDictionaryEntriesStream(generator);
}

/// Unmodifiable [Map] version of [VendorDictionary] that all values
/// no longer formed as [Future] with `await` requires.
final class SyncedVendorDictionary<V> extends UnmodifiableMapBase<String, V> {
  final int _length;
  final Map<String, V> _map;

  SyncedVendorDictionary._(this._map, this._length);

  void _checkKeyType(Object? key) {
    if (key is! String) {
      throw DictionaryKeyTypeMismatchError.singleType(String);
    }
  }

  /// Get corresponded [values], which associated with [key].
  ///
  /// Unlike [Map] will return [Null] when no value paired with [key],
  /// it throws [InvalidDictionaryKeyError].
  ///
  /// In additions, the [key] must be [String] type, applying other types
  /// will throw [DictionaryKeyTypeMismatchError].
  @override
  V operator [](Object? key) {
    _checkKeyType(key);

    if (!containsKey(key)) {
      throw InvalidDictionaryKeyError(key as String,
          "No value found that it associated with the given key.");
    }

    return entries.singleWhere((element) => element.key == key).value;
  }

  @override
  int get length => _length;

  @override
  Iterable<DictionaryEntry<V>> get entries => _map.entries;

  @override
  Iterable<String> get keys => entries.map((e) => e.key);

  @override
  Iterable<V> get values => entries.map((e) => e.value);

  @override
  bool containsKey(Object? key) {
    _checkKeyType(key);
    return super.containsKey(key);
  }
}

/// An extension to convert [VendorDictionary], which operate asynchronously
/// to [Future] wrapped [SyncedVendorDictionary].
extension VendorDictionarySynchronizer<V> on VendorDictionary<V> {
  /// Obtain [UnmodifiableMapBase], synced [VendorDictionary] with
  /// exact same key-value pair stored in this dictionary.
  ///
  /// By default, it should be returned unsorted [Map] based
  /// [SyncedVendorDictionary]. To enable sorting order of [Map],
  /// [sortEntries] should be defined, unless it called during testing
  /// which will be sorted by [VendorDictionary.keys].
  Future<SyncedVendorDictionary<V>> toSynced(
      {Comparator<DictionaryEntry<V>>? sortEntries}) async {
    final List<DictionaryEntry<V>> syncedEntries = await entries.toList();
    late final Map<String, V> syncedMap;

    if (sortEntries != null ||
        Platform.environment.containsKey("FLUTTER_TEST")) {
      syncedEntries.sort(sortEntries ?? _keySort);
      syncedMap = LinkedHashMap();
    } else {
      syncedMap = HashMap();
    }

    syncedMap.addEntries(syncedEntries);

    return SyncedVendorDictionary._(syncedMap, syncedEntries.length);
  }
}

int _keySort<V>(DictionaryEntry<V> a, DictionaryEntry<V> b) =>
    a.key.compareTo(b.key);

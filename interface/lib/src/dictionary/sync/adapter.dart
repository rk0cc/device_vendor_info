import 'dart:collection';

import 'package:meta/meta.dart';

import '../async/dictionary.dart' show VendorDictionary;
import '../typedef.dart';
import 'dictionary.dart';

@internal
final class VendorDictionarySyncAdapter<V>
    extends SyncedVendorDictionaryBase<V> {
  late final int _length;
  late final HashMap<String, V> _map;

  VendorDictionarySyncAdapter(VendorDictionary<V> dictionary) {
    _syncToMap(dictionary);
  }

  /// Sync all properties and elements in [VendorDictionary]
  /// into [Future]-resolved types.
  void _syncToMap(VendorDictionary<V> dictionary) async {
    _length = await dictionary.length;
    _map = HashMap();

    // Do not uses forEach to implement that it may uses differ workflow
    await for (var DictionaryEntry(key: k, value: v) in dictionary.entries) {
      _map[k] = v;
    }
  }

  @override
  int get length => _length;

  @override
  Iterable<DictionaryEntry<V>> get entries => _map.entries;
}
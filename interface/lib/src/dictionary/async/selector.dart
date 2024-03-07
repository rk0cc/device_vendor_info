import 'package:meta/meta.dart';

import '../typedef.dart';
import 'collections.dart';
import 'dictionary.dart';

final class _VendorDictionaryCollectionSelector<V>
    extends VendorDictionaryCollectionBase<V> {
  final bool Function(String key, V value) condition;
  final VendorDictionaryCollection<V> soruce;

  _VendorDictionaryCollectionSelector(this.soruce, this.condition);

  @override
  Stream<DictionaryEntry<V>> generator() async* {
    await for (var DictionaryEntry(key: k, value: v) in soruce) {
      if (condition(k, v)) {
        yield DictionaryEntry(k, v);
      }
    }
  }
}

final class _VendorDictionaryCollectionTypedSelector<RV>
    extends VendorDictionaryCollectionBase<RV> {
  final VendorDictionaryCollection<Object?> soruce;

  _VendorDictionaryCollectionTypedSelector(this.soruce);

  @override
  Stream<DictionaryEntry<RV>> generator() async* {
    await for (var DictionaryEntry(key: k, value: v) in soruce) {
      if (v is RV) {
        yield DictionaryEntry(k, v);
      }
    }
  }
}

@internal
final class VendorDictionarySelector<V> extends VendorDictionaryBase<V> {
  final _VendorDictionaryCollectionSelector<V> _entries;

  VendorDictionarySelector(VendorDictionary<V> dictionary,
      bool Function(String key, V value) condition)
      : _entries =
            _VendorDictionaryCollectionSelector(dictionary.entries, condition);

  @override
  VendorDictionaryCollection<V> get entries => _entries;
}

@internal
final class VendorDictionaryTypedSelector<RV> extends VendorDictionaryBase<RV> {
  final _VendorDictionaryCollectionTypedSelector<RV> _entries;

  VendorDictionaryTypedSelector(VendorDictionary<Object?> dictionary)
      : _entries = _VendorDictionaryCollectionTypedSelector(dictionary.entries);

  @override
  VendorDictionaryCollection<RV> get entries => _entries;
}

import 'package:meta/meta.dart';

import '../typedef.dart';
import 'stream.dart';
import 'dictionary.dart';

final class _VendorDictionaryEntriesStreamSelector<V>
    extends VendorDictionaryEntriesStreamBase<V> {
  final bool Function(String key, V value) condition;
  final VendorDictionaryEntriesStream<V> source;

  _VendorDictionaryEntriesStreamSelector(this.source, this.condition);

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<V> add,
      DictionaryEntryStreamThrower addError) async {
    try {
      await for (var DictionaryEntry(key: k, value: v) in source) {
        if (condition(k, v)) {
          add(k, v);
        }
      }
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }
}

final class _VendorDictionaryEntriesStreamTypedSelector<RV>
    extends VendorDictionaryEntriesStreamBase<RV> {
  final VendorDictionaryEntriesStream<Object?> source;

  _VendorDictionaryEntriesStreamTypedSelector(this.source);

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<RV> add,
      DictionaryEntryStreamThrower addError) async {
    try {
      await for (var DictionaryEntry(key: k, value: v) in source) {
        if (v is RV) {
          add(k, v);
        }
      }
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }
}

@internal
final class VendorDictionarySelector<V> extends VendorDictionaryBase<V> {
  final _VendorDictionaryEntriesStreamSelector<V> _entries;

  VendorDictionarySelector(VendorDictionary<V> dictionary,
      bool Function(String key, V value) condition)
      : _entries = _VendorDictionaryEntriesStreamSelector(
            dictionary.entries, condition);

  @override
  VendorDictionaryEntriesStream<V> get entries => _entries;
}

@internal
final class VendorDictionaryTypedSelector<RV> extends VendorDictionaryBase<RV> {
  final _VendorDictionaryEntriesStreamTypedSelector<RV> _entries;

  VendorDictionaryTypedSelector(VendorDictionary<Object?> dictionary)
      : _entries =
            _VendorDictionaryEntriesStreamTypedSelector(dictionary.entries);

  @override
  VendorDictionaryEntriesStream<RV> get entries => _entries;
}

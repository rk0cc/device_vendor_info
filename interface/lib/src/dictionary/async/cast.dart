import 'package:meta/meta.dart';

import '../typedef.dart';
import 'stream.dart';
import 'dictionary.dart';

final class _CastVendorDictionaryEntriesStream<SV, RV>
    extends VendorDictionaryEntriesStreamBase<RV> {
  final VendorDictionaryEntriesStream<SV> origin;

  _CastVendorDictionaryEntriesStream(this.origin);

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<RV> add,
      DictionaryEntryStreamThrower addError) async {
    try {
      await for (var DictionaryEntry(key: k, value: v) in origin) {
        add(k, v as RV);
      }
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }
}

@internal
final class CastVendorDictionary<SV, RV> extends VendorDictionaryBase<RV> {
  final _CastVendorDictionaryEntriesStream<SV, RV> _entries;

  CastVendorDictionary._(VendorDictionaryEntriesStream<SV> origin)
      : _entries = _CastVendorDictionaryEntriesStream(origin);

  factory CastVendorDictionary(VendorDictionary<SV> dictionary) =>
      CastVendorDictionary._(dictionary.entries);

  @override
  VendorDictionary<NRV> cast<NRV>() {
    return CastVendorDictionary<SV, NRV>._(_entries.origin);
  }

  @override
  VendorDictionaryEntriesStream<RV> get entries => _entries;
}

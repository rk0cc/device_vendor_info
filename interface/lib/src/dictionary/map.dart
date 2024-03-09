import 'package:meta/meta.dart';

import 'typedef.dart';
import 'stream.dart';
import 'dictionary.dart';

final class _VendorDictionaryEntriesStreamMapper<SV, RV>
    extends VendorDictionaryEntriesStreamBase<RV> {
  final VendorDictionaryEntriesStream<SV> source;
  final DictionaryEntry<RV> Function(String key, SV value) convert;

  _VendorDictionaryEntriesStreamMapper(this.source, this.convert);

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<RV> add,
      DictionaryEntryStreamThrower addError) async {
    try {
      await for (var DictionaryEntry<SV>(key: k, value: v) in source) {
        var DictionaryEntry<RV>(key: nk, value: nv) = convert(k, v);
        add(nk, nv);
      }
    } catch (err, stackTrace) {
      addError(err, stackTrace);
    }
  }
}

@internal
final class MapVendorDictionaryCollection<SV, RV>
    extends VendorDictionaryBase<RV> {
  final _VendorDictionaryEntriesStreamMapper<SV, RV> _entries;

  MapVendorDictionaryCollection(VendorDictionary<SV> dictionary,
      DictionaryEntry<RV> Function(String key, SV value) convert)
      : _entries =
            _VendorDictionaryEntriesStreamMapper(dictionary.entries, convert);

  @override
  VendorDictionaryEntriesStream<RV> get entries => _entries;
}

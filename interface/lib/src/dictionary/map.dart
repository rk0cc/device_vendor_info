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

/// Apply [values] conversion to another object with completely difference
/// [values] type.
@internal
final class MapVendorDictionary<SV, RV>
    extends VendorDictionaryBase<RV> {
  final _VendorDictionaryEntriesStreamMapper<SV, RV> _entries;

  /// Create new [MapVendorDictionary] and [convert] to ideal [values]
  /// in [RV] type as well as alter [keys].
  MapVendorDictionary(VendorDictionary<SV> dictionary,
      DictionaryEntry<RV> Function(String key, SV value) convert)
      : _entries =
            _VendorDictionaryEntriesStreamMapper(dictionary.entries, convert);

  @override
  VendorDictionaryEntriesStream<RV> get entries => _entries;
}

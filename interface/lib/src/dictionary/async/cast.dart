import 'package:meta/meta.dart';

import '../typedef.dart';
import 'collections.dart';
import 'dictionary.dart';

final class _CastVendorDictionaryCollection<SV, RV>
    extends VendorDictionaryCollectionBase<RV> {
  final VendorDictionaryCollection<SV> origin;

  _CastVendorDictionaryCollection(this.origin);

  @override
  Stream<DictionaryEntry<RV>> generator() async* {
    await for (var DictionaryEntry(key: k, value: v) in origin) {
      yield DictionaryEntry(k, v as RV);
    }
  }
}

@internal
final class CastVendorDictionary<SV, RV> extends VendorDictionaryBase<RV> {
  final _CastVendorDictionaryCollection<SV, RV> _entries;

  CastVendorDictionary._(VendorDictionaryCollection<SV> origin)
      : _entries = _CastVendorDictionaryCollection(origin);

  factory CastVendorDictionary(VendorDictionary<SV> dictionary) =>
      CastVendorDictionary._(dictionary.entries);

  @override
  VendorDictionary<NRV> cast<NRV>() {
    return CastVendorDictionary<SV, NRV>._(_entries.origin);
  }

  @override
  VendorDictionaryCollection<RV> get entries => _entries;
}

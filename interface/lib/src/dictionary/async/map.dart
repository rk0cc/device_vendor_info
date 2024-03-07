import 'package:meta/meta.dart';

import '../typedef.dart';
import 'collections.dart';
import 'dictionary.dart';

final class _VendorDictionaryCollectionMapper<SV, RV>
    extends VendorDictionaryCollectionBase<RV> {
  final VendorDictionaryCollection<SV> source;
  final DictionaryEntry<RV> Function(String key, SV value) convert;

  _VendorDictionaryCollectionMapper(this.source, this.convert);

  @override
  Stream<DictionaryEntry<RV>> generator() {
    return source.map((event) => convert(event.key, event.value));
  }
}

@internal
final class MapVendorDictionaryCollection<SV, RV> extends VendorDictionaryBase<RV> {
  final _VendorDictionaryCollectionMapper<SV, RV> _entries;

  MapVendorDictionaryCollection(VendorDictionary<SV> dictionary, DictionaryEntry<RV> Function(String key, SV value) convert)
    : _entries = _VendorDictionaryCollectionMapper(dictionary.entries, convert);

  @override
  VendorDictionaryCollection<RV> get entries => _entries;
}

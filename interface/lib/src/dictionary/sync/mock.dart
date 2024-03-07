import 'package:meta/meta.dart';

import '../typedef.dart';
import 'dictionary.dart';

@internal
final class MockVendorDictionary<V> extends SyncedVendorDictionaryBase<V> {
  final Map<String, V> _mockMap;

  MockVendorDictionary(Map<String, V> mockMap)
      : _mockMap = Map.unmodifiable(mockMap);

  @override
  Iterable<DictionaryEntry<V>> get entries => _mockMap.entries;

  @override
  int get length => _mockMap.length;
}
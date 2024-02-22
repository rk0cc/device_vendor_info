part of '../../dictionary.dart';

final class _DelegatedDeviceVendorInfoDictionary<V extends Object>
    extends EntryBasedTypedDeviceVendorInfoDictionary<V> {
  @override
  final Stream<MapEntry<String, V>> entries;

  _DelegatedDeviceVendorInfoDictionary(this.entries);
}

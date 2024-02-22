part of '../../dictionary.dart';

final class _ValueTypeSelectorDeviceVendorInfoDictionary<V extends Object>
    extends EntryBasedTypedDeviceVendorInfoDictionary<V> {
  final _DelegatedDeviceVendorInfoDictionary<Object> _origin;

  _ValueTypeSelectorDeviceVendorInfoDictionary(
      DeviceVendorInfoDictionary origin)
      : _origin = _DelegatedDeviceVendorInfoDictionary(origin.entries);

  @override
  Stream<MapEntry<String, V>> get entries async* {
    await for (var kv in _origin.entries) {
      if (kv.value is V) {
        yield MapEntry(kv.key, kv.value as V);
      }
    }
  }
}
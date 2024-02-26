part of '../../dictionary.dart';

final class _ValueTypeCastedDeviceVendorInfoDictionary<V extends Object>
    extends EntryBasedTypedDeviceVendorInfoDictionary<V> {
  final DeviceVendorInfoDictionary _origin;

  _ValueTypeCastedDeviceVendorInfoDictionary(DeviceVendorInfoDictionary origin)
      : _origin = origin is _ValueTypeCastedDeviceVendorInfoDictionary
            ? origin._origin
            : origin;

  @override
  Stream<MapEntry<String, V>> get entries async* {
    await for (var kv in _origin.entries) {
      yield MapEntry(kv.key, kv.value as V);
    }
  }
}

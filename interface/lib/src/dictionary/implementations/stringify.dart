part of '../../dictionary.dart';

final class _StringifiedValuesDeviceVendorInfoDictionary
    extends EntryBasedTypedDeviceVendorInfoDictionary<String> {
  final DeviceVendorInfoDictionary _origin;

  _StringifiedValuesDeviceVendorInfoDictionary(this._origin)
      : assert(_origin is! _StringifiedValuesDeviceVendorInfoDictionary);

  @override
  Stream<MapEntry<String, String>> get entries => _origin.entries.map((event) {
        var v = event.value;
        late String vStr;

        if (v is List<int>) {
          if (v is TypedData) {
            final String typeName = RegExp(r"(?:(?:u?int)|float)(?:8|16|32|64)",
                    caseSensitive: false)
                .firstMatch("${v.runtimeType}")![0]!;
            vStr = "$typeName<${v.join(" ")}>";
          } else {
            vStr = "$v";
          }
        } else {
          vStr = "$v";
        }

        return MapEntry(event.key, vStr);
      });
}
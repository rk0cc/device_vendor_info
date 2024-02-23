part of '../../dictionary.dart';

/// Determine the display format for each bytes notated in [int].
enum BytesDisplayFormat {
  dec(10),
  hex(16);

  final int radix;

  const BytesDisplayFormat(this.radix);
}

extension on BytesDisplayFormat {
  String format(List<int> bytes) {
    Iterable<String> formatted =
        bytes.map((e) => e.toRadixString(radix).toUpperCase());

    switch (this) {
      case BytesDisplayFormat.hex:
        final int maxBytes = bytes.reduce(math.max);
        int byteHexGroupLength = 1;

        while (maxBytes >= math.pow(16, byteHexGroupLength)) {
          byteHexGroupLength *= 2;
        }

        formatted = formatted.map((e) => e.padLeft(byteHexGroupLength));
        break;
      default:
        break;
    }

    return formatted.join(" ");
  }
}

final class _StringifiedValuesDeviceVendorInfoDictionary
    extends EntryBasedTypedDeviceVendorInfoDictionary<String> {
  final DeviceVendorInfoDictionary _origin;
  final BytesDisplayFormat bytesFormat;

  _StringifiedValuesDeviceVendorInfoDictionary(this._origin, this.bytesFormat)
      : assert(_origin is! _StringifiedValuesDeviceVendorInfoDictionary);

  String _handleIntList(List<int> intList) {
    if (intList is TypedData) {
      final String typeName =
          RegExp(r"(?:(?:u?int)|float)(?:8|16|32|64)", caseSensitive: false)
              .firstMatch("${intList.runtimeType}")![0]!;

      return "$typeName<${bytesFormat.format(intList)}>";
    }

    return "$intList";
  }

  @override
  Stream<MapEntry<String, String>> get entries => _origin.entries.map((event) {
        var v = event.value;
        late String vStr;

        if (v is List<int>) {
          vStr = _handleIntList(v);
        } else {
          vStr = "$v";
        }

        return MapEntry(event.key, vStr);
      });
}

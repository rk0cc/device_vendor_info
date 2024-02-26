part of '../../dictionary.dart';

/// Determine applied rules when stringifying [TypedData] as a [List]
/// of [int] form.
enum BytesStringify {
  /// Display decimal number with spaced between byte value.
  dec(_RadixBytesStringifier(10)),

  /// Display hexadecimal with `0x` as prefix.
  ///
  /// When the convered bytes is negative, the negative sign will
  /// be appeared at first (e.g. `-0xA`).
  hex(_HexBytesStringifier());

  final _BytesStringifier _stringifier;

  /// Apply stringify rules with stringifier.
  const BytesStringify(this._stringifier);
}

sealed class _BytesStringifier {
  const _BytesStringifier();

  String stringify(List<int> bytes);
}

final class _RadixBytesStringifier extends _BytesStringifier {
  final int radix;

  const _RadixBytesStringifier(this.radix);

  @mustCallSuper
  @protected
  String stringifyByte(int byte, int maxMag) {
    return byte.toRadixString(radix);
  }

  @nonVirtual
  @override
  String stringify(List<int> bytes) {
    final int maxMag = bytes.map((e) => e.abs()).reduce(math.max);

    return bytes.map((e) => stringifyByte(e, maxMag).toUpperCase()).join(" ");
  }
}

final class _HexBytesStringifier extends _RadixBytesStringifier {
  const _HexBytesStringifier() : super(16);

  @override
  String stringifyByte(int byte, int maxMag) {
    int binLength = 4;
    while (maxMag >= math.pow(2, binLength)) {
      binLength *= 2;
    }

    final String result =
        super.stringifyByte(byte, maxMag).replaceFirst(r"-", "");

    final StringBuffer buf = StringBuffer();

    if (byte < 0) {
      buf.write("-");
    }

    buf
      ..write("0x")
      ..write(result.padLeft(binLength ~/ 4, "0"));

    return buf.toString();
  }
}

final class _StringifiedValuesDeviceVendorInfoDictionary
    extends EntryBasedTypedDeviceVendorInfoDictionary<String> {
  final DeviceVendorInfoDictionary _origin;
  final BytesStringify bytesStringify;

  _StringifiedValuesDeviceVendorInfoDictionary(
      this._origin, this.bytesStringify)
      : assert(_origin is! _StringifiedValuesDeviceVendorInfoDictionary);

  String _handleIntList(List<int> intList) {
    if (intList is TypedData) {
      return bytesStringify._stringifier.stringify(intList);
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

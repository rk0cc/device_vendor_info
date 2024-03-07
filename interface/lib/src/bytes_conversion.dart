import 'dart:math' as math hide MutableRectangle, Random, Point, Rectangle;
import 'dart:typed_data';

import 'package:meta/meta.dart';

/// A preference for converting bytes, which is a [List] of [int]
/// with [TypedData] implemented value.
///
/// The notation of bytes will be wrapped in angle bracket and containing
/// numerous of bytes value in [int].
///
/// ```dart
/// "<1 4 43 143 -29 86>" // Decimal
/// "<0x00F3 0x34F0 -0x0002>" // Hexadecimal
/// ```
///
/// When stringify bytes in [lowerHexadecimal] or [upperHexadecimal],
/// the notations always formed with `0x` prefix and length of hexadecimal
/// value must be `2^n` where `n` is the maximum length of hexadecimal value
/// that allowing the maximum magnitude of byte value can be displayed within
/// `2^n` standard.
///
/// ```dart
/// [256, 255] // These will be converted to <0x0100 0x00FF>
/// [0x100, 0XFF] // Same rule applied form above
/// ```
enum StringifyBytes {
  /// Stringify bytes to decimal value.
  decimal(_DecimalStringifier()),

  /// Stringify bytes to hexadecimal value and display
  /// letters in [String.toLowerCase].
  lowerHexadecimal(_HexadecimalStringifier(false)),

  /// Stringify bytes to hexadecimal value and display
  /// letters in [String.toUpperCase].
  upperHexadecimal(_HexadecimalStringifier(true));

  final _BytesStringifier _stringifier;

  const StringifyBytes(this._stringifier);
}

@visibleForTesting
extension StringifyBytesConverter on StringifyBytes {
  String convert(List<int> bytes) => _stringifier.stringify(bytes);
}

sealed class _BytesStringifier {
  const _BytesStringifier();

  String _byteToString(bool negative, int magnitude, int maxMag);

  @nonVirtual
  String stringify(List<int> bytes) {
    assert(bytes is TypedData, "Bytes must be implemented TypedData already.");

    final int maxMag = bytes.map((e) => e < 0 ? e * -1 : e).reduce(math.max);
    final ctx = bytes.map((e) {
      final bool negative = e < 0;

      return _byteToString(negative, negative ? e * -1 : e, maxMag);
    }).join(" ");

    return "<$ctx>";
  }
}

final class _DecimalStringifier extends _BytesStringifier {
  const _DecimalStringifier();

  @override
  String _byteToString(bool negative, int magnitude, int maxMag) {
    final StringBuffer buf = StringBuffer();

    if (negative) {
      buf.write(r"-");
    }

    buf.write(magnitude.toRadixString(10));

    return buf.toString();
  }
}

final class _HexadecimalStringifier extends _BytesStringifier {
  final bool uppercase;

  const _HexadecimalStringifier(this.uppercase);

  @override
  String _byteToString(bool negative, int magnitude, int maxMag) {
    int bytesLength = 2;
    while (maxMag >= math.pow(2, 4 * bytesLength)) {
      bytesLength *= 2;
    }

    final StringBuffer buf = StringBuffer();

    if (negative) {
      buf.write(r"-");
    }

    buf.write(r"0x");

    final String magRadixStr =
        magnitude.toRadixString(16).padLeft(bytesLength, r"0");

    buf.write(
        uppercase ? magRadixStr.toUpperCase() : magRadixStr.toLowerCase());

    return buf.toString();
  }
}

extension BytesStringifyExtension on List<int> {
  String toStringifyBytes(StringifyBytes method) {
    return this is TypedData ? method.convert(this) : toString();
  }
}

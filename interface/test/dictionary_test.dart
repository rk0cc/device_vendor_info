import 'dart:convert';
import 'dart:typed_data';

import 'package:device_vendor_info_interface/release.dart';
import 'package:enough_convert/big5.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

final class _IteratedEntriesTester extends IteratedFutureDictionaryEntries {
  final Map<String, Object> origin;

  _IteratedEntriesTester(this.origin);

  @override
  Iterator<FutureDictionaryEntry<Object>> get iterator => origin.entries
      .map((e) => MapEntry(e.key, Future.value(e.value)))
      .iterator;
}

base class DeviceVendorInfoDictionaryTester extends DeviceVendorInfoDictionary {
  @override
  final IteratedFutureDictionaryEntries<Object> entries;

  DeviceVendorInfoDictionaryTester(Map<String, Object> dictionary)
      : entries = _IteratedEntriesTester(dictionary);

  factory DeviceVendorInfoDictionaryTester.fromIterable(
          Iterable<Object> values) =>
      DeviceVendorInfoDictionaryTester(<String, Object>{
        for (var (idx, value) in values.indexed) "$idx": value
      });
}

enum BytesSystem { uint8, uint16, uint32, uint64 }

extension on BytesSystem {
  List<int> convertToTypedData(List<int> bytes) => switch (this) {
        BytesSystem.uint8 => Uint8List.fromList(bytes),
        BytesSystem.uint16 => Uint16List.fromList(bytes),
        BytesSystem.uint32 => Uint32List.fromList(bytes),
        BytesSystem.uint64 => Uint64List.fromList(bytes)
      };
}

const Map<String, BytesSystem> encodingBytesSystem = {
  "": BytesSystem.uint16,
  "utf-8": BytesSystem.uint8,
  "Big5": BytesSystem.uint8
};

final class _SingleBytesIterable
    extends IteratedFutureDictionaryEntries<List<int>> {
  final List<int> bytes;

  _SingleBytesIterable(this.bytes) : assert(bytes is TypedData);

  @override
  Iterator<FutureDictionaryEntry<List<int>>> get iterator =>
      [MapEntry("bytes", Future.value(bytes))].iterator;
}

base class ByteDeviceVendorInfoDictionaryTester
    extends DeviceVendorInfoDictionary<List<int>> {
  @override
  final IteratedFutureDictionaryEntries<List<int>> entries;

  ByteDeviceVendorInfoDictionaryTester(List<int> bytes)
      : entries = _SingleBytesIterable(bytes);

  factory ByteDeviceVendorInfoDictionaryTester.fromString(String str,
      {Encoding? encoding}) {
    final List<int> bytes = encoding?.encode(str) ?? str.codeUnits;
    final BytesSystem system = encodingBytesSystem[encoding?.name ?? ""]!;

    return ByteDeviceVendorInfoDictionaryTester(
        system.convertToTypedData(bytes));
  }
}

@immutable
final class StringifiedByteResult {
  final String dec;
  final String hex;

  const StringifiedByteResult({required this.dec, required this.hex});
}

const Map<String, StringifiedByteResult> expectedResult = {
  "": StringifiedByteResult(
      dec: "31684 83 97 109 112 108 101 32 116 101 120 116 26412",
      hex:
          "0x7BC4 0x0053 0x0061 0x006D 0x0070 0x006C 0x0065 0x0020 0x0074 0x0065 0x0078 0x0074 0x672C"),
  "utf-8": StringifiedByteResult(
      dec: "231 175 132 83 97 109 112 108 101 32 116 101 120 116 230 156 172",
      hex:
          "0xE7 0xAF 0x84 0x53 0x61 0x6D 0x70 0x6C 0x65 0x20 0x74 0x65 0x78 0x74 0xE6 0x9C 0xAC"),
  "Big5": StringifiedByteResult(
      dec: "189 100 83 97 109 112 108 101 32 116 101 120 116 165 187",
      hex:
          "0xBD 0x64 0x53 0x61 0x6D 0x70 0x6C 0x65 0x20 0x74 0x65 0x78 0x74 0xA5 0xBB")
};

void strBytesTester(Encoding? encoding) {
  final syncedTester = ByteDeviceVendorInfoDictionaryTester.fromString(
          "範Sample text本",
          encoding: encoding)
      .toSyncedValuesDictionary();
  final StringifiedByteResult result = expectedResult[encoding?.name ?? ""]!;

  test("decimal", () {
    syncedTester.stringifyBytes = StringifyBytes.decimal;
    expect(syncedTester.toString(), equals("{bytes:<${result.dec}>}"));
  });

  test("hexadecimal", () {
    syncedTester.stringifyBytes = StringifyBytes.upperHexadecimal;
    expect(syncedTester.toString(), equals("{bytes:<${result.hex}>}"));
  });
}

void main() {
  group("Stringify bytes", () {
    group("in Dart code unit", () => strBytesTester(null));
    group("in UTF-8", () => strBytesTester(utf8));
    group("in Big 5", () => strBytesTester(big5));
  });
}

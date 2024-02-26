import 'dart:convert';
import 'dart:typed_data';

import 'package:device_vendor_info_interface/mock.dart'
    show overrideCorrectTargetPlatform;
import 'package:device_vendor_info_interface/release.dart'
    show
        DeviceVendorInfoDictionary,
        EntryBasedDeviceVendorInfoDictionary,
        TypedDeviceVendorInfoDictionary,
        EntryBasedTypedDeviceVendorInfoDictionary;
import 'package:enough_convert/big5.dart';
import 'package:flutter/foundation.dart' hide immutable;
import 'package:flutter_test/flutter_test.dart';
import 'package:meta/meta.dart';

class DeviceVendorInfoDictionaryTester
    extends EntryBasedDeviceVendorInfoDictionary {
  @override
  final Stream<MapEntry<String, Object>> entries;

  DeviceVendorInfoDictionaryTester(Map<String, Object> dictionary)
      : entries = Stream.fromIterable(dictionary.entries);

  factory DeviceVendorInfoDictionaryTester.fromIterable(
          Iterable<Object> values) =>
      DeviceVendorInfoDictionaryTester(<String, Object>{
        for (var (idx, value) in values.indexed) "$idx": value
      });
}

class ByteDeviceVendorInfoDictionaryTester
    extends EntryBasedTypedDeviceVendorInfoDictionary<List<int>> {
  @override
  final Stream<MapEntry<String, List<int>>> entries;

  ByteDeviceVendorInfoDictionaryTester(List<int> bytes)
      : entries = Stream.value(MapEntry("byte", bytes));

  factory ByteDeviceVendorInfoDictionaryTester.fromString(String str,
          {Encoding? encoding}) =>
      ByteDeviceVendorInfoDictionaryTester(
          encoding?.encode(str) ?? str.codeUnits);
}

void byteTester([Encoding? encoding]) {
  final ByteDeviceVendorInfoDictionaryTester tester =
      ByteDeviceVendorInfoDictionaryTester.fromString("範Sample text本",
          encoding: encoding);
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
          "0x7BC4 0x0053 0x0061 0x006D 0x0065 0x0020 0x0074 0x0065 0x0078 0x0074 0x672C"),
  "utf-8": StringifiedByteResult(
      dec: "231 175 132 83 97 109 112 108 101 32 116 101 120 116 230 156 172",
      hex:
          "0xE7 0xAF 0x84 0x53 0x61 0x6D 0x65 0x20 0x74 0x65 0x78 0x74 0xE6 0x9C 0xAC"),
  "Big5": StringifiedByteResult(
      dec:
          "48484 41697 41705 41717 41720 41716 41709 41280 41724 41709 41793 41724 42427",
      hex:
          "0xBD64 0xA2E1 0xA2E9 0xA2F5 0xA2F8 0xA2F4 0xA2ED 0xA140 0xA2FC 0xA2ED 0xA341 0xA2FC 0xA5BB")
};

void main() {
  setUpAll(() {
    overrideCorrectTargetPlatform();
  });

  group("Stringify bytes", () {
    group("in Dart code unit", byteTester);
    group("in UTF-8", () => byteTester(utf8));
    group("in Big 5", () => byteTester(big5));
  });
}

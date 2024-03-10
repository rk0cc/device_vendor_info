import 'dart:math' as math;
import 'dart:typed_data';

import 'package:device_vendor_info_interface/collections.dart';
import 'package:enough_convert/big5.dart';
import 'package:flutter_test/flutter_test.dart';

final class TestVendorDictionaryEntriesStream
    extends VendorDictionaryEntriesStreamBase<Object?> {
  const TestVendorDictionaryEntriesStream();

  Iterable<Object?> mockValues() sync* {
    yield null;
    yield 1;
    yield math.pi;
    yield <int>[67, 39, 53];
    yield "Foo";
    yield Uint8List.fromList(big5.encode("測試"));
  }

  @override
  Future<void> generateContent(DictionaryEntryStreamAdder<Object?> add,
      DictionaryEntryStreamThrower addError) async {
    for (var element in mockValues().indexed) {
      add("${element.$1}", element.$2);
    }
  }
}

final class TestVendorDictionary extends VendorDictionaryBase<Object?> {
  const TestVendorDictionary();

  @override
  VendorDictionaryEntriesStream<Object?> get entries =>
      const TestVendorDictionaryEntriesStream();
}

void main() {
  const testDict = TestVendorDictionary();
  late final SyncedVendorDictionary<Object?> syncedTestDict;

  setUpAll(() async {
    syncedTestDict = await testDict.syncAndSorted;
  });

  test("Stringify vendor dictionary", () {
    expect(
        syncedTestDict.toString(),
        equals(
            "{0: null, 1: 1, 2: ${math.pi}, 3: [67, 39, 53], 4: Foo, 5: [180, 250, 184, 213]}"));
  });
  group("Accessing dictionary:", () {
    group("Ensure no return null if key unexisted", () {
      test("in concurrent", () {
        Future<Object?> normalReturn() => testDict["0"];
        Future<Object?> normalThrows() => testDict["foo"];

        expect(normalReturn, returnsNormally);
        expect(normalThrows, throwsA(isA<InvalidDictionaryKeyError>()));
      });

      test("in synced", () {
        Object? normalReturn() => syncedTestDict["0"];
        Object? normalThrows() => syncedTestDict["foo"];

        expect(normalReturn, returnsNormally);
        expect(normalThrows, throwsA(isA<InvalidDictionaryKeyError>()));
      });
    });
    test("Disallow modify for synced dictionary", () {
      expect(() => syncedTestDict["0"] = 0, throwsUnsupportedError);
      expect(() => syncedTestDict["foo"] = "bar", throwsUnsupportedError);
    });
  });
}

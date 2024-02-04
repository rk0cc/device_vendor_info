@TestOn("windows || mac-os || linux")

import 'package:device_vendor_info/device_vendor_info.dart';
import 'package:device_vendor_info/instance.dart';
import 'package:device_vendor_info/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  test("Forbid using real loader during test", () {
    expect(() => DeviceVendorInfo.instance = null, throwsUnsupportedError);
  });
  group("Mock fetching test", () {
    setUpAll(() {
      DeviceVendorInfo.instance = MockDeviceVendorInfoLoader.simulateDelay(
          BiosInfo(vendor: "Test", version: "Test", releaseDate: null),
          BoardInfo(manufacturer: "Test", productName: "Test", version: "Test"),
          SystemInfo(
              family: "Test",
              manufacturer: "Test",
              productName: "Test",
              version: "Test"));
    });
    test("get mock loader without thrown", () {
      expect(() => DeviceVendorInfo.instance, returnsNormally);
    });
  });
}

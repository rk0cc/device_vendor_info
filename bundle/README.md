# Hardware information getter in Flutter environment

<p align="center">
    <a link="https://pub.dev/packages/device_vendor_info"><img alt="Pub Version" src="https://img.shields.io/pub/v/device_vendor_info?style=flat-square&logo=flutter"/></a>
</p>

This package offers additional hardware informations regarding on BIOS, motherboard and system that it enables software to allow/restrict features to specific vendors.

## Usages

### Install dependencies

In `pubspec.yaml`:

```yaml
dependencies:
    device_vendor_info: # Version constraint
```

### Import & implementation

```dart
import 'package:device_vendor_info/device_vendor_info.dart';
import 'package:flutter/widgets.dart';

Future<void> main() async {
    WidgetsFlutterBinding.ensureInitialized();

    final bios = await getBiosInfo();
    print(bios.vendor);
}
```

### Testing

To run testes with `DeviceVendorInfo`, attaching `MockDeviceVendorInfoLoader` into `DeviceVendorInfo.instance` is requried otherwise the incoming testes will throws `UnsepportedError` immediately.

```dart
// Specify testing platform to prevent causing test failed when running on unsupport platform accidentally.
@TestOn("windows || mac-os || linux")

import 'package:device_vendor_info/device_vendor_info.dart';
import 'package:device_vendor_info/instance.dart' show DeviceVendorInfo;
import 'package:device_vendor_info/testing.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
    setupAll(() {
        // Change the instance to mock loader instead of automatically uses produtive loader.
        DeviceVendorInfo.instance = MockDeviceVendorInfoLoader(
          BiosInfo(vendor: "Generic vendor", version: "v1.23", releaseDate: DateTime(2023, 2, 21)),
          BoardInfo(manufacturer: "Default", productName: "", version: ""),
          SystemInfo(family: "",manufacturer: "",productName: "",version: "")
        );
    });
    test("Run test", () {
        // Test implementations here
    });
    testWidget("Run test with widget", (tester) async {
        // Test with Flutter widget
    });
}
```

## License

BSD-3

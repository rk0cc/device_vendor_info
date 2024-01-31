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

    final bios = await DeviceVendorInfo.instance.biosInfo;
    print(bios.vendor);
}
```

## License

BSD-3

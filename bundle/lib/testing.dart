/// Provide a mock test framework that no real hardware information
/// will be used during executing testes.
library testing;

import 'dart:io';

import 'package:flutter/foundation.dart' hide visibleForTesting;
import 'package:meta/meta.dart';

export 'package:device_vendor_info_interface/mock.dart';

/// Override [defaultTargetPlatform] to correct [TargetPlatform]
/// during test.
///
/// Since [defaultTargetPlatform] will return [TargetPlatform.android]
/// when executing Flutter test that `device_vendor_info` should
/// throw [UnsupportedError]. This **MUST BE** called in `setUpAll`
/// as immediate as possible.
///
/// ```dart
/// void main() {
///   setUpAll(() {
///     overrideCorrectTargetPlatform();
///   });
///
///   // Writing test below
/// }
/// ```
@visibleForTesting
void overrideCorrectTargetPlatform() {
  if (Platform.isWindows) {
    debugDefaultTargetPlatformOverride = TargetPlatform.windows;
  }

  if (Platform.isMacOS) {
    debugDefaultTargetPlatformOverride = TargetPlatform.macOS;
  }

  if (Platform.isLinux) {
    debugDefaultTargetPlatformOverride = TargetPlatform.linux;
  }
}

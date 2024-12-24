## 2.0.4+1

* Fix incorrect `vmchecker` transitive constraint in `windows` dependencies.

## 2.0.4

* Change SDK constraint to `^3.6.0` for monorepo support

## 2.0.3

* Move VM suspect as internal code
* Simply code

## 2.0.2

* Recode `isVirtualized()` for better virtual machine detection.
    * Original implementation will be renamed to `hasHypervisor()`.

## 2.0.1

* Fix vmchecker loading issue

## 2.0.0

* Add virtualization detection.
* Increase minimum Flutter and Dart SDK version.

## 1.0.0

* Stable release of v1

## 1.0.0-beta.2

* Uses v4 interface API
* Switch to `dart:io` to determine release platform.

## 1.0.0-beta.1

* New interface implementations.

## 0.2.0

* Move `DeviceVendorInfo` class under `instance.dart` libarary.
* Update example using direct callback function.
* Provide export hardware information to JSON object in Dart.
* Add topics

## 0.1.1

* Add three functions to fetch hardware informations without calling instance.
* Update dependencies constraint.

## 0.1.0

* First release.

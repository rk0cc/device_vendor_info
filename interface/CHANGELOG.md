## 5.1.0

* Change Dart SDK constraint to `^3.8.0` along with serval dependencies.

## 5.0.1

* Change Dart SDK constaint to `^3.6.0` to enable monorepo support.

## 5.0.0

* Add virtual machine detection.

## 4.1.1

* Documentation fix

## 4.1.0

* Remove `synced` and `syncAndSorted` getter. These features have been replaced by `toSynced()`.

## 4.0.1

* Resolved linting problems.
* Apply missing docs.

## 4.0.0

**WARNING: THIS VERSION'S API IS INCOMPATABLE WITH `3.0.0` OR BELOW**

* Class rename
    * `DeviceVendorInfoDictionary` becomes `VendorDictionary`
* Redefine dictionray's entires stream API.

## 3.0.0

* `DeviceVendorInfoDictionary` values becomes `Object`
* Added `TypedDeviceVendorInfoDictionary` for specifed values types returned from dictionary.
* Added `EntryBasedDeviceVendorInfoDictionary` to deploy new `DeviceVendorInfoDictionary` by implementing `entries` only.
* Provides additional methods of `DeviceVendorInfoDictionary` which distributed via extension:
    * `castValues`
    * `map`
    * `where`
    * `whereTypeOfValues`

## 2.0.0

* `DeviceVendorInfoLoader` marked as `abstract final` class that extending or implementing it directly is forbidden.
    * Instead, uses `ProductiveDeviceVendorInfoLoader` for platform implementation or `MockDeviceVendorInfoLoader` for testing environment.
* Add `DeviceVendorInfoDictionary` inside of `ProductiveDeviceVendorInfoLoader` for getting raw value from platform.

## 1.1.0

* Add `toJson` for retrive information in JSON format

## 1.0.0+1

* Add macOS as supported platform.

## 1.0.0

* Define standard structure of hardware infos:
    * BIOS
    * Motherboard
    * System or product

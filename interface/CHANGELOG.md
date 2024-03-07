## 4.0.0



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

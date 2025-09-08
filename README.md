A completed layout for running fetching hardware information in Flutter.

There is a tree layout description for each subdirectories in root directory of this repository:

* `bundle`: A completed implementations of `device_vendor_info` which publicly exposed in pub.dev.
* `example`: Example code for implementing `device_vendor_info`, which originally stored inside of `bundle` directory.
* `interface`: Standard layout of object model and loader interface that it will be implemented in specific platform.
* `unix`: Loader implementations in UNIX platform.
* `vmchecker`: FFI plugin for checking program is executed under virtual machine or container.
* `windows`: Loader implementations in Windows platform.

# Windows based implementations of fetching device vendor information

This library implements a loader to fetch hardware information in Windows.

## Mechanism

The loader will get all necessry values from Windows Registry where their keys located at

```plain
HKEY_LOCAL_MACHINE\HARDWARE\DESCRIPTION\System\BIOS
```

and obtains them to a Dart object.

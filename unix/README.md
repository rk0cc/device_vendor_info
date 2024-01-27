# UNIX based implementations of fetching device vendor information

This library implements a loader to fetch hardware information in UNIX based system (including macOS and Linux).

## Mechanism

The loader will read files content which stored into DMI directory

```plain
/sys/class/dmi/id/
```

and obtains them to a Dart object.

> [!IMPORTANT]  
> The loader only reads DMI files that they have been granted read access to `other` which owned by `root`.

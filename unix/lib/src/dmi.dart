import 'dart:io';

import 'package:meta/meta.dart';
import 'package:path/path.dart' as p;

/// Define a valid category used for [DmiEntity].
@internal
enum DmiCategory { bios, board, chassis, product }

/// Define a [Map] declaration for getting value of DMI.
@internal
typedef DmiMap = Map<String, String>;

/// Declare a pattern for getting value from [DmiDirectoryReader].
@internal
typedef DmiEntity = (DmiCategory category, String value);

extension _DmiEntityStringifier on DmiEntity {
  String toRawString() {
    var (cat, val) = this;

    return "${cat.name}_$val".toLowerCase();
  }
}

/// A [Map]-like based reader for getting hardware information
/// from DMI directory.
@internal
final class DmiDirectoryReader {
  /// Construct a reader that ready to fetch hardware information.
  const DmiDirectoryReader();

  Future<DmiMap> get _dmiMap async {
    final Directory dmi = Directory(r"/sys/class/dmi/id/");
    assert(dmi.isAbsolute);

    if (!await dmi.exists()) {
      return const <String, String>{};
    }

    bool isReadable(String mode) =>
        RegExp(r"(?:r(?:w|-)(?:x|-)){3}$", caseSensitive: true, dotAll: false)
            .hasMatch(mode);

    return Map.unmodifiable({
      await for (File f in dmi
          .list(followLinks: false)
          .where((event) =>
              event is File && isReadable(event.statSync().modeString()))
          .cast<File>())
        p.basename(f.path): f.readAsStringSync()
    });
  }

  /// Get DMI content to [String].
  ///
  /// [query] can be accepted using [String] or [DmiEntity]
  /// to find corresponded DMI value. Otherwise, using
  /// other types will cause throwing [TypeError].
  Future<String?> operator [](Object query) async {
    late String name;

    if (query is DmiEntity) {
      name = query.toRawString();
    } else if (query is String) {
      name = query;
    } else {
      throw TypeError();
    }

    return (await _dmiMap)[name];
  }
}

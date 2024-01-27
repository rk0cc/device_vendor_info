import 'dart:io';

import 'package:async/async.dart';
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
  String toRawString() => "${$1.name}_${$2}".toLowerCase();
}

/// A [Map]-like based reader for getting hardware information
/// from DMI directory.
@internal
final class DmiDirectoryReader {
  final AsyncMemoizer<DmiMap> _dmiMapMemorizer = AsyncMemoizer();

  /// Construct a reader that ready to fetch hardware information.
  DmiDirectoryReader() {
    final Directory dmi = Directory(r"/sys/class/dmi/id/");
    assert(dmi.isAbsolute);

    _dmiMapMemorizer.runOnce(() async => await dmi.exists()
        ? Map.unmodifiable({
            await for (File f in dmi
                .list(followLinks: false)
                .where((event) =>
                    event is File && _isReadable(event.statSync().modeString()))
                .cast<File>())
              p.basename(f.path): f.readAsStringSync()
          })
        : const <String, String>{});
  }

  static bool _isReadable(String mode) =>
      RegExp(r"(?:r(?:w|-)(?:x|-)){3}$", caseSensitive: true, dotAll: false)
          .hasMatch(mode);

  Future<DmiMap> get _dmiMap => _dmiMapMemorizer.future;

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

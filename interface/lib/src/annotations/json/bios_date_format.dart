import 'package:json_annotation/json_annotation.dart';
import 'package:meta/meta.dart';

import '../../info/bios.dart';
import '../../definitions/bios_dateformat.dart';

/// Define conversion format of [DateTime] field for parsing
/// [BiosInfo.releaseDate].
@internal
@immutable
final class BiosDateFormatConverter
    implements JsonConverter<DateTime?, String?> {
  /// Annotate it to [BiosInfo.releaseDate] to enforce date format
  /// of BIOS release date.
  const BiosDateFormatConverter();

  @override
  DateTime? fromJson(String? json) => biosDateFormat.tryParse(json ?? "");

  @override
  String? toJson(DateTime? object) =>
      object == null ? null : biosDateFormat.format(object);
}

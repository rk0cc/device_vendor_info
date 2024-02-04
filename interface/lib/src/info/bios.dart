import 'package:json_annotation/json_annotation.dart';

import '../annotations/json/bios_date_format.dart';

part 'bios.g.dart';

/// A collection of BIOS data of the computer.
@JsonSerializable()
final class BiosInfo {
  /// Name of vandor who produces this BIOS chip.
  final String? vendor;

  /// BIOS version.
  ///
  /// Be note that the pattern of BIOS version
  /// is varied.
  final String? version;

  /// A [DateTime] when this BIOS [version] released at.
  @BiosDateFormatConverter()
  final DateTime? releaseDate;

  /// Construct a BIOS information of a device.
  const BiosInfo(
      {required this.vendor, required this.version, required this.releaseDate});

  /// Return an unmodifiable [Map] to notate information of [BiosInfo].
  Map<String, dynamic> toJson() => Map.unmodifiable(_$BiosInfoToJson(this));
}

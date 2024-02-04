import 'package:json_annotation/json_annotation.dart';

part 'board.g.dart';

/// A collection of the motherboard.
@JsonSerializable()
final class BoardInfo {
  /// A company who produce this motherboard.
  final String? manufacturer;

  /// Name of motherboard.
  final String? productName;

  /// Motherboard version.
  final String? version;

  /// Construct a motherboard information.
  const BoardInfo(
      {required this.manufacturer,
      required this.productName,
      required this.version});

  /// Return an unmodifiable [Map] to notate information of [BoardInfo].
  Map<String, dynamic> toJson() => Map.unmodifiable(_$BoardInfoToJson(this));
}

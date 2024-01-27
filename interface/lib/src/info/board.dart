/// A collection of the motherboard.
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
}

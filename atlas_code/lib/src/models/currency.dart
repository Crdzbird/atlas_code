/// {@template currency}
/// An ISO 4217 currency, as used by one or more countries.
///
/// Instances are bundled with the package as compile-time constants and
/// generated from the same dataset as the countries.
/// {@endtemplate}
final class Currency {
  /// {@macro currency}
  const Currency({
    required this.code,
    required this.name,
    required this.symbol,
  });

  /// ISO 4217 code, always uppercase.
  ///
  /// Example: `USD`, `EUR`.
  final String code;

  /// English currency name.
  ///
  /// Example: `United States dollar`, `Euro`.
  final String name;

  /// Currency symbol.
  ///
  /// Example: `$`, `€`.
  final String symbol;

  /// Currencies are identified by their ISO 4217 [code].
  @override
  bool operator ==(Object other) =>
      identical(this, other) || (other is Currency && other.code == code);

  @override
  int get hashCode => code.hashCode;

  @override
  String toString() => 'Currency($code, $name)';
}

// AtlasCodeApi must be abstract.
// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartPackageName: 'atlas_code',
    swiftOut: 'ios/atlas_code_ios/Sources/atlas_code_ios/Messages.g.swift',
    swiftOptions: SwiftOptions(),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class AtlasCodeApi {
  /// Returns OS-localized country display names for the BCP-47
  /// [languageTag], keyed by uppercase ISO 3166-1 alpha-2 code.
  Map<String, String> localizedCountryNames(String languageTag);
}

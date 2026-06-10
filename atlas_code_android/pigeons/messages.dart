// AtlasCodeApi must be abstract.
// ignore_for_file: one_member_abstracts

import 'package:pigeon/pigeon.dart';

@ConfigurePigeon(
  PigeonOptions(
    dartOut: 'lib/src/messages.g.dart',
    dartPackageName: 'atlas_code',
    kotlinOut:
        'android/src/main/kotlin/ni/devotion/atlas_code/Messages.g.kt',
    kotlinOptions: KotlinOptions(package: 'ni.devotion.atlas_code'),
    copyrightHeader: 'pigeons/copyright.txt',
  ),
)
@HostApi()
abstract class AtlasCodeApi {
  /// Returns OS-localized country display names for the BCP-47
  /// [languageTag], keyed by uppercase ISO 3166-1 alpha-2 code.
  Map<String, String> localizedCountryNames(String languageTag);
}

import 'package:atlas_code_macos/src/messages.g.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter/foundation.dart';

/// {@template atlas_code_macos}
/// The macOS implementation of [AtlasCodePlatform].
/// {@endtemplate}
class AtlasCodeMacOS extends AtlasCodePlatform {
  /// {@macro atlas_code_macos}
  AtlasCodeMacOS({
    @visibleForTesting AtlasCodeApi? api,
  }) : api = api ?? AtlasCodeApi();

  /// The API used to interact with the native platform.
  final AtlasCodeApi api;

  /// Registers this class as the default instance of [AtlasCodePlatform].
  static void registerWith() {
    AtlasCodePlatform.instance = AtlasCodeMacOS();
  }

  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) {
    return api.localizedCountryNames(languageTag);
  }
}

import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter/foundation.dart' show visibleForTesting;
import 'package:flutter/services.dart';

/// An implementation of [AtlasCodePlatform] that uses method channels.
class MethodChannelAtlasCode extends AtlasCodePlatform {
  /// The method channel used to interact with the native platform.
  @visibleForTesting
  final methodChannel = const MethodChannel('atlas_code');

  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) async {
    final names = await methodChannel.invokeMapMethod<String, String>(
      'localizedCountryNames',
      languageTag,
    );
    return names ?? const {};
  }
}

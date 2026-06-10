import 'package:atlas_code_platform_interface/src/method_channel_atlas_code.dart';
import 'package:plugin_platform_interface/plugin_platform_interface.dart';

export 'package:atlas_code_platform_interface/src/iso_alpha2_codes.dart';
export 'package:atlas_code_platform_interface/src/method_channel_atlas_code.dart';

/// {@template atlas_code_platform}
/// The interface that implementations of atlas_code must implement.
///
/// Platform implementations should extend this class
/// rather than implement it as `AtlasCode`.
///
/// Extending this class (using `extends`) ensures that the subclass will get
/// the default implementation, while platform implementations that
/// `implements` this interface will be broken by newly added
/// [AtlasCodePlatform] methods.
/// {@endtemplate}
abstract class AtlasCodePlatform extends PlatformInterface {
  /// {@macro atlas_code_platform}
  AtlasCodePlatform() : super(token: _token);

  static final Object _token = Object();

  static AtlasCodePlatform _instance = MethodChannelAtlasCode();

  /// The default instance of [AtlasCodePlatform] to use.
  ///
  /// Defaults to [MethodChannelAtlasCode].
  static AtlasCodePlatform get instance => _instance;

  /// Platform-specific plugins should set this with their own
  /// platform-specific class that extends [AtlasCodePlatform]
  /// when they register themselves.
  static set instance(AtlasCodePlatform instance) {
    PlatformInterface.verify(instance, _token);
    _instance = instance;
  }

  // CONTRACT: keys are UPPERCASE ISO 3166-1 alpha-2 codes; values are
  // display names localized to [languageTag]. An empty map means the
  // platform has no localization data and callers should fall back to
  // bundled English names. Changing this shape breaks every platform
  // implementation package.
  /// Returns the country display names known to the operating system,
  /// localized to the BCP-47 [languageTag] (e.g. `en-US`, `pt`).
  ///
  /// Keys are uppercase ISO 3166-1 alpha-2 codes. Implementations that have
  /// no localization data for [languageTag] should return an empty map
  /// rather than throwing.
  Future<Map<String, String>> localizedCountryNames(String languageTag);
}

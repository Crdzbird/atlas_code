import 'dart:ui' show Locale;

import 'package:atlas_code/atlas_code.dart';
import 'package:atlas_code_platform_interface/atlas_code_platform_interface.dart';
import 'package:flutter_test/flutter_test.dart';

class _FakePlatform extends AtlasCodePlatform {
  _FakePlatform(this._handler);

  final Future<Map<String, String>> Function(String languageTag) _handler;
  final requestedTags = <String>[];

  @override
  Future<Map<String, String>> localizedCountryNames(String languageTag) {
    requestedTags.add(languageTag);
    return _handler(languageTag);
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  group('AtlasCode.localizedNames', () {
    test('returns platform names keyed by alpha-2', () async {
      final platform = _FakePlatform(
        (_) async => {'US': 'Estados Unidos da América'},
      );
      final atlas = AtlasCode(platform: platform);

      final names = await atlas.localizedNames(
        locale: const Locale('pt', 'PT'),
      );

      expect(platform.requestedTags, ['pt-PT']);
      expect(names.languageTag, 'pt-PT');
      expect(names.isFallback, isFalse);
      expect(names['us'], 'Estados Unidos da América');
    });

    test('fills codes the platform omits with bundled English', () async {
      final platform = _FakePlatform((_) async => {'DE': 'Alemanha'});
      final atlas = AtlasCode(platform: platform);

      final names = await atlas.localizedNames(locale: const Locale('pt'));

      expect(names['DE'], 'Alemanha');
      expect(names['US'], 'United States');
    });

    test(
      'falls back to bundled English when the platform has no data',
      () async {
        final platform = _FakePlatform((_) async => {});
        final atlas = AtlasCode(platform: platform);

        final names = await atlas.localizedNames(locale: const Locale('xx'));

        expect(names.isFallback, isTrue);
        expect(names['PT'], 'Portugal');
        expect(names.of(Countries.fromAlpha2('DE')!), 'Germany');
      },
    );

    test('falls back when the platform call throws', () async {
      final platform = _FakePlatform((_) async => throw Exception('boom'));
      final atlas = AtlasCode(platform: platform);

      final names = await atlas.localizedNames(locale: const Locale('de'));

      expect(names.isFallback, isTrue);
      expect(names['FR'], 'France');
    });

    test('caches results per language tag', () async {
      final platform = _FakePlatform((_) async => {'US': 'Vereinigte Staaten'});
      final atlas = AtlasCode(platform: platform);

      await atlas.localizedNames(locale: const Locale('de'));
      await atlas.localizedNames(locale: const Locale('de'));
      await atlas.localizedNames(locale: const Locale('de', 'AT'));

      expect(platform.requestedTags, ['de', 'de-AT']);
    });

    test('defaults to the device locale', () async {
      final platform = _FakePlatform((_) async => {});
      final atlas = AtlasCode(platform: platform);

      await atlas.localizedNames();

      expect(
        platform.requestedTags.single,
        atlas.deviceLocale.toLanguageTag(),
      );
    });
  });

  group('AtlasCode.localizedNameOf', () {
    test('resolves a single country with fallback', () async {
      final platform = _FakePlatform((_) async => {'PT': 'Portogallo'});
      final atlas = AtlasCode(platform: platform);
      final pt = Countries.fromAlpha2('PT')!;
      final us = Countries.fromAlpha2('US')!;

      expect(
        await atlas.localizedNameOf(pt, locale: const Locale('it')),
        'Portogallo',
      );
      expect(
        await atlas.localizedNameOf(us, locale: const Locale('it')),
        'United States',
      );
    });
  });

  group('LocalizedCountryNames', () {
    test('asMap is unmodifiable', () {
      const names = LocalizedCountryNames(
        languageTag: 'en',
        names: {'US': 'United States'},
        isFallback: false,
      );
      expect(() => names.asMap['PT'] = 'x', throwsUnsupportedError);
    });
  });
}

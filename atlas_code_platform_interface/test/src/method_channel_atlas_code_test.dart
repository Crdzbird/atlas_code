import 'package:atlas_code_platform_interface/src/method_channel_atlas_code.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const kNames = {'US': 'United States', 'PT': 'Portugal'};

  group('$MethodChannelAtlasCode', () {
    late MethodChannelAtlasCode methodChannelAtlasCode;
    final log = <MethodCall>[];
    Object? response;

    setUp(() {
      response = kNames;
      methodChannelAtlasCode = MethodChannelAtlasCode();
      TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger
          .setMockMethodCallHandler(
            methodChannelAtlasCode.methodChannel,
            (methodCall) async {
              log.add(methodCall);
              switch (methodCall.method) {
                case 'localizedCountryNames':
                  return response;
                default:
                  return null;
              }
            },
          );
    });

    tearDown(log.clear);

    test('localizedCountryNames passes the language tag through', () async {
      final names =
          await methodChannelAtlasCode.localizedCountryNames('en-US');
      expect(
        log,
        <Matcher>[isMethodCall('localizedCountryNames', arguments: 'en-US')],
      );
      expect(names, equals(kNames));
    });

    test('localizedCountryNames returns an empty map on null response',
        () async {
      response = null;
      final names = await methodChannelAtlasCode.localizedCountryNames('pt');
      expect(names, isEmpty);
    });
  });
}

import 'package:blockday/core/build_info/build_info_labels.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('shortCommit', () {
    test('recorta a siete caracteres', () {
      expect(shortCommit('3d8890b1a2b3c4d5'), '3d8890b');
    });

    test('deja intacto un hash corto', () {
      expect(shortCommit('3d8890b'), '3d8890b');
    });

    test('recorta espacios', () {
      expect(shortCommit('  a1b2c3d  '), 'a1b2c3d');
    });
  });

  group('isDirtyFlag', () {
    test('true sin importar mayúsculas', () {
      expect(isDirtyFlag('TRUE'), isTrue);
      expect(isDirtyFlag('true'), isTrue);
    });

    test('cualquier otro valor es false', () {
      expect(isDirtyFlag('false'), isFalse);
      expect(isDirtyFlag(''), isFalse);
    });
  });

  group('parseBuildTime', () {
    test('convierte ISO-8601 UTC a local', () {
      final parsed = parseBuildTime('2026-11-18T14:22:00Z');
      expect(parsed, isNotNull);
      expect(parsed!.isUtc, isFalse);
      expect(parsed.toUtc(), DateTime.utc(2026, 11, 18, 14, 22));
    });

    test('devuelve null si viene vacío o inválido', () {
      expect(parseBuildTime(''), isNull);
      expect(parseBuildTime('no-es-fecha'), isNull);
    });
  });

  group('formatBuildTime', () {
    test('formatea día, mes corto, año y hora', () {
      expect(
        formatBuildTime(DateTime(2026, 11, 18, 14, 5)),
        '18 nov 2026 · 14:05',
      );
    });

    test('sin fecha devuelve No disponible', () {
      expect(formatBuildTime(null), kBuildUnavailable);
    });
  });

  group('appVersionLabel', () {
    test('incluye el número de build', () {
      expect(appVersionLabel('0.1.0', '3'), 'v0.1.0 (3)');
    });

    test('sin build deja solo la versión', () {
      expect(appVersionLabel('0.1.0', ''), 'v0.1.0');
    });

    test('sin versión devuelve No disponible', () {
      expect(appVersionLabel('  ', '3'), kBuildUnavailable);
    });
  });

  group('appCommitLabel', () {
    test('marca los cambios sin commitear', () {
      expect(appCommitLabel('3d8890b', dirty: true), '3d8890b *');
    });

    test('sin dirty queda el hash limpio', () {
      expect(appCommitLabel('3d8890b'), '3d8890b');
    });

    test('sin commit devuelve No disponible', () {
      expect(appCommitLabel(''), kBuildUnavailable);
    });
  });

  group('platformLabel', () {
    test('traduce el sistema y toma la arquitectura', () {
      expect(
        platformLabel('linux', '3.13.1 (stable) on "linux_x64"'),
        'Linux x64',
      );
      expect(
        platformLabel('windows', '3.13.1 (stable) on "windows_arm64"'),
        'Windows arm64',
      );
      expect(
        platformLabel('android', '3.13.1 (stable) on "android_arm64"'),
        'Android arm64',
      );
    });

    test('sin arquitectura deja solo el sistema', () {
      expect(platformLabel('linux', '3.13.1 (stable)'), 'Linux');
    });

    test('sistema vacío devuelve No disponible', () {
      expect(platformLabel('', ''), kBuildUnavailable);
    });
  });

  group('buildChannelLabel', () {
    test('distingue release, debug y profile', () {
      expect(buildChannelLabel(release: true, debug: false), 'release');
      expect(buildChannelLabel(release: false, debug: true), 'debug');
      expect(buildChannelLabel(release: false, debug: false), 'profile');
    });
  });
}

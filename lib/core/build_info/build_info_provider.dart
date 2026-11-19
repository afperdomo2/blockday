import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';

import 'build_info.dart';
import 'build_info_labels.dart';

const String kRepositoryUrl = 'https://github.com/afperdomo2/blockday';

const String _commit = String.fromEnvironment('GIT_COMMIT');
const String _buildTime = String.fromEnvironment('BUILD_TIME');
const String _dirty = String.fromEnvironment('BUILD_DIRTY');

Future<BuildInfo> _loadBuildInfo() async {
  var version = '';
  var buildNumber = '';
  try {
    final info = await PackageInfo.fromPlatform();
    version = info.version;
    buildNumber = info.buildNumber;
  } catch (_) {
    version = '';
    buildNumber = '';
  }

  return BuildInfo(
    version: version,
    buildNumber: buildNumber,
    commit: shortCommit(_commit),
    buildDate: parseBuildTime(_buildTime),
    dirty: isDirtyFlag(_dirty),
    platform: platformLabel(Platform.operatingSystem, Platform.version),
    channel: buildChannelLabel(release: kReleaseMode, debug: kDebugMode),
  );
}

final buildInfoProvider = FutureProvider<BuildInfo>((ref) => _loadBuildInfo());

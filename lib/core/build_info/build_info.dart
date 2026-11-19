import 'dart:io';

import 'build_info_labels.dart';

class BuildInfo {
  const BuildInfo({
    required this.version,
    required this.buildNumber,
    required this.commit,
    required this.buildDate,
    required this.dirty,
    required this.platform,
    required this.channel,
  });

  final String version;
  final String buildNumber;
  final String commit;
  final DateTime? buildDate;
  final bool dirty;
  final String platform;
  final String channel;

  String get versionLabel => appVersionLabel(version, buildNumber);

  String get commitLabel => appCommitLabel(commit, dirty: dirty);

  String get buildDateLabel => formatBuildTime(buildDate);

  static BuildInfo unknown() => BuildInfo(
    version: '',
    buildNumber: '',
    commit: '',
    buildDate: null,
    dirty: false,
    platform: platformLabel(Platform.operatingSystem, Platform.version),
    channel: buildChannelLabel(release: false, debug: true),
  );
}

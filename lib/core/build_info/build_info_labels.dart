library;

const String kBuildUnavailable = 'No disponible';

const int _shortCommitLength = 7;

const List<String> _months = [
  '',
  'ene',
  'feb',
  'mar',
  'abr',
  'may',
  'jun',
  'jul',
  'ago',
  'sep',
  'oct',
  'nov',
  'dic',
];

String shortCommit(String raw) {
  final commit = raw.trim();
  if (commit.length > _shortCommitLength) {
    return commit.substring(0, _shortCommitLength);
  }
  return commit;
}

bool isDirtyFlag(String raw) => raw.trim().toLowerCase() == 'true';

DateTime? parseBuildTime(String raw) {
  final value = raw.trim();
  if (value.isEmpty) return null;
  return DateTime.tryParse(value)?.toLocal();
}

String formatBuildTime(DateTime? date) {
  if (date == null) return kBuildUnavailable;
  final local = date.toLocal();
  final hour = local.hour.toString().padLeft(2, '0');
  final minute = local.minute.toString().padLeft(2, '0');
  return '${local.day} ${_months[local.month]} ${local.year} · $hour:$minute';
}

String appVersionLabel(String version, String buildNumber) {
  final value = version.trim();
  if (value.isEmpty) return kBuildUnavailable;
  final build = buildNumber.trim();
  return build.isEmpty ? 'v$value' : 'v$value ($build)';
}

String appCommitLabel(String commit, {bool dirty = false}) {
  final value = commit.trim();
  if (value.isEmpty) return kBuildUnavailable;
  return dirty ? '$value *' : value;
}

String platformLabel(String operatingSystem, String dartVersion) {
  final name = switch (operatingSystem.trim().toLowerCase()) {
    'linux' => 'Linux',
    'windows' => 'Windows',
    'macos' => 'macOS',
    'android' => 'Android',
    'ios' => 'iOS',
    'fuchsia' => 'Fuchsia',
    '' => kBuildUnavailable,
    _ => operatingSystem.trim(),
  };
  final arch = _archFromDartVersion(dartVersion);
  return arch == null ? name : '$name $arch';
}

String? _archFromDartVersion(String dartVersion) {
  final match = RegExp(r'on "([A-Za-z0-9_]+)"').firstMatch(dartVersion);
  final target = match?.group(1);
  if (target == null) return null;
  final arch = target.split('_').skip(1).join('_');
  return arch.isEmpty ? null : arch;
}

String buildChannelLabel({required bool release, required bool debug}) {
  if (release) return 'release';
  if (debug) return 'debug';
  return 'profile';
}

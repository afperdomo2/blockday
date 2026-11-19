import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../activities/providers/activities_providers.dart';
import '../data/backup_file_service.dart';
import '../data/backup_repository.dart';

final backupRepositoryProvider = Provider<BackupRepository>((ref) {
  return BackupRepository(ref.watch(appDatabaseProvider));
});

final backupFileServiceProvider = Provider<BackupFileService>((ref) {
  return FilePickerBackupFileService();
});

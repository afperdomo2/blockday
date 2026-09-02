import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../data/app_database.dart';
import '../data/repositories/activities_repository.dart';

final appDatabaseProvider = Provider<AppDatabase>((ref) {
  final db = AppDatabase();
  ref.onDispose(db.close);
  return db;
});

final activitiesRepositoryProvider = Provider<ActivitiesRepository>((ref) {
  final db = ref.watch(appDatabaseProvider);
  return ActivitiesRepository(db);
});

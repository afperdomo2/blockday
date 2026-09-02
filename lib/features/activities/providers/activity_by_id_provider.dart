import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../domain/activity.dart';
import 'activities_providers.dart';

final activityByIdProvider = FutureProvider.family<Activity?, String>((
  ref,
  id,
) async {
  return ref.watch(activitiesRepositoryProvider).getById(id);
});

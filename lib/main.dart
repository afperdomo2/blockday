import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';

import 'app.dart';
import 'core/debug/seed_data.dart';
import 'features/activities/data/app_database.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('es', null);
  if (kDebugMode) {
    final db = AppDatabase();
    await seedDebugDataIfEmpty(db);
    await db.close();
  }
  runApp(const ProviderScope(child: BlockdayApp()));
}

import 'package:go_router/go_router.dart';

import '../features/activities/presentation/screens/activity_editor_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    GoRoute(path: '/', builder: (context, state) => const CalendarScreen()),
    GoRoute(
      path: '/activity/new',
      builder: (context, state) => const ActivityEditorScreen(),
    ),
    GoRoute(
      path: '/activity/:id',
      builder: (context, state) =>
          ActivityEditorScreen(activityId: state.pathParameters['id']),
    ),
  ],
);

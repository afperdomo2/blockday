import 'package:go_router/go_router.dart';

import '../features/activities/presentation/screens/activity_editor_screen.dart';
import '../features/backlog/presentation/screens/backlog_screen.dart';
import '../features/backlog/presentation/screens/task_editor_screen.dart';
import '../features/calendar/presentation/screens/calendar_screen.dart';
import 'main_shell.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/',
  routes: <RouteBase>[
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) =>
          MainShell(navigationShell: navigationShell),
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/',
              builder: (context, state) => const CalendarScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/backlog',
              builder: (context, state) => const BacklogScreen(),
            ),
            GoRoute(
              path: '/backlog/task/new',
              builder: (context, state) => const TaskEditorScreen(),
            ),
            GoRoute(
              path: '/backlog/task/:id',
              builder: (context, state) =>
                  TaskEditorScreen(taskId: state.pathParameters['id']),
            ),
          ],
        ),
      ],
    ),
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

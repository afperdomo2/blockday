import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/responsive/constrained_content.dart';
import '../../../../core/theme/app_spacing.dart';
import '../../../../shared/widgets/section_header.dart';
import '../../domain/app_settings.dart';
import '../../providers/settings_providers.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settingsAsync = ref.watch(settingsProvider);
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes'), centerTitle: false),
      body: ConstrainedContent(
        maxWidth: AppContentWidth.form,
        child: settingsAsync.when(
          loading: () => const Center(child: CircularProgressIndicator()),
          error: (e, _) => Center(child: Text('Error: $e')),
          data: (settings) => ListView(
            padding: const EdgeInsets.all(AppSpacing.lg),
            children: [
              const SectionHeader(title: 'Apariencia'),
              _SettingCard(
                title: 'Tema',
                subtitle: 'Modo claro u oscuro de la app',
                child: SegmentedButton<ThemePreference>(
                  segments: const [
                    ButtonSegment(
                      value: ThemePreference.system,
                      label: Text('Sistema'),
                      icon: Icon(Icons.brightness_auto),
                    ),
                    ButtonSegment(
                      value: ThemePreference.light,
                      label: Text('Claro'),
                      icon: Icon(Icons.light_mode),
                    ),
                    ButtonSegment(
                      value: ThemePreference.dark,
                      label: Text('Oscuro'),
                      icon: Icon(Icons.dark_mode),
                    ),
                  ],
                  selected: {settings.themePreference},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .setThemePreference(v.first),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Calendario'),
              _SettingCard(
                title: 'La semana empieza en',
                subtitle: 'Afecta a las vistas de semana y mes',
                child: SegmentedButton<WeekStart>(
                  segments: const [
                    ButtonSegment(
                      value: WeekStart.monday,
                      label: Text('Lunes'),
                    ),
                    ButtonSegment(
                      value: WeekStart.sunday,
                      label: Text('Domingo'),
                    ),
                  ],
                  selected: {settings.weekStart},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) =>
                      ref.read(settingsProvider.notifier).setWeekStart(v.first),
                ),
              ),
              const SizedBox(height: AppSpacing.xl),
              const SectionHeader(title: 'Formato de hora'),
              _SettingCard(
                title: 'Reloj',
                subtitle: 'Cómo se muestran las horas',
                child: SegmentedButton<bool>(
                  segments: const [
                    ButtonSegment(value: false, label: Text('12 h')),
                    ButtonSegment(value: true, label: Text('24 h')),
                  ],
                  selected: {settings.use24HourFormat},
                  showSelectedIcon: false,
                  onSelectionChanged: (v) => ref
                      .read(settingsProvider.notifier)
                      .setUse24HourFormat(v.first),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _SettingCard extends StatelessWidget {
  const _SettingCard({
    required this.title,
    required this.subtitle,
    required this.child,
  });

  final String title;
  final String subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    final colorScheme = Theme.of(context).colorScheme;
    return Card(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: textTheme.titleSmall),
            const SizedBox(height: AppSpacing.xxs),
            Text(
              subtitle,
              style: textTheme.bodySmall?.copyWith(
                color: colorScheme.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: AppSpacing.md),
            child,
          ],
        ),
      ),
    );
  }
}

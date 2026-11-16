import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/external_links.dart';
import '../widgets/project_card.dart';

class ProjectsScreen extends StatelessWidget {
  const ProjectsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Все проекты')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 1080),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Semantics(
                    header: true,
                    child: Text(
                      'Мои проекты',
                      style: theme.textTheme.headlineMedium,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'Код и подробности — в репозиториях на GitHub.',
                    style: theme.textTheme.bodyLarge?.copyWith(
                      color: theme.colorScheme.onSurfaceVariant,
                    ),
                  ),
                  const SizedBox(height: 32),
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final textScale =
                          MediaQuery.textScalerOf(context).scale(16) / 16;
                      final columns =
                          constraints.maxWidth >= 760 && textScale <= 1.4
                          ? 2
                          : 1;
                      final cardWidth =
                          (constraints.maxWidth - (columns - 1) * 20) / columns;

                      return Wrap(
                        spacing: 20,
                        runSpacing: 20,
                        children: [
                          for (final project in portfolioProjects)
                            SizedBox(
                              width: cardWidth,
                              child: ProjectCard(project: project),
                            ),
                        ],
                      );
                    },
                  ),
                  const SizedBox(height: 28),
                  TextButton.icon(
                    onPressed: () => openExternalLink(
                      context,
                      Uri.parse(
                        'https://github.com/Davichik353?tab=repositories',
                      ),
                    ),
                    icon: const Icon(Icons.open_in_new, size: 18),
                    label: const Text('Все репозитории на GitHub'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

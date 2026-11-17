import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/external_links.dart';

class ProjectCard extends StatelessWidget {
  const ProjectCard({super.key, required this.project});

  final PortfolioProject project;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final colors = theme.colorScheme;

    return Card.outlined(
      margin: EdgeInsets.zero,
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: colors.primaryContainer,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(project.icon, color: colors.onPrimaryContainer),
            ),
            const SizedBox(height: 20),
            Semantics(
              header: true,
              child: Text(project.title, style: theme.textTheme.titleLarge),
            ),
            const SizedBox(height: 8),
            Text(
              project.description,
              style: theme.textTheme.bodyLarge?.copyWith(
                color: colors.onSurfaceVariant,
              ),
            ),
            const SizedBox(height: 20),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final technology in project.technologies)
                  Chip(
                    label: Text(technology),
                    visualDensity: VisualDensity.compact,
                  ),
              ],
            ),
            const SizedBox(height: 20),
            OutlinedButton.icon(
              onPressed: () =>
                  openExternalLink(context, Uri.parse(project.repositoryUrl)),
              icon: const Icon(Icons.open_in_new, size: 18),
              label: const Text('Код на GitHub'),
            ),
          ],
        ),
      ),
    );
  }
}

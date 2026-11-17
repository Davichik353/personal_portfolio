import 'package:flutter/material.dart';

enum PortfolioSection {
  about('О себе'),
  projects('Проекты'),
  skills('Навыки'),
  experience('Опыт'),
  contacts('Контакты');

  const PortfolioSection(this.label);
  final String label;
}

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  const CustomAppBar({super.key, required this.onSectionSelected});

  final ValueChanged<PortfolioSection> onSectionSelected;

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    final expanded =
        MediaQuery.sizeOf(context).width >= 1000 &&
        MediaQuery.textScalerOf(context).scale(14) <= 18;
    return AppBar(
      title: const Text('Davichik353'),
      actions: [
        if (expanded)
          for (final section in PortfolioSection.values)
            TextButton(
              onPressed: () => onSectionSelected(section),
              child: Text(section.label),
            )
        else
          PopupMenuButton<PortfolioSection>(
            tooltip: 'Разделы портфолио',
            icon: const Icon(Icons.menu_rounded),
            onSelected: onSectionSelected,
            itemBuilder: (context) => [
              for (final section in PortfolioSection.values)
                PopupMenuItem(value: section, child: Text(section.label)),
            ],
          ),
        const SizedBox(width: 12),
      ],
    );
  }
}

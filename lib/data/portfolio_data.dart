import 'package:flutter/material.dart';

/// The projects featured in the portfolio, shared by both project views.
@immutable
class PortfolioProject {
  const PortfolioProject({
    required this.title,
    required this.description,
    required this.repositoryUrl,
    required this.icon,
    required this.technologies,
  });

  final String title;
  final String description;
  final String repositoryUrl;
  final IconData icon;
  final List<String> technologies;
}

const portfolioProjects = <PortfolioProject>[
  PortfolioProject(
    title: 'Weather App',
    description: 'Погодное приложение с фоном города и анимациями.',
    repositoryUrl: 'https://github.com/Davichik353/weather_app_1',
    icon: Icons.wb_sunny_outlined,
    technologies: ['Flutter', 'Dart', 'API'],
  ),
  PortfolioProject(
    title: 'AR Compass',
    description: 'Компас с поворотом по направлению.',
    repositoryUrl: 'https://github.com/Davichik353/ar_compass',
    icon: Icons.explore_outlined,
    technologies: ['Flutter', 'Dart'],
  ),
];

import 'package:flutter/material.dart';

import '../data/portfolio_data.dart';
import '../utils/external_links.dart';
import '../widgets/background.dart';
import '../widgets/custom_app_bar.dart';
import '../widgets/project_card.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _scrollController = ScrollController();
  final _sectionKeys = {
    for (final section in PortfolioSection.values) section: GlobalKey(),
  };

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _goTo(PortfolioSection section) {
    final target = _sectionKeys[section]?.currentContext;
    if (target == null) return;
    Scrollable.ensureVisible(
      target,
      duration: MediaQuery.disableAnimationsOf(context)
          ? Duration.zero
          : const Duration(milliseconds: 350),
      curve: Curves.easeOutCubic,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: CustomAppBar(onSectionSelected: _goTo),
      body: Background(
        child: SafeArea(
          top: false,
          child: Scrollbar(
            controller: _scrollController,
            child: SingleChildScrollView(
              controller: _scrollController,
              padding: const EdgeInsets.fromLTRB(20, 32, 20, 40),
              child: Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1080),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      _Intro(
                        key: _sectionKeys[PortfolioSection.about],
                        onProjects: () => _goTo(PortfolioSection.projects),
                      ),
                      _Section(
                        key: _sectionKeys[PortfolioSection.projects],
                        title: 'Проекты',
                        subtitle: 'Мобильные приложения на Flutter и Dart',
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _ResponsivePair(
                              children: [
                                for (final project in portfolioProjects)
                                  ProjectCard(project: project),
                              ],
                            ),
                            const SizedBox(height: 16),
                            OutlinedButton.icon(
                              onPressed: () =>
                                  Navigator.pushNamed(context, '/projects'),
                              icon: const Icon(Icons.arrow_forward_rounded),
                              label: const Text('Все проекты'),
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        key: _sectionKeys[PortfolioSection.skills],
                        title: 'Навыки',
                        subtitle: 'Мой инструментарий',
                        child: const _Panel(
                          child: Wrap(
                            spacing: 8,
                            runSpacing: 8,
                            children: [
                              _SkillTag('Flutter'),
                              _SkillTag('Dart · 85%'),
                              _SkillTag('Python · 70%'),
                              _SkillTag('UI/UX · 80%'),
                              _SkillTag('Нейросети · 89%'),
                              _SkillTag('Блокчейн · 65%'),
                              _SkillTag('Photoshop · 77%'),
                              _SkillTag('MS Office · 90%'),
                              _SkillTag('Git · 70%'),
                              _SkillTag('JavaScript · 50%'),
                              _SkillTag('Trello, Jira, Slack · 60%'),
                            ],
                          ),
                        ),
                      ),
                      _Section(
                        key: _sectionKeys[PortfolioSection.experience],
                        title: 'Профессиональный опыт',
                        child: const _Panel(
                          child: Column(
                            children: [
                              _Experience(
                                title: 'Оператор в UCELL',
                                period: 'Апрель 2025 — настоящее время',
                                icon: Icons.support_agent_rounded,
                                details: [
                                  'Поддержка клиентов и техническая помощь.',
                                  'Активация SIM-карт и устранение неполадок.',
                                  'Работа над качеством обслуживания клиентов.',
                                ],
                              ),
                              Divider(height: 32),
                              _Experience(
                                title: 'Графический дизайнер',
                                period: 'Копицентр · январь — апрель 2025',
                                icon: Icons.design_services_outlined,
                                details: [
                                  'Работа с печатными заказами и обработка фотографий.',
                                  'Редактирование изображений и дизайн в Adobe Photoshop.',
                                ],
                              ),
                            ],
                          ),
                        ),
                      ),
                      const _Section(
                        title: 'Образование',
                        child: _ResponsivePair(
                          children: [
                            _Panel(
                              child: _Education(
                                title: 'Курс по программированию на Dart',
                                subtitle: 'Центр обучения в Навои',
                                date: 'Май 2023',
                              ),
                            ),
                            _Panel(
                              child: _Education(
                                title: 'Среднее образование',
                                subtitle: 'Самаркандская областная школа',
                                date: '2022',
                              ),
                            ),
                          ],
                        ),
                      ),
                      _Section(
                        title: 'Сертификат',
                        child: _Panel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Icon(
                                Icons.workspace_premium_outlined,
                                size: 32,
                              ),
                              const SizedBox(height: 12),
                              Text(
                                'Mobile App Development',
                                style: Theme.of(context).textTheme.titleLarge,
                              ),
                              const SizedBox(height: 8),
                              const Text('NEMNIG IT AKADEMIYA'),
                              const Text('Flutter, Dart, UI/UX и работа с API'),
                              const SizedBox(height: 20),
                              OutlinedButton.icon(
                                onPressed: () => _showCertificate(context),
                                icon: const Icon(Icons.zoom_in_rounded),
                                label: const Text('Посмотреть сертификат'),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const _Section(
                        title: 'Языки',
                        child: _Panel(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              _Language(
                                name: 'Узбекский',
                                level: 'Родной',
                                value: 1,
                              ),
                              SizedBox(height: 24),
                              _Language(
                                name: 'Русский',
                                level: 'Продвинутый',
                                value: .95,
                              ),
                              SizedBox(height: 24),
                              _Language(
                                name: 'Английский',
                                level: 'Базовый',
                                value: .4,
                              ),
                            ],
                          ),
                        ),
                      ),
                      _Section(
                        key: _sectionKeys[PortfolioSection.contacts],
                        title: 'Контакты',
                        subtitle: 'Свяжитесь со мной удобным способом',
                        child: const _Panel(
                          child: Column(
                            children: [
                              _Contact(
                                icon: Icons.mail_outline_rounded,
                                label: 'Электронная почта',
                                actionLabel: 'Написать',
                                value: 'abddavlat2@gmail.com',
                                uri: 'mailto:abddavlat2@gmail.com',
                              ),
                              Divider(height: 32),
                              _Contact(
                                icon: Icons.phone_outlined,
                                label: 'Телефон',
                                actionLabel: 'Позвонить',
                                value: '+998 (94) 582 71 71',
                                uri: 'tel:+998945827171',
                              ),
                              Divider(height: 32),
                              _Contact(
                                icon: Icons.code_rounded,
                                label: 'GitHub',
                                actionLabel: 'Открыть GitHub',
                                value: 'github.com/Davichik353',
                                uri: 'https://github.com/Davichik353',
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(height: 40),
                      const Text(
                        'Абдурасулов Давлатбек · Сделано на Flutter',
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _Intro extends StatelessWidget {
  const _Intro({super.key, required this.onProjects});
  final VoidCallback onProjects;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final profile = Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Flutter / Dart / Python',
          style: theme.textTheme.titleMedium?.copyWith(
            color: theme.colorScheme.primary,
          ),
        ),
        const SizedBox(height: 12),
        Text('Абдурасулов Давлатбек', style: theme.textTheme.headlineLarge),
        const SizedBox(height: 12),
        Text('Full-Stack Developer', style: theme.textTheme.titleLarge),
        const SizedBox(height: 20),
        const Text(
          'Создаю мобильные приложения на Flutter, работаю с API и пишу на Dart и Python. '
          'Интересуюсь UI/UX, анимациями, нейросетями, блокчейном и backend-разработкой. '
          'Продолжаю учиться и осваивать новые технологии.',
          style: TextStyle(fontSize: 16, height: 1.6),
        ),
        const SizedBox(height: 24),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            FilledButton.icon(
              onPressed: onProjects,
              icon: const Icon(Icons.apps_rounded),
              label: const Text('Смотреть проекты'),
            ),
            OutlinedButton.icon(
              onPressed: () => openExternalLink(
                context,
                Uri.parse('mailto:abddavlat2@gmail.com'),
              ),
              icon: const Icon(Icons.mail_outline_rounded),
              label: const Text('Написать мне'),
            ),
          ],
        ),
      ],
    );
    final avatar = Semantics(
      image: true,
      label: 'Пиксельный аватар Davichik353',
      child: Container(
        width: 160,
        height: 160,
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: theme.colorScheme.primaryContainer,
          borderRadius: BorderRadius.circular(32),
        ),
        child: Image.asset(
          'assets/images/avatar.png',
          excludeFromSemantics: true,
        ),
      ),
    );
    return _Panel(
      child: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 650 ||
              MediaQuery.textScalerOf(context).scale(16) > 22) {
            return Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [avatar, const SizedBox(height: 24), profile],
            );
          }
          return Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(child: profile),
              const SizedBox(width: 40),
              avatar,
            ],
          );
        },
      ),
    );
  }
}

class _Section extends StatelessWidget {
  const _Section({
    super.key,
    required this.title,
    required this.child,
    this.subtitle,
  });
  final String title;
  final String? subtitle;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 40),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Semantics(
          header: true,
          child: Text(title, style: Theme.of(context).textTheme.headlineSmall),
        ),
        if (subtitle != null) ...[const SizedBox(height: 8), Text(subtitle!)],
        const SizedBox(height: 20),
        child,
      ],
    ),
  );
}

class _Panel extends StatelessWidget {
  const _Panel({required this.child});
  final Widget child;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(24),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surface,
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      borderRadius: BorderRadius.circular(20),
    ),
    child: child,
  );
}

class _ResponsivePair extends StatelessWidget {
  const _ResponsivePair({required this.children});
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => LayoutBuilder(
    builder: (context, constraints) {
      final twoColumns =
          constraints.maxWidth >= 760 &&
          MediaQuery.textScalerOf(context).scale(16) <= 22;
      return Wrap(
        spacing: 20,
        runSpacing: 20,
        children: [
          for (final child in children)
            SizedBox(
              width: twoColumns
                  ? (constraints.maxWidth - 20) / 2
                  : constraints.maxWidth,
              child: child,
            ),
        ],
      );
    },
  );
}

class _SkillTag extends StatelessWidget {
  const _SkillTag(this.label);
  final String label;

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(8),
      border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
    ),
    child: Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      child: Text(label),
    ),
  );
}

class _Experience extends StatelessWidget {
  const _Experience({
    required this.title,
    required this.period,
    required this.icon,
    required this.details,
  });
  final String title;
  final String period;
  final IconData icon;
  final List<String> details;

  @override
  Widget build(BuildContext context) => ExpansionTile(
    tilePadding: EdgeInsets.zero,
    childrenPadding: const EdgeInsets.only(top: 8, bottom: 12),
    leading: Icon(icon, color: Theme.of(context).colorScheme.primary),
    title: Text(title),
    subtitle: Text(period),
    expandedCrossAxisAlignment: CrossAxisAlignment.start,
    children: [
      for (final detail in details)
        Padding(
          padding: const EdgeInsets.only(bottom: 8),
          child: Text('• $detail'),
        ),
    ],
  );
}

class _Education extends StatelessWidget {
  const _Education({
    required this.title,
    required this.subtitle,
    required this.date,
  });
  final String title;
  final String subtitle;
  final String date;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Icon(Icons.school_outlined, color: Theme.of(context).colorScheme.primary),
      const SizedBox(height: 16),
      Text(title, style: Theme.of(context).textTheme.titleLarge),
      const SizedBox(height: 8),
      Text(subtitle),
      const SizedBox(height: 8),
      Text(date),
    ],
  );
}

class _Language extends StatelessWidget {
  const _Language({
    required this.name,
    required this.level,
    required this.value,
  });
  final String name;
  final String level;
  final double value;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Text('$name · $level'),
      const SizedBox(height: 8),
      Semantics(
        label: '$name: $level',
        child: LinearProgressIndicator(
          value: value,
          minHeight: 6,
          borderRadius: BorderRadius.circular(4),
        ),
      ),
    ],
  );
}

class _Contact extends StatelessWidget {
  const _Contact({
    required this.icon,
    required this.label,
    required this.actionLabel,
    required this.value,
    required this.uri,
  });
  final IconData icon;
  final String label;
  final String actionLabel;
  final String value;
  final String uri;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.start,
    children: [
      Row(
        children: [
          Icon(icon, color: Theme.of(context).colorScheme.primary),
          const SizedBox(width: 12),
          Expanded(child: Text(label)),
        ],
      ),
      const SizedBox(height: 8),
      SelectableText(value),
      const SizedBox(height: 8),
      Wrap(
        spacing: 8,
        children: [
          TextButton.icon(
            onPressed: () => openExternalLink(context, Uri.parse(uri)),
            icon: const Icon(Icons.open_in_new_rounded, size: 18),
            label: Text(actionLabel),
          ),
          IconButton(
            tooltip: 'Копировать $label',
            onPressed: () => copyText(context, value),
            icon: const Icon(Icons.copy_outlined, size: 20),
          ),
        ],
      ),
    ],
  );
}

void _showCertificate(BuildContext context) {
  showDialog<void>(
    context: context,
    builder: (context) => Dialog.fullscreen(
      child: Scaffold(
        appBar: AppBar(
          leading: IconButton(
            tooltip: 'Закрыть сертификат',
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close),
          ),
          title: const Text('Сертификат'),
        ),
        body: SafeArea(
          child: Column(
            children: [
              Expanded(
                child: InteractiveViewer(
                  minScale: 1,
                  maxScale: 5,
                  child: Center(
                    child: Image.asset(
                      'assets/certificates/certificate.png',
                      fit: BoxFit.contain,
                      semanticLabel:
                          'Сертификат Mobile App Development Абдурасулова Давлатбека',
                      errorBuilder: (context, error, stack) => const Padding(
                        padding: EdgeInsets.all(24),
                        child: Text(
                          'Не удалось загрузить сертификат. Попробуйте открыть его снова.',
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  'Масштаб: жест двумя пальцами или колесо мыши',
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

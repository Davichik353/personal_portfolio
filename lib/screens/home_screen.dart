// lib/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Моё портфолио")),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // 👤 О себе
              Row(
                children: [
                  const CircleAvatar(
                    backgroundImage: AssetImage("assets/images/avatar.png"),
                    radius: 60,
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Абдурасулов Давлатбек",
                          style: GoogleFonts.poppins(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        Text(
                          "Junior Programmer",
                          style: GoogleFonts.poppins(
                            fontSize: 22,
                            color: Colors.grey[700],
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          "Молодой и целеустремленный разработчик с уверенными знаниями в Dart и Python. Умею создавать мобильные приложения на Flutter, работать с API, интегрировать нейросети и криптотехнологии. Владею навыками проектирования UI/UX, создания анимаций и backend-разработки. Стремлюсь осваивать новые технологии и участвовать в инновационных проектах.",
                          style: GoogleFonts.poppins(fontSize: 16),
                        ),
                      ],
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 💼 Профессиональный опыт
              Text(
                "Профессиональный опыт",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.work_outline,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  "Оператор в UCELL",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text("Апрель 2025 - текущий"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showExperienceDetails(context, "Оператор в UCELL", """
• Обеспечивал поддержку клиентов и техническую помощь.
• Выполнял активацию SIM-карт и устранял неполадки.
• Поддерживал высокий уровень удовлетворенности клиентов.
""");
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.design_services_rounded,
                  color: Colors.green,
                ),
                title: Text(
                  "Графический дизайнер",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text("Копицентре | Январь 2025 - Апрель 2025"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showExperienceDetails(context, "Графический дизайнер", """
• Управлял печатными заказами и задачами по обработке фотографий.
• Использовал Adobe Photoshop для манипуляции изображениями и дизайна.
""");
                },
              ),

              const SizedBox(height: 30),

              // 📁 Проекты
              Text(
                "Проекты",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.code,
                  size: 40,
                  color: Colors.blueAccent,
                ),
                title: Text(
                  "Weather App",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text("Погода с фоном города и анимациями"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _launchURL(
                    context,
                    "https://github.com/Davichik353/weather_app_1",
                  );
                },
              ),
              ListTile(
                leading: const Icon(
                  Icons.compass_calibration,
                  size: 40,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "AR Compass",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text("Компас с поворотом по направлению"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _launchURL(
                    context,
                    "https://github.com/Davichik353/ar_compass",
                  );
                },
              ),
              ElevatedButton.icon(
                onPressed: () {
                  _launchURL(
                    context,
                    "https://github.com/Davichik353?tab=repositories",
                  );
                },
                icon: const Icon(Icons.all_inclusive),
                label: const Text("Все проекты на GitHub"),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.deepPurple,
                  foregroundColor: Colors.white,
                ),
              ),

              const SizedBox(height: 30),

              // 📜 Сертификаты
              Text(
                "Сертификаты",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              ListTile(
                leading: const Icon(
                  Icons.image,
                  size: 40,
                  color: Colors.redAccent,
                ),
                title: Text(
                  "Mobile App Development",
                  style: TextStyle(color: Colors.black),
                ),
                subtitle: const Text("NEMNIG IT AKADEMIYA"),
                trailing: const Icon(Icons.arrow_forward_ios),
                onTap: () {
                  _showCertificateImage(context);
                },
              ),

              const SizedBox(height: 30),

              // 💡 Навыки
              Text(
                "Навыки",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  Chip(label: Text("Dart (85%)")),
                  Chip(label: Text("Python (70%)")),
                  Chip(label: Text("UI/UX дизайн (80%)")),
                  Chip(label: Text("Нейросети (89%)")),
                  Chip(label: Text("Блокчейн (65%)")),
                  Chip(label: Text("Adobe Photoshop (77%)")),
                  Chip(label: Text("MS Office (90%)")),
                  Chip(label: Text("Git (70%)")),
                  Chip(label: Text("JavaScript (50%)")),
                  Chip(
                    label: Text(
                      "Работа с командами (Trello, Jira, Slack) (60%)",
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 🏫 Образование
              Text(
                "Образование",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Text(
                "Аттестат о среднем образовании, Самаркандская областная школа\n"
                "Окончил в 2022 году",
                style: GoogleFonts.poppins(fontSize: 16),
              ),
              const SizedBox(height: 10),
              Text(
                "Курс по программированию на Dart, Центр обучения в Навои\n"
                "Завершил в Май 2023 года",
                style: GoogleFonts.poppins(fontSize: 16),
              ),

              const SizedBox(height: 30),

              // 🌍 Языки
              Text(
                "Языки",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text("Русский", style: GoogleFonts.poppins(fontSize: 16)),
                      CircularProgressIndicator(
                        value: 0.95,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.blue,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Узбекский",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      CircularProgressIndicator(
                        value: 1.0,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.green,
                        ),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        "Английский",
                        style: GoogleFonts.poppins(fontSize: 16),
                      ),
                      CircularProgressIndicator(
                        value: 0.4,
                        backgroundColor: Colors.grey[300],
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Colors.orange,
                        ),
                      ),
                    ],
                  ),
                ],
              ),

              const SizedBox(height: 30),

              // 📬 Контакты
              Text(
                "Контакты",
                style: GoogleFonts.poppins(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.phone, color: Colors.green),
                  const SizedBox(width: 10),
                  Text("+998 (94) 582 71 71"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.email, color: Colors.blue),
                  const SizedBox(width: 10),
                  Text("abddavlat2@gmail.com"),
                ],
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Icon(Icons.public, color: Colors.red),
                  const SizedBox(width: 10),
                  Text("github.com/Davichik353"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchURL(BuildContext context, String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    } else {
      // ignore: avoid_print
      print("Не удалось открыть ссылку $url");
    }
  }

  void _showCertificateImage(BuildContext context) {
    try {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text("Сертификат"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Image.asset(
                "assets/certificates/certificate.png",
                width: 300,
                height: 400,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) {
                  return const Text(
                    "Фото сертификата не найдено",
                    textAlign: TextAlign.center,
                  );
                },
              ),
              const SizedBox(height: 10),
              const Text(
                "Вы успешно завершили курс «Mobile App Development» в NEMNIG IT AKADEMIYA",
                textAlign: TextAlign.center,
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: Navigator.of(context).pop,
              child: const Text("Закрыть"),
            ),
          ],
        ),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Ошибка загрузки сертификата: $e")),
      );
    }
  }

  void _showExperienceDetails(
    BuildContext context,
    String title,
    String details,
  ) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(title),
        content: Text(details),
        actions: [
          TextButton(
            onPressed: Navigator.of(context).pop,
            child: const Text("Закрыть"),
          ),
        ],
      ),
    );
  }
}

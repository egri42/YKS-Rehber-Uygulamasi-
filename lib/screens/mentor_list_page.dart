import 'package:flutter/material.dart';
import 'dart:ui';
import 'chat_page.dart';

class MentorModel {
  final String id;
  final String name;
  final String title;
  final String description;
  final String avatarUrl;
  final Color themeColor;
  final String welcomeMessage;
  final String autoReplyMessage;

  MentorModel({
    required this.id,
    required this.name,
    required this.title,
    required this.description,
    required this.avatarUrl,
    required this.themeColor,
    required this.welcomeMessage,
    required this.autoReplyMessage,
  });
}

class MentorListPage extends StatelessWidget {
  MentorListPage({super.key});

  final List<MentorModel> _mentors = [
    MentorModel(
      id: "m1",
      name: "Dr. Alperen Yılmaz",
      title: "Bilişsel Performans & Analitik Stratejisti",
      description:
          "Hibrit Karar Destek sistemleriyle çalışır. Deneme analizlerini veri bilimi ve kognitif psikoloji ile harmanlayarak size özel algoritmik bir çalışma programı çizer.",
      avatarUrl: "https://api.dicebear.com/9.x/initials/png?seed=AY&backgroundColor=3B82F6",
      themeColor: const Color(0xFF3B82F6), // Mavi
      welcomeMessage: "Selamlar! Ben Alperen Hoca. Deneme netlerinle ilgili bir analize mi ihtiyacımız var, yoksa algoritmanı baştan mı tasarlıyoruz?",
      autoReplyMessage: "Şu an başka bir öğrencinin veri analiz raporunu inceliyorum. Lütfen son deneme netlerini ve takıldığın yeri detaylıca yaz, raporum biter bitmez hemen ilgileneceğim.",
    ),
    MentorModel(
      id: "m2",
      name: "Uzm. Psk. Zeynep Arslan",
      title: "Klinik Psikolog & Sınav Stratejisti",
      description:
          "Sınav kaygısı ve odaklanma problemlerini bilişsel davranışçı teknikler ve bilimsel Pomodoro metotlarıyla çözer. Mental dayanıklılık (Mental Toughness) koçudur.",
      avatarUrl: "https://api.dicebear.com/9.x/initials/png?seed=ZA&backgroundColor=10B981",
      themeColor: const Color(0xFF10B981), // Yeşil
      welcomeMessage: "Merhaba, ben Zeynep. Sınav stresi, odaklanma problemi ya da sadece anlatıp rahatlamak istediğin bir şey varsa seni dinlemeye hazırım. Bugün nasılsın?",
      autoReplyMessage: "Harika bir adım attın. Şu an bir danışanımla seanstayım ama mesajını okumak için sabırsızlanıyorum. Lütfen hissettiklerini yaz, seansım biter bitmez buradayım.",
    ),
    MentorModel(
      id: "m3",
      name: "Kaan Erdem (Türkiye 12.si)",
      title: "Derece Koçu & Zaman Yönetimi Uzmanı",
      description:
          "Boğaziçi Bilgisayar Mühendisliği öğrencisi. YKS sürecinde kendi kullandığı 'Deep Work' (Derin Çalışma) ve hafıza çivileme tekniklerini yeni derece adaylarına aktarır.",
      avatarUrl: "https://api.dicebear.com/9.x/initials/png?seed=KE&backgroundColor=F59E0B",
      themeColor: const Color(0xFFF59E0B), // Turuncu
      welcomeMessage: "Naber dostum! Ben Kaan. YKS'de derece yapmak o kadar da korkutucu değil, sadece doğru taktiğe ihtiyacın var. Hangi derste zorlanıyorsun?",
      autoReplyMessage: "Dostum şu an dersteyim (Boğaziçi affetmez biliyorsun 😅). Sen netlerini ve takıldığın yeri aşağıya bırak, çıkışta sana dönüş yapacağım. Deep Work'e devam!",
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          "Özel Mentorlar",
          style: TextStyle(
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
        elevation: 0,
        iconTheme: const IconThemeData(color: Color(0xFF0F172A)),
      ),
      body: Stack(
        children: [
          // Arka plan
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFF8FAFC)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          SafeArea(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              physics: const BouncingScrollPhysics(),
              itemCount: _mentors.length + 1, // +1 başlık için
              itemBuilder: (context, index) {
                if (index == 0) {
                  return Padding(
                    padding: const EdgeInsets.only(bottom: 24),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          "Sana Uygun Mentoru Seç",
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF4F46E5),
                          ),
                        ),
                        SizedBox(height: 8),
                        Text(
                          "Hedeflerine en uygun rehberi seç ve hemen mesajlaşmaya başla.",
                          style: TextStyle(
                            fontSize: 14,
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                }

                final mentor = _mentors[index - 1];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 16),
                  child: _buildMentorCard(context, mentor),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMentorCard(BuildContext context, MentorModel mentor) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(24),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: Container(
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.6),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.04),
                blurRadius: 10,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  CircleAvatar(
                    radius: 30,
                    backgroundColor: mentor.themeColor.withOpacity(0.2),
                    backgroundImage: NetworkImage(mentor.avatarUrl),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          mentor.name,
                          style: const TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const SizedBox(height: 2),
                        Text(
                          mentor.title,
                          style: TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: mentor.themeColor,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                mentor.description,
                style: const TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF475569),
                  height: 1.4,
                ),
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => ChatPage(mentor: mentor),
                      ),
                    );
                  },
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 20),
                  label: const Text(
                    "Sohbet Et",
                    style: TextStyle(fontWeight: FontWeight.w800),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: mentor.themeColor,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16),
                    ),
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
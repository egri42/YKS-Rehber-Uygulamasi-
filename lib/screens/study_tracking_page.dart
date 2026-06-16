import 'dart:ui';
import 'package:flutter/material.dart';
import 'dart:math';
import 'mentor_list_page.dart'; // Dosya yolun farklıysa ona göre düzenle
import '../plan_store.dart';

class StudyTrackingPage extends StatefulWidget {
  const StudyTrackingPage({super.key});

  @override
  State<StudyTrackingPage> createState() => _StudyTrackingPageState();
}

class _StudyTrackingPageState extends State<StudyTrackingPage> {
  bool isAylik = false;
  DateTime selectedMonth = DateTime.now();

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: PlanStore(),
      builder: (context, _) {
        final store = PlanStore();

        // Gerçek verileri hesapla
        final streak = store.guncelCalismaSerisi();

        final toplamDk = isAylik
            ? store.aylikTamamlananDakika(selectedMonth)
            : store.haftalikTamamlananDakika();
        final toplamPlanDk = isAylik
            ? store.aylikToplamPlanDakika(selectedMonth)
            : store.haftalikToplamPlanDakika();

        final chartData = isAylik
            ? store.aylikHaftalikTamamlananDakikalar(selectedMonth)
            : store.haftalikGunlukTamamlananDakikalar();

        final dersAnalizi = store.dersAnalizi(isAylik, selectedMonth);

        return Scaffold(
          extendBodyBehindAppBar: true,
          appBar: AppBar(
            title: const Text(
              'Performans Analizi',
              style: TextStyle(
                fontWeight: FontWeight.w900,
                color: Color(0xFF0F172A),
              ),
            ),
            centerTitle: true,
            backgroundColor: Colors.transparent,
            elevation: 0,
          ),
          body: Stack(
            children: [
              _buildBackground(),
              SafeArea(
                child: SingleChildScrollView(
                  physics: const BouncingScrollPhysics(),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24.0,
                    vertical: 20.0,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        "Analiz ve Öneriler",
                        style: TextStyle(
                          fontSize: 26,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const Text(
                        "Verilerine göre çalışma durumun aşağıda.",
                        style: TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 14,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 20),

                      _buildStreakCard(streak),
                      const SizedBox(height: 20),

                      _buildToggle(),
                      const SizedBox(height: 20),

                      if (isAylik) ...[
                        _buildMonthPicker(),
                        const SizedBox(height: 20),
                      ],

                      _buildStatsRow(toplamDk, toplamPlanDk, store),
                      const SizedBox(height: 25),

                      Text(
                        isAylik ? "Aylık Tempo (Haftalık)" : "Haftalık Tempo",
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildModernChart(chartData, isAylik),
                      const SizedBox(height: 35),

                      _buildSubjectAnalysis(dersAnalizi),

                      const Row(
                        children: [
                          Icon(
                            Icons.auto_awesome,
                            color: Color(0xFF4F46E5),
                            size: 20,
                          ),
                          SizedBox(width: 8),
                          Text(
                            "Senin Yol Haritan",
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF0F172A),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildMentorSuggestions(),
                      const SizedBox(height: 30),

                      // --- TAM AKTİF VE GÖRSEL GERİ BİLDİRİMLİ BUTON ---
                      _buildConsultMentorButton(context),

                      const SizedBox(height: 50),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildConsultMentorButton(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          // ARTIK AKTİF: Bu satır seni diğer sayfaya fırlatacak
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => MentorListPage()),
          );
        },
        borderRadius: BorderRadius.circular(20),
        child: Ink(
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [Color(0xFF4F46E5), Color(0xFF6366F1)],
              begin: Alignment.centerLeft,
              end: Alignment.centerRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF4F46E5).withOpacity(0.4),
                blurRadius: 15,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: const Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.auto_awesome, color: Colors.white, size: 22),
                SizedBox(width: 12),
                Text(
                  "Özel Mentore Danış",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 17,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildStreakCard(int streak) {
    return _glassBox(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Text("🔥", style: TextStyle(fontSize: 26)),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Çalışma Serisi",
                  style: TextStyle(
                    fontSize: 13,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  streak > 0
                      ? "$streak Gündür Aralıksız Çalışıyorsun!"
                      : "Seriyi başlatmak için plan tamamla.",
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: Color(0xFF0F172A),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.5),
        borderRadius: BorderRadius.circular(16),
      ),
      padding: const EdgeInsets.all(6),
      child: Row(
        children: [
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isAylik = false),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: !isAylik ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: !isAylik
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Haftalık",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: !isAylik
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
          Expanded(
            child: GestureDetector(
              onTap: () => setState(() => isAylik = true),
              child: Container(
                padding: const EdgeInsets.symmetric(vertical: 12),
                decoration: BoxDecoration(
                  color: isAylik ? Colors.white : Colors.transparent,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: isAylik
                      ? [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.05),
                            blurRadius: 4,
                          ),
                        ]
                      : [],
                ),
                alignment: Alignment.center,
                child: Text(
                  "Aylık",
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 15,
                    color: isAylik
                        ? const Color(0xFF4F46E5)
                        : const Color(0xFF64748B),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMonthPicker() {
    final months = [
      "Ocak",
      "Şubat",
      "Mart",
      "Nisan",
      "Mayıs",
      "Haziran",
      "Temmuz",
      "Ağustos",
      "Eylül",
      "Ekim",
      "Kasım",
      "Aralık",
    ];
    final monthName = months[selectedMonth.month - 1];
    final year = selectedMonth.year;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month - 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_left, color: Color(0xFF4F46E5)),
        ),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.5),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Text(
            "$monthName $year",
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 16,
              color: Color(0xFF0F172A),
            ),
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              selectedMonth = DateTime(
                selectedMonth.year,
                selectedMonth.month + 1,
                1,
              );
            });
          },
          icon: const Icon(Icons.chevron_right, color: Color(0xFF4F46E5)),
        ),
      ],
    );
  }

  Widget _buildSubjectAnalysis(Map<String, int> dersAnalizi) {
    if (dersAnalizi.isEmpty) {
      return const SizedBox.shrink();
    }

    final sortedList = dersAnalizi.entries.toList()
      ..sort((a, b) => b.value.compareTo(a.value)); // descending

    final enCok = sortedList.first;
    final enAz = sortedList.last;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text(
          "Ders Analizi",
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w900,
            color: Color(0xFF0F172A),
          ),
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(child: _subjectCard(enCok.key, enCok.value, true)),
            const SizedBox(width: 12),
            Expanded(child: _subjectCard(enAz.key, enAz.value, false)),
          ],
        ),
        const SizedBox(height: 35),
      ],
    );
  }

  Widget _subjectCard(String name, int dk, bool isTop) {
    final saat = dk ~/ 60;
    final dakika = dk % 60;
    final timeStr = saat > 0 ? "${saat}s ${dakika}dk" : "${dakika}dk";

    return _glassBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(
                isTop ? Icons.trending_up : Icons.trending_down,
                color: isTop ? Colors.green : Colors.redAccent,
                size: 20,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  isTop ? "En Çok" : "En Az",
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: Color(0xFF64748B),
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            name.isEmpty ? "Belirtilmemiş" : name,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: Color(0xFF0F172A),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            timeStr,
            style: const TextStyle(
              fontSize: 13,
              fontWeight: FontWeight.w700,
              color: Color(0xFF4F46E5),
            ),
          ),
        ],
      ),
    );
  }

  // Mentor önerileri — kullanıcının gerçek verilerine göre dinamik
  Widget _buildMentorSuggestions() {
    final store = PlanStore();

    // --- 1) GÜNLÜK ÖNERİ: Bugün yapılmamış planlar ---
    final yapilmamislar = store.yapilmamisGorevler();
    String gunlukOneri;
    IconData gunlukIcon;
    Color gunlukColor;

    if (yapilmamislar.isEmpty) {
      gunlukOneri =
          "Bugün tüm planlarını tamamladın! 🎉 Harika gidiyorsun, bu performansı koru.";
      gunlukIcon = Icons.check_circle_rounded;
      gunlukColor = const Color(0xFF10B981);
    } else {
      final toplamYapilmamisDk = yapilmamislar.values.fold(0, (a, b) => a + b);
      final dersListesi = yapilmamislar.keys.toList();
      final saatStr = toplamYapilmamisDk >= 60
          ? "${toplamYapilmamisDk ~/ 60} saat ${toplamYapilmamisDk % 60 > 0 ? '${toplamYapilmamisDk % 60} dk' : ''}"
          : "$toplamYapilmamisDk dk";
      if (dersListesi.length == 1) {
        gunlukOneri =
            "Hâlâ $saatStr'lık ${dersListesi.first} planın var. Bir adım atarsan gerisini halledersin 💪";
      } else {
        final tumDersler = dersListesi.join(', ');
        gunlukOneri =
            "Bugün $tumDersler derslerinden toplam $saatStr'lık çalışma seni bekliyor. Küçük bir başlangıç bile fark yaratır! ✨";
      }
      gunlukIcon = Icons.assignment_late_rounded;
      gunlukColor = Colors.orange.shade700;
    }

    // --- 2) HAFTALIK ÖNERİ: En az çalışılan ders ---
    final haftalikSirali = store.haftalikAzCalisilanDersler();
    String haftalikOneri;
    IconData haftalikIcon;
    Color haftalikColor;

    if (haftalikSirali.isEmpty) {
      haftalikOneri =
          "Bu hafta henüz plan verisi yok. Plan ekleyerek çalışma düzenini oluştur.";
      haftalikIcon = Icons.info_outline_rounded;
      haftalikColor = const Color(0xFF64748B);
    } else {
      final enAz = haftalikSirali.first;
      final enCok = haftalikSirali.last;
      if (enAz.value == 0) {
        haftalikOneri =
            "Bu hafta ${enAz.key} dersine hiç vakit ayırmadın! Dengeyi kurman için bu derse öncelik ver.";
      } else {
        final fark = enCok.value - enAz.value;
        final farkSaat = fark ~/ 60;
        final farkDk = fark % 60;
        final farkStr = farkSaat > 0
            ? "${farkSaat}s ${farkDk}dk"
            : "${farkDk}dk";
        haftalikOneri =
            "${enAz.key} dersine bu hafta en az vakit ayırdın. ${enCok.key} ile arasında $farkStr fark var. Dengeyi sağla!";
      }
      haftalikIcon = Icons.balance_rounded;
      haftalikColor = const Color(0xFF3B82F6);
    }

    // --- 3) AYLIK ÖNERİ: Geçen aya kıyasla düşen dersler ---
    final aylikFarklar = store.aylikKarsilastirma();
    String aylikOneri;
    IconData aylikIcon;
    Color aylikColor;

    if (aylikFarklar.isEmpty) {
      aylikOneri =
          "Henüz aylık karşılaştırma için yeterli veri yok. Düzenli çalışmaya devam et!";
      aylikIcon = Icons.info_outline_rounded;
      aylikColor = const Color(0xFF64748B);
    } else {
      // En çok düşen dersi bul (negatif fark)
      final enCokDusen = aylikFarklar.first; // zaten ascending sıralı
      if (enCokDusen.value < 0) {
        final dususDk = enCokDusen.value.abs();
        final dususSaat = dususDk ~/ 60;
        final dususDkKalan = dususDk % 60;
        final dususStr = dususSaat > 0
            ? "${dususSaat}s ${dususDkKalan}dk"
            : "${dususDkKalan}dk";
        aylikOneri =
            "${enCokDusen.key} dersinde geçen aya göre $dususStr daha az çalıştın. Bu dersi aksatma, geri dönüş yap!";
        aylikIcon = Icons.trending_down_rounded;
        aylikColor = Colors.redAccent;
      } else if (enCokDusen.value == 0) {
        // Hiç değişiklik yok
        final enCokArtan = aylikFarklar.last;
        if (enCokArtan.value > 0) {
          aylikOneri =
              "${enCokArtan.key} dersinde geçen aya göre ilerleme var, harika! Diğer dersleri de bu tempoya getir.";
        } else {
          aylikOneri =
              "Bu ay ve geçen ay arasında ders çalışma sürelerin aynı. Hedeflerini büyütmeyi düşün!";
        }
        aylikIcon = Icons.swap_horiz_rounded;
        aylikColor = const Color(0xFF8B5CF6);
      } else {
        // Tüm dersler artmış
        aylikOneri =
            "Tebrikler! 🚀 Bu ay tüm derslerde geçen aya göre daha fazla çalıştın. Bu ivmeyi kaybetme!";
        aylikIcon = Icons.rocket_launch_rounded;
        aylikColor = const Color(0xFF10B981);
      }
    }

    // --- 4) KONU BAZLI ÖNERİ: Bu hafta aksatılan konular ---
    final aksatilanKonular = store.haftaninAksatilanKonulari();
    String konuOneri;
    IconData konuIcon;
    Color konuColor;

    if (aksatilanKonular.isEmpty) {
      konuOneri =
          "Bu hafta planladığın tüm konulara çalışmışsın, süpersin! 🏆 Böyle devam et.";
      konuIcon = Icons.verified_rounded;
      konuColor = const Color(0xFF10B981);
    } else {
      final ilk = aksatilanKonular.first;
      final konuAdi = (ilk['konu'] as String).isNotEmpty
          ? ilk['konu'] as String
          : 'Belirtilmemiş';
      final dersAdi = ilk['ders'] as String;
      final planSure = ilk['planSure'] as int;

      if (aksatilanKonular.length == 1) {
        konuOneri =
            "$dersAdi dersinde \"$konuAdi\" konusuna $planSure dk ayırmıştın ama neredeyse hiç çalışmadın. Bu konuya bugün göz at! 👀";
      } else {
        final ikinciKonu = aksatilanKonular[1];
        final ikinciAd = (ikinciKonu['konu'] as String).isNotEmpty
            ? ikinciKonu['konu'] as String
            : 'Belirtilmemiş';
        konuOneri =
            "Bu hafta \"$konuAdi\" ve \"$ikinciAd\" konularını aksattın. Planına eklediğin konuları tamamlamayı hedefle! 🎯";
      }
      konuIcon = Icons.topic_rounded;
      konuColor = const Color(0xFFEA580C);
    }

    // --- 5) TEKRAR ÖNERİSİ: Uzun süredir çalışılmayan konular ---
    final eskiKonular = store.uzunSuredirCalisilmayanKonular();
    String tekrarOneri;
    IconData tekrarIcon;
    Color tekrarColor;

    if (eskiKonular.isEmpty) {
      tekrarOneri =
          "Tüm konularını düzenli tekrar ediyorsun, hafızan sağlam kalacak! 🧠";
      tekrarIcon = Icons.psychology_rounded;
      tekrarColor = const Color(0xFF10B981);
    } else {
      final ilk = eskiKonular.first;
      final konuAdi = ilk['konu'] as String;
      final dersAdi = ilk['ders'] as String;
      final gunOnce = ilk['gunOnce'] as int;

      if (gunOnce >= 99) {
        tekrarOneri =
            "\"$konuAdi\" ($dersAdi) konusunu hiç tamamlamamışsın. Unutmadan bu konuyu çalışma planına al! 📌";
      } else if (gunOnce >= 10) {
        tekrarOneri =
            "\"$konuAdi\" ($dersAdi) konusuna $gunOnce gündür dokunmadın! Unutma eğrisi seni yakalamadan tekrar et 🔄";
      } else {
        tekrarOneri =
            "\"$konuAdi\" ($dersAdi) konusuna $gunOnce gündür bakmadın. Kısa bir tekrar bile kalıcılığı artırır 📖";
      }
      tekrarIcon = Icons.replay_rounded;
      tekrarColor = const Color(0xFFDC2626);
    }

    return Column(
      children: [
        // Günlük öneri
        _animatedSuggestionCard(
          text: gunlukOneri,
          icon: gunlukIcon,
          color: gunlukColor,
          label: "GÜNLÜK",
          labelColor: Colors.orange,
        ),
        const SizedBox(height: 12),
        // Haftalık öneri
        _animatedSuggestionCard(
          text: haftalikOneri,
          icon: haftalikIcon,
          color: haftalikColor,
          label: "HAFTALIK",
          labelColor: const Color(0xFF3B82F6),
        ),
        const SizedBox(height: 12),
        // Aylık öneri
        _animatedSuggestionCard(
          text: aylikOneri,
          icon: aylikIcon,
          color: aylikColor,
          label: "AYLIK",
          labelColor: const Color(0xFF8B5CF6),
        ),
        const SizedBox(height: 12),
        // Konu bazlı aksatma önerisi
        _animatedSuggestionCard(
          text: konuOneri,
          icon: konuIcon,
          color: konuColor,
          label: "KONU TAKİP",
          labelColor: const Color(0xFFEA580C),
        ),
        const SizedBox(height: 12),
        // Tekrar önerisi
        _animatedSuggestionCard(
          text: tekrarOneri,
          icon: tekrarIcon,
          color: tekrarColor,
          label: "TEKRAR",
          labelColor: const Color(0xFFDC2626),
        ),
      ],
    );
  }

  Widget _animatedSuggestionCard({
    required String text,
    required IconData icon,
    required Color color,
    required String label,
    required Color labelColor,
  }) {
    return _glassBox(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Üst kısım: etiket + ikon
          Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: labelColor.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Text(
                  label,
                  style: TextStyle(
                    fontSize: 10,
                    fontWeight: FontWeight.w900,
                    color: labelColor,
                    letterSpacing: 1.2,
                  ),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: color.withOpacity(0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 22),
              ),
            ],
          ),
          const SizedBox(height: 12),
          // Alt kısım: öneri metni
          Text(
            text,
            style: const TextStyle(
              fontSize: 14,
              fontWeight: FontWeight.w600,
              color: Color(0xFF1E293B),
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildModernChart(List<int> data, bool isAylik) {
    int maxDk = data.isEmpty ? 1 : data.reduce(max);
    if (maxDk == 0) maxDk = 1; // Sıfıra bölmeyi engelle

    int bugunIndex = DateTime.now().weekday - 1;

    return _glassBox(
      height: 160,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: isAylik
            ? List.generate(
                4,
                (index) => _bar(
                  "H${index + 1}",
                  data[index] / maxDk,
                  isSelected: index == 0,
                ),
              ) // İlk haftayı şimdilik seçili yapalım
            : [
                _bar("P", data[0] / maxDk, isSelected: bugunIndex == 0),
                _bar("S", data[1] / maxDk, isSelected: bugunIndex == 1),
                _bar("Ç", data[2] / maxDk, isSelected: bugunIndex == 2),
                _bar("P", data[3] / maxDk, isSelected: bugunIndex == 3),
                _bar("C", data[4] / maxDk, isSelected: bugunIndex == 4),
                _bar("C", data[5] / maxDk, isSelected: bugunIndex == 5),
                _bar("P", data[6] / maxDk, isSelected: bugunIndex == 6),
              ],
      ),
    );
  }

  Widget _bar(String label, double height, {bool isSelected = false}) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        Container(
          width: 8,
          height: 80 * height,
          decoration: BoxDecoration(
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFF94A3B8).withOpacity(0.2),
            borderRadius: BorderRadius.circular(10),
          ),
        ),
        const SizedBox(height: 12),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: isSelected ? FontWeight.w900 : FontWeight.w600,
            color: isSelected
                ? const Color(0xFF4F46E5)
                : const Color(0xFF64748B),
          ),
        ),
      ],
    );
  }

  Widget _buildStatsRow(int toplamDk, int toplamPlanDk, PlanStore store) {
    final toplamSaat = toplamDk / 60.0;

    // Günlük ortalama hesapla
    final gunSayisi = isAylik
        ? DateTime.now()
              .day // Ayın kaçıncı günüyse
        : DateTime.now().weekday; // Haftanın kaçıncı günüyse
    final gunlukOrtDk = gunSayisi > 0 ? toplamDk / gunSayisi : 0.0;
    final gunlukOrtSaat = gunlukOrtDk / 60.0;

    // Progress yüzdesi
    final yuzde = toplamPlanDk > 0
        ? (toplamDk / toplamPlanDk).clamp(0.0, 1.0)
        : 0.0;

    return Column(
      children: [
        // Üstte büyük hero kart
        _glassBox(
          padding: const EdgeInsets.all(24),
          child: Row(
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: const Icon(
                            Icons.timer_rounded,
                            color: Colors.white,
                            size: 18,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          isAylik ? "Aylık Çalışma" : "Haftalık Çalışma",
                          style: const TextStyle(
                            color: Color(0xFF64748B),
                            fontWeight: FontWeight.w700,
                            fontSize: 13,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    Row(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        ShaderMask(
                          shaderCallback: (bounds) => const LinearGradient(
                            colors: [Color(0xFF4F46E5), Color(0xFF7C3AED)],
                          ).createShader(bounds),
                          child: Text(
                            toplamSaat.toStringAsFixed(1),
                            style: const TextStyle(
                              fontSize: 44,
                              fontWeight: FontWeight.w900,
                              color: Colors.white,
                              height: 1,
                            ),
                          ),
                        ),
                        const Padding(
                          padding: EdgeInsets.only(bottom: 6, left: 4),
                          child: Text(
                            "saat",
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w800,
                              color: Color(0xFF7C3AED),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    // Mini progress bar
                    ClipRRect(
                      borderRadius: BorderRadius.circular(6),
                      child: LinearProgressIndicator(
                        value: yuzde,
                        minHeight: 6,
                        backgroundColor: const Color(
                          0xFF4F46E5,
                        ).withOpacity(0.1),
                        valueColor: const AlwaysStoppedAnimation<Color>(
                          Color(0xFF4F46E5),
                        ),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      "Hedefin %${(yuzde * 100).round()}'i tamamlandı",
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: const Color(0xFF64748B).withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 16),
              // Sağda dairesel çalışma göstergesi
              Container(
                padding: const EdgeInsets.all(4),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF4F46E5).withOpacity(0.15),
                      blurRadius: 20,
                      spreadRadius: 2,
                    ),
                  ],
                ),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    SizedBox(
                      width: 75,
                      height: 75,
                      child: CircularProgressIndicator(
                        value: yuzde,
                        strokeWidth: 7,
                        backgroundColor: const Color(
                          0xFF4F46E5,
                        ).withOpacity(0.08),
                        color: const Color(0xFF4F46E5),
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "%${(yuzde * 100).round()}",
                          style: const TextStyle(
                            fontWeight: FontWeight.w900,
                            fontSize: 16,
                            color: Color(0xFF0F172A),
                          ),
                        ),
                        const Text(
                          "oran",
                          style: TextStyle(
                            fontSize: 9,
                            fontWeight: FontWeight.w600,
                            color: Color(0xFF94A3B8),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        // Günlük ortalama kartı
        _miniStatCard(
          icon: Icons.trending_up_rounded,
          iconColor: const Color(0xFF10B981),
          label: "Günlük Ortalama",
          value: gunlukOrtSaat.toStringAsFixed(1),
          unit: "saat",
        ),
      ],
    );
  }

  Widget _miniStatCard({
    required IconData icon,
    required Color iconColor,
    required String label,
    required String value,
    required String unit,
  }) {
    return _glassBox(
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: iconColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, color: iconColor, size: 18),
          ),
          const SizedBox(height: 12),
          Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Color(0xFF94A3B8),
            ),
          ),
          const SizedBox(height: 4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                  height: 1,
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(bottom: 2, left: 3),
                child: Text(
                  unit,
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: iconColor,
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBackground() {
    return Container(
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFF8FAFC)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
    );
  }

  Widget _glassBox({
    required Widget child,
    EdgeInsetsGeometry? padding,
    double? height,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.4),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: child,
        ),
      ),
    );
  }
}

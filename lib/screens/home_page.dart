import 'dart:async';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'pomodoro_page.dart';
import 'puan_hesapla_page.dart';
import '../plan_store.dart';
import '../logic/study_session_store.dart';
import '../services/auth_service.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final PlanStore _store = PlanStore();
  final StudySessionStore _sessionStore = StudySessionStore();

  @override
  void initState() {
    super.initState();
    _store.addListener(_onStoreChanged);
    _sessionStore.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _sessionStore.removeListener(_onStoreChanged);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          _buildDynamicBackground(),
          CustomScrollView(
            physics: const BouncingScrollPhysics(),
            slivers: [
              _buildSliverAppBar(),
              SliverToBoxAdapter(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 24),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 20),
                      _buildYKSCountdownCard(),
                      const SizedBox(height: 25),
                      _buildGlassPredictorCard(context),
                      const SizedBox(height: 35),
                      const Text(
                        "Sıradaki Görev",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildNextTaskCard(context),
                      const SizedBox(height: 35),
                      const Text(
                        "Verimlilik Analizi",
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w900,
                          color: Color(0xFF0F172A),
                        ),
                      ),
                      const SizedBox(height: 16),
                      _buildEnhancedEfficiencySection(),
                      const SizedBox(height: 100),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // --- ÜST BAR ---
  Widget _buildSliverAppBar() {
    return SliverAppBar(
      expandedHeight: 120,
      floating: true,
      backgroundColor: Colors.transparent,
      elevation: 0,
      flexibleSpace: FlexibleSpaceBar(
        background: Container(
          padding: const EdgeInsets.fromLTRB(24, 55, 24, 0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    "Selam ${AuthService().currentUser?.email?.split('@')[0] ?? 'Öğrenci'},",
                    style: const TextStyle(
                      color: Color(0xFF475569),
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "Bugün Hazır mısın?",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: -0.5,
                    ),
                  ),
                ],
              ),
              _glassContainer(
                height: 38,
                borderRadius: 18,
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Text("🔥", style: TextStyle(fontSize: 13)),
                    const SizedBox(width: 4),
                    Text(
                      "Seri: ${_store.guncelCalismaSerisi()}",
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 12,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  await AuthService().logout();
                },
                icon: const Icon(
                  Icons.logout_rounded,
                  color: Color(0xFF4F46E5),
                ),
                tooltip: 'Çıkış Yap',
              ),
            ],
          ),
        ),
      ),
    );
  }

  // --- YKS SAYACI ---
  Widget _buildYKSCountdownCard() {
    return const _YKSCountdownWidget();
  }

  // --- CAM KONTEYNER ---
  Widget _glassContainer({
    required Widget child,
    required double borderRadius,
    EdgeInsetsGeometry? padding,
    double? width,
    double? height,
    Color? backgroundColor,
  }) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(borderRadius),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          width: width,
          height: height,
          padding: padding,
          decoration: BoxDecoration(
            color: backgroundColor ?? Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(borderRadius),
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

  // --- AKILLI SIRADAKİ GÖREV KARTI ---
  Widget _buildNextTaskCard(BuildContext context) {
    final PlanModel? siradaki = _store.siradakiGorev();

    if (siradaki == null) {
      // Plan yoksa boş durum
      return _glassContainer(
        padding: const EdgeInsets.all(22),
        borderRadius: 28,
        backgroundColor: Colors.white.withOpacity(0.5),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.12),
                shape: BoxShape.circle,
              ),
              child: const Icon(
                Icons.event_busy_rounded,
                color: Colors.grey,
                size: 28,
              ),
            ),
            const SizedBox(width: 18),
            const Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Plan Bulunamadı",
                    style: TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w800,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 2),
                  Text(
                    "Plan sayfasından bugüne görev ekle",
                    style: TextStyle(
                      color: Color(0xFF64748B),
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    }

    // Süreyi hesapla (dakika) — PomodoroPage max 120 dk destekler
    final int basMin = siradaki.baslangic.hour * 60 + siradaki.baslangic.minute;
    final int bitMin = siradaki.bitis.hour * 60 + siradaki.bitis.minute;
    final int sureDakika = ((bitMin - basMin).abs()).clamp(1, 120);

    final Color dersRengi = siradaki.renk;

    // Şu an devam ediyor mu, yoksa ileriki mi?
    final now = DateTime.now();
    final int simdiMin = now.hour * 60 + now.minute;
    final bool devamEdiyor = simdiMin >= basMin && simdiMin <= bitMin;

    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => PomodoroPage(
            gelenDers: siradaki.ders,
            gelenKonu: siradaki.konu,
            gelenSure: sureDakika,
          ),
        ),
      ),
      borderRadius: BorderRadius.circular(28),
      child: _glassContainer(
        padding: const EdgeInsets.all(22),
        borderRadius: 28,
        backgroundColor: Colors.white.withOpacity(0.5),
        child: Row(
          children: [
            // Sol: Renkli ikon
            Container(
              padding: const EdgeInsets.all(14),
              decoration: BoxDecoration(
                color: dersRengi.withOpacity(0.15),
                shape: BoxShape.circle,
              ),
              child: Icon(
                devamEdiyor ? Icons.play_arrow_rounded : Icons.schedule_rounded,
                color: dersRengi,
                size: 32,
              ),
            ),
            const SizedBox(width: 18),
            // Orta: Ders ve Konu
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    siradaki.ders,
                    style: TextStyle(
                      color: dersRengi,
                      fontWeight: FontWeight.w900,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    siradaki.konu,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      color: Color(0xFF0F172A),
                      fontWeight: FontWeight.w700,
                      fontSize: 14,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Icon(
                        Icons.access_time_rounded,
                        size: 11,
                        color: const Color(0xFF64748B).withOpacity(0.7),
                      ),
                      const SizedBox(width: 3),
                      Text(
                        "${siradaki.baslangic.format(context)} – ${siradaki.bitis.format(context)}",
                        style: const TextStyle(
                          color: Color(0xFF64748B),
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 10),
            // Sağ: Süre chip + devam durumu
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF0F172A),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Text(
                    "$sureDakika DK",
                    style: const TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w800,
                      fontSize: 13,
                    ),
                  ),
                ),
                if (devamEdiyor) ...[
                  const SizedBox(height: 6),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 3,
                    ),
                    decoration: BoxDecoration(
                      color: Colors.green.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Text(
                      "Şu an",
                      style: TextStyle(
                        color: Colors.green,
                        fontWeight: FontWeight.w800,
                        fontSize: 10,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ],
        ),
      ),
    );
  }

  // --- VERİMLİLİK ANALİZİ ---
  Widget _buildEnhancedEfficiencySection() {
    // --- Gerçek istatistikleri hesapla ---

    // Plandan gelen toplam tamamlanan süre (dakika) - Pomodorolar da buraya otomatik ekleniyor
    final int toplamOdak = _store.bugunTamamlananPlanDakika();

    // Günün hedefi yüzde hesabı
    final int toplamPlan = _store.bugunToplamPlanDakika();
    int hedefYuzde = 0;
    if (toplamPlan > 0) {
      hedefYuzde = ((toplamOdak / toplamPlan) * 100).round().clamp(0, 100);
    }

    final List<String> taktikler = [
      "Paragraf çözerken önce soru kökünü, sonra metni oku. Zaman kazandırır!",
      "Matematikte yapamadığın sorularla inatlaşma, turlama tekniğini kullan.",
      "Gece uyumadan hemen önce yapılan kısa tekrarlar çok daha kalıcıdır.",
      "Deneme çözerken mutlaka gerçek sınav süresini ve kurallarını uygula.",
      "Sosyal testinde şıklardaki kavramların anlamlarına dikkat et.",
      "Düzenli mola vermek (Pomodoro), aralıksız saatlerce çalışmaktan etkilidir.",
      "Yanlış yaptığın sorunun çözümünü öğrenmek, doğru yaptığından daha değerlidir.",
      "Her gün paragraf ve problem çözmeyi alışkanlık haline getir.",
      "Fizikte formül ezberlemek yerine olayın temel mantığını anlamaya çalış.",
      "Ders çalışırken telefonu tamamen farklı bir odaya bırakmayı dene.",
      "Sınav anında derin nefes almak, stresi anında azaltan en hızlı yöntemdir.",
      "Uzun paragraflarda önemli yerlerin altını çiz, tüm metni karalama.",
    ];
    final gununTaktigi = taktikler[DateTime.now().day % taktikler.length];

    // Günün şampiyonu: Tüm tamamlanmış (isDone=true) planlara göre hesapla
    // Bu sayede hem Pomodorolar hem de manuel işaretlemeler sayılır ve restart'ta silinmez
    final String? sampiyonDers = _store.bugunEnCokTamamlananDers();

    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: _glassSummaryCard(
                title: "Odak Süresi",
                value: toplamOdak > 0 ? "$toplamOdak" : "—",
                unit: toplamOdak > 0 ? " dk" : "",
                icon: Icons.timer_outlined,
                iconColor: Colors.orange,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: _glassSummaryCard(
                title: "Günün Hedefi",
                value: toplamPlan > 0 ? "%$hedefYuzde" : "—",
                unit: "",
                icon: Icons.track_changes_rounded,
                iconColor: Colors.teal,
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        _glassContainer(
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          borderRadius: 22,
          child: Row(
            children: [
              const Icon(
                Icons.emoji_events_rounded,
                color: Colors.amber,
                size: 24,
              ),
              const SizedBox(width: 12),
              const Text(
                "Günün Şampiyonu:",
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 6,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF4F46E5).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  sampiyonDers ?? "Henüz yok",
                  style: const TextStyle(
                    color: Color(0xFF4F46E5),
                    fontWeight: FontWeight.w900,
                    fontSize: 13,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        _glassContainer(
          padding: const EdgeInsets.all(18),
          borderRadius: 24,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF10B981).withOpacity(0.1),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: const Icon(
                  Icons.lightbulb_rounded,
                  color: Color(0xFF10B981),
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Günün Taktiği",
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFF64748B),
                      ),
                    ),
                    const SizedBox(height: 6),
                    Text(
                      gununTaktigi,
                      style: const TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        height: 1.4,
                        color: Color(0xFF0F172A),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _glassSummaryCard({
    required String title,
    required String value,
    required String unit,
    required IconData icon,
    required Color iconColor,
  }) {
    return _glassContainer(
      padding: const EdgeInsets.all(18),
      borderRadius: 24,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(icon, color: iconColor, size: 20),
              const SizedBox(width: 8),
              Text(
                title,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                value,
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              Text(
                unit,
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF64748B),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildGlassPredictorCard(BuildContext context) {
    return InkWell(
      onTap: () => Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const PuanHesaplaPage()),
      ),
      borderRadius: BorderRadius.circular(30),
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              const Color(0xFF4F46E5).withOpacity(0.85),
              const Color(0xFF3730A3).withOpacity(0.85),
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
          borderRadius: BorderRadius.circular(30),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFF4F46E5).withOpacity(0.3),
              blurRadius: 20,
              offset: const Offset(0, 10),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(30),
          child: BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 26),
              child: Row(
                children: [
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Sıralama Tahmini",
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 22,
                            fontWeight: FontWeight.w900,
                          ),
                        ),
                        SizedBox(height: 6),
                        Text(
                          "2024-2025 Verileriyle Analiz Et",
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.15),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.analytics_rounded,
                      color: Colors.white,
                      size: 30,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildDynamicBackground() {
    return Stack(
      children: [
        Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFE0E7FF), Color(0xFFF3E8FF), Color(0xFFF8FAFC)],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
          ),
        ),
        // ImageFiltered, sadece kendi child'ını bulanıklaştırır.
        // BackdropFilter gibi arkasındaki her şeyi işlemez → çok daha hızlı.
        Positioned(
          top: -50,
          left: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 60,
              sigmaY: 60,
              tileMode: TileMode.decal,
            ),
            child: Container(
              width: 250,
              height: 250,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF818CF8).withOpacity(0.5),
              ),
            ),
          ),
        ),
        Positioned(
          bottom: 100,
          right: -50,
          child: ImageFiltered(
            imageFilter: ImageFilter.blur(
              sigmaX: 70,
              sigmaY: 70,
              tileMode: TileMode.decal,
            ),
            child: Container(
              width: 300,
              height: 300,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFFC084FC).withOpacity(0.4),
              ),
            ),
          ),
        ),
      ],
    );
  }
}

extension BlurExtension on Widget {
  Widget blur({required double radius}) => BackdropFilter(
    filter: ImageFilter.blur(sigmaX: radius, sigmaY: radius),
    child: this,
  );
}

// ----------------------------------------------------------
// YKS Sayacı — Sadece bu küçük widget dakikada bir rebuild
// edilir. HomePage'in geri kalanı etkilenmez.
// ----------------------------------------------------------
class _YKSCountdownWidget extends StatefulWidget {
  const _YKSCountdownWidget();

  @override
  State<_YKSCountdownWidget> createState() => _YKSCountdownWidgetState();
}

class _YKSCountdownWidgetState extends State<_YKSCountdownWidget> {
  final DateTime _yksTarihi = DateTime(2026, 6, 20, 10, 0);
  late Duration _kalanSure;
  late Timer _timer;

  @override
  void initState() {
    super.initState();
    _kalanSure = _yksTarihi.difference(DateTime.now());
    _timer = Timer.periodic(const Duration(minutes: 1), (_) {
      if (mounted) {
        setState(() {
          _kalanSure = _yksTarihi.difference(DateTime.now());
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(28),
      child: BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 24),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(0.35),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: Colors.white.withOpacity(0.6),
              width: 1.5,
            ),
          ),
          child: Column(
            children: [
              const Text(
                "YKS 2026 GERİ SAYIM",
                style: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF4F46E5),
                  letterSpacing: 1.5,
                ),
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  _unit(_kalanSure.inDays.toString(), "GÜN"),
                  _sep(),
                  _unit((_kalanSure.inHours % 24).toString(), "SAAT"),
                  _sep(),
                  _unit((_kalanSure.inMinutes % 60).toString(), "DK"),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _unit(String val, String label) => Column(
    children: [
      Text(
        val,
        style: const TextStyle(
          fontSize: 30,
          fontWeight: FontWeight.w900,
          color: Color(0xFF0F172A),
        ),
      ),
      Text(
        label,
        style: const TextStyle(
          fontSize: 10,
          fontWeight: FontWeight.w800,
          color: Color(0xFF64748B),
        ),
      ),
    ],
  );

  Widget _sep() => Padding(
    padding: const EdgeInsets.symmetric(horizontal: 15),
    child: Text(
      ":",
      style: TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.w900,
        color: Colors.grey.withOpacity(0.5),
      ),
    ),
  );
}

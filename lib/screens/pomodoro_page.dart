import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:ui';
import '../logic/study_session_store.dart';
import '../plan_store.dart';
import '../data/curriculum_data.dart';
// ---------------------------------------------------------
// 1. SAYFA: PLANLAMA VE KURULUM EKRANI
// ---------------------------------------------------------
class PomodoroPage extends StatefulWidget {
  final String? gelenDers;
  final String? gelenKonu;
  final int? gelenSure;

  const PomodoroPage({
    super.key,
    this.gelenDers,
    this.gelenKonu,
    this.gelenSure,
  });

  @override
  State<PomodoroPage> createState() => _PomodoroPageState();
}

class _PomodoroPageState extends State<PomodoroPage> {
  String? _secilenDers;
  String? _secilenKonu;
  int _odaklanmaSuresi = 25;
  int _etutSayisi = 1;
  late FixedExtentScrollController _odakController;



  @override
  void initState() {
    super.initState();
    _secilenDers = widget.gelenDers;
    // Gelen konunun, ders listesinde gerçekten bulunup bulunmadığını kontrol et
    if (widget.gelenKonu != null &&
        _secilenDers != null &&
        (mufredat[_secilenDers]?.contains(widget.gelenKonu) ?? false)) {
      _secilenKonu = widget.gelenKonu;
    }
    if (widget.gelenSure != null) {
      _odaklanmaSuresi = widget.gelenSure!.clamp(1, 120);
    }
    _odakController = FixedExtentScrollController(
      initialItem: _odaklanmaSuresi - 1,
    );
  }

  int get _otomatikMola =>
      _odaklanmaSuresi < 30 ? 5 : (_odaklanmaSuresi < 60 ? 10 : 15);

  String get _onerilenMesaj {
    if (_secilenDers == null)
      return "Verimli bir çalışma için önce bir ders seçmelisin.";
    if (_etutSayisi > 3)
      return "Yüksek etüt sayısı seçtin, molalarda mutlaka su içmeyi unutma!";
    return "Harika bir plan! ${_secilenDers} çalışmak için her şey hazır.";
  }

  void _odaklanmaModunaGec() {
    if (_secilenDers == null || _secilenKonu == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Lütfen ders ve konu seçin!'),
          backgroundColor: Colors.redAccent,
        ),
      );
      return;
    }

    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => DarkFocusPage(
          ders: _secilenDers!,
          konu: _secilenKonu!,
          odakDakika: _odaklanmaSuresi,
          molaDakika: _otomatikMola,
          toplamEtut: _etutSayisi,
        ),
      ),
    );
  }

  Widget _buildBackground() {
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
        Positioned(
          top: 100,
          left: -50,
          child: _blurCircle(200, const Color(0xFF818CF8).withOpacity(0.3)),
        ),
        Positioned(
          bottom: 200,
          right: -50,
          child: _blurCircle(250, const Color(0xFFC084FC).withOpacity(0.2)),
        ),
      ],
    );
  }

  Widget _blurCircle(double size, Color color) {
    return ImageFiltered(
      imageFilter: ImageFilter.blur(
        sigmaX: 50,
        sigmaY: 50,
        tileMode: TileMode.decal,
      ),
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(shape: BoxShape.circle, color: color),
      ),
    );
  }

  // --- GLASSBOX (hızlı versiyon) ---
  Widget _glassBox({
    required Widget child,
    double? height,
    EdgeInsetsGeometry? padding,
    Color? color,
  }) {
    return Container(
      height: height,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.72),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 14,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Otonom Seans Ayarı',
          style: TextStyle(
            fontWeight: FontWeight.w900,
            fontSize: 18,
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
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    "Planını Yap 🎯",
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                  const SizedBox(height: 20),

                  _glassBox(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      children: [
                        DropdownButtonFormField<String>(
                          value: _secilenDers,
                          decoration: InputDecoration(
                            hintText: 'Ders Seçin',
                            prefixIcon: const Icon(
                              Icons.school_rounded,
                              color: Color(0xFF4F46E5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items: mufredat.keys
                              .map(
                                (ders) => DropdownMenuItem(
                                  value: ders,
                                  child: Text(ders),
                                ),
                              )
                              .toList(),
                          onChanged: (value) => setState(() {
                            _secilenDers = value;
                            _secilenKonu = null;
                          }),
                        ),
                        const SizedBox(height: 12),
                        DropdownButtonFormField<String>(
                          value: _secilenKonu,
                          decoration: InputDecoration(
                            hintText: 'Hangi Konu?',
                            prefixIcon: const Icon(
                              Icons.bolt_rounded,
                              color: Color(0xFF4F46E5),
                            ),
                            filled: true,
                            fillColor: Colors.white.withOpacity(0.5),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(16),
                              borderSide: BorderSide.none,
                            ),
                          ),
                          items:
                              (_secilenDers != null &&
                                  mufredat.containsKey(_secilenDers))
                              ? mufredat[_secilenDers]!
                                    .map(
                                      (konu) => DropdownMenuItem(
                                        value: konu,
                                        child: Text(konu),
                                      ),
                                    )
                                    .toList()
                              : (_secilenKonu != null
                                    ? [
                                        DropdownMenuItem(
                                          value: _secilenKonu,
                                          child: Text(_secilenKonu!),
                                        ),
                                      ]
                                    : []),
                          onChanged: (value) =>
                              setState(() => _secilenKonu = value),
                        ),
                        const SizedBox(height: 12),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Text(
                              "Kaç Etüt Yapılacak?",
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                color: Color(0xFF0F172A),
                              ),
                            ),
                            Row(
                              children: [
                                IconButton(
                                  onPressed: () => setState(
                                    () =>
                                        _etutSayisi > 1 ? _etutSayisi-- : null,
                                  ),
                                  icon: const Icon(
                                    Icons.remove_circle_outline,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                                Text(
                                  "$_etutSayisi",
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                                IconButton(
                                  onPressed: () =>
                                      setState(() => _etutSayisi++),
                                  icon: const Icon(
                                    Icons.add_circle_outline,
                                    color: Color(0xFF4F46E5),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 30),

                  Row(
                    children: [
                      Expanded(
                        flex: 3,
                        child: _glassBox(
                          height: 140,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text(
                                "ODAK SÜRESİ",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF4F46E5),
                                  fontSize: 11,
                                ),
                              ),
                              SizedBox(
                                height: 100,
                                child: ListWheelScrollView.useDelegate(
                                  controller: _odakController,
                                  itemExtent: 50,
                                  physics: const FixedExtentScrollPhysics(),
                                  onSelectedItemChanged: (i) =>
                                      setState(() => _odaklanmaSuresi = i + 1),
                                  childDelegate: ListWheelChildBuilderDelegate(
                                    childCount: 120,
                                    builder: (context, i) => Center(
                                      child: Text(
                                        '${i + 1}',
                                        style: TextStyle(
                                          fontSize: _odaklanmaSuresi == (i + 1)
                                              ? 32
                                              : 24,
                                          fontWeight:
                                              _odaklanmaSuresi == (i + 1)
                                              ? FontWeight.w900
                                              : FontWeight.normal,
                                          color: _odaklanmaSuresi == (i + 1)
                                              ? const Color(0xFF4F46E5)
                                              : Colors.black26,
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        flex: 2,
                        child: _glassBox(
                          height: 140,
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.auto_awesome_rounded,
                                color: Color(0xFF14B8A6),
                                size: 28,
                              ),
                              const Text(
                                "ÖNERİLEN MOLA",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14B8A6),
                                ),
                              ),
                              Text(
                                "$_otomatikMola dk",
                                style: const TextStyle(
                                  fontSize: 28,
                                  fontWeight: FontWeight.w900,
                                  color: Color(0xFF14B8A6),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 30),

                  // ARTIK HATA VERMEYEN RENKLİ CAM KART
                  _glassBox(
                    padding: const EdgeInsets.all(16),
                    color: Colors.amber.withOpacity(0.15),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.lightbulb_rounded,
                          color: Colors.orange,
                          size: 28,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                "Otonom Rehber",
                                style: TextStyle(
                                  fontWeight: FontWeight.w900,
                                  color: Colors.orange,
                                  fontSize: 13,
                                ),
                              ),
                              Text(
                                _onerilenMesaj,
                                style: const TextStyle(
                                  color: Color(0xFF0F172A),
                                  fontSize: 12,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 25),
                  SizedBox(
                    width: double.infinity,
                    height: 60,
                    child: ElevatedButton.icon(
                      onPressed: _odaklanmaModunaGec,
                      icon: const Icon(
                        Icons.rocket_launch_rounded,
                        color: Colors.white,
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF4F46E5),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(18),
                        ),
                      ),
                      label: const Text(
                        'Seansı Başlat',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w900,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class DarkFocusPage extends StatefulWidget {
  final String ders;
  final String konu;
  final int odakDakika;
  final int molaDakika;
  final int toplamEtut;
  const DarkFocusPage({
    super.key,
    required this.ders,
    required this.konu,
    required this.odakDakika,
    required this.molaDakika,
    required this.toplamEtut,
  });

  @override
  State<DarkFocusPage> createState() => _DarkFocusPageState();
}

class _DarkFocusPageState extends State<DarkFocusPage>
    with TickerProviderStateMixin {
  late int _kalanSaniye;
  int _tamamlananEtut = 0;
  Timer? _timer;
  bool _isRunning = false;
  bool _molaModu = false;
  late AnimationController _pulseController;
  late DateTime _seansBaslangicZamani;
  late String _sessionId;

  @override
  void initState() {
    super.initState();
    _sessionId = '${DateTime.now().millisecondsSinceEpoch}_auto';
    _kalanSaniye = widget.odakDakika * 60;
    _seansBaslangicZamani = DateTime.now();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat(reverse: true);
    _toggleTimer();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pulseController.dispose();
    super.dispose();
  }

  void _toggleTimer() {
    setState(() => _isRunning = !_isRunning);
    if (_isRunning) {
      _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
        if (mounted) {
          setState(() {
            if (_kalanSaniye > 0) {
              _kalanSaniye--;
            } else {
              _timer?.cancel();
              _isRunning = false;
              if (!_molaModu) {
                _seansBitti();
              } else {
                _molaBitti();
              }
            }
          });
        }
      });
    } else {
      _timer?.cancel();
    }
  }

  void _akisKontrol() {
    if (!_molaModu) {
      if (_kalanSaniye > 0) {
        showDialog(
          context: context,
          builder: (context) => BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
            child: AlertDialog(
              backgroundColor: const Color(0xFF1E293B),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              title: const Text(
                "Odaklanma Bitmedi ⚠️",
                style: TextStyle(
                  color: Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
              content: const Text(
                "Daha vaktin var! Seansı erken bitirip disiplinini bozmak istediğine emin misin?",
                style: TextStyle(color: Colors.white70),
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text("Çalışmaya Dön"),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent,
                  ),
                  onPressed: () async {
                    Navigator.pop(context);
                    await _seansBitti();
                  },
                  child: const Text("Bitir"),
                ),
              ],
            ),
          ),
        );
      } else {
        _seansBitti();
      }
    } else {
      _molaBitti();
    }
  }

  Future<void> _seansBitti() async {
    _timer?.cancel();
    _isRunning = false;
    _tamamlananEtut++;
    // Tamamlanan seansı istatistik store'a kaydet
    StudySessionStore().seansEkle(widget.ders, widget.odakDakika);
    // Plan’a otomatik ekle (await ile — Firestore yazımı tamamlanmadan devam etme)
    await _otomatikPlanEkle();
    if (_tamamlananEtut >= widget.toplamEtut) {
      _tebrikDialog();
    } else {
      _molaSorDialog();
    }
  }

  /// Pomodoro seansı biten dersi plana ekler.
  /// • Aynı ders + çakışan saat varsa → sadece tamamlandı işaretle.
  /// • Yoksa yeni kayıt oluştur.
  Future<void> _otomatikPlanEkle() async {
    final store = PlanStore();
    final today = DateTime.now();

    // 1. Durum: Bu oturuma ait daha önce eklenmiş bir plan var mı? (2. veya 3. etütü bitiriyorsak)
    final mevcutPlanIdx = store.planlar.indexWhere((p) => p.id == _sessionId);

    if (mevcutPlanIdx != -1) {
      final eskiPlan = store.planlar[mevcutPlanIdx];
      
      final eskiBitisDt = DateTime(today.year, today.month, today.day, eskiPlan.bitis.hour, eskiPlan.bitis.minute);
      // Yeni bitiş zamanı = Eski bitiş zamanı + Odak Süresi (böylece 30+30=60 dk olur)
      final yeniBitisDt = eskiBitisDt.add(Duration(minutes: widget.odakDakika));
      
      int r(int dk) => ((dk / 5).round() * 5).clamp(0, 55);
      final bitH = yeniBitisDt.hour;
      final bitM = r(yeniBitisDt.minute);
      
      final yeniPlan = PlanModel(
        id: eskiPlan.id,
        ders: eskiPlan.ders,
        konu: eskiPlan.konu,
        baslangic: eskiPlan.baslangic,
        bitis: TimeOfDay(hour: bitH, minute: bitM),
        renk: eskiPlan.renk,
        tarih: eskiPlan.tarih,
        isDone: true,
      );
      
      await store.planGuncelle(eskiPlan, yeniPlan);
      return;
    }

    // 2. Durum: İLK ETÜT. Yeni plan oluşturacağız veya mevcuta entegre olacağız.
    final baslangicDt = _seansBaslangicZamani;
    
    // Bitiş zamanını pomodoro süresine göre belirle
    final bitisDt = baslangicDt.add(Duration(minutes: widget.odakDakika));

    int r(int dk) => ((dk / 5).round() * 5).clamp(0, 55);

    final basH = baslangicDt.hour;
    final basM = r(baslangicDt.minute);
    final bitH = bitisDt.hour;
    final bitM = r(bitisDt.minute);

    final basDk = basH * 60 + basM;

    // Bugünkü planlar içinde AYNI DERS çakışıyor mu?
    for (final p in store.planlar) {
      if (p.tarih.year != today.year ||
          p.tarih.month != today.month ||
          p.tarih.day != today.day) continue;
      if (p.ders != widget.ders) continue;

      final pBas = p.baslangic.hour * 60 + p.baslangic.minute;

      // Eğer kullanıcının daha önceden oluşturduğu plan ile bu seansın başlangıcı yakınsa (±20 dk)
      if ((pBas - basDk).abs() <= 20) {
        // Planı devral! Bundan sonraki etütler bu planı uzatacak.
        _sessionId = p.id;
        if (!p.isDone) await store.tamamlandiToggle(p.id, isDone: true);
        return;
      }
    }

    // Eşleşen yakın bir plan yok → sıfırdan yeni kayıt ekle
    final baslangic = TimeOfDay(hour: basH, minute: basM);
    final bitis = TimeOfDay(hour: bitH, minute: bitM);

    await store.planEkle(PlanModel(
      id: _sessionId,
      ders: widget.ders,
      konu: widget.konu,
      baslangic: baslangic,
      bitis: bitis,
      renk: _dersRengiBul(widget.ders),
      tarih: DateTime(today.year, today.month, today.day),
      isDone: true,
    ));
  }


  /// Ders adına göre renk döndürür.
  Color _dersRengiBul(String ders) {
    switch (ders) {
      case 'Matematik': return const Color(0xFFEF4444);
      case 'Fizik':     return const Color(0xFF3B82F6);
      case 'Türkçe':    return const Color(0xFFF59E0B);
      case 'Biyoloji':  return const Color(0xFF10B981);
      case 'Kimya':     return const Color(0xFF06B6D4);
      case 'Geometri':  return const Color(0xFF8B5CF6);
      default:          return const Color(0xFF6366F1);
    }
  }

  void _molaBitti() {
    _timer?.cancel();
    _isRunning = false;
    _molaModu = false;
    setState(() {
      _kalanSaniye = widget.odakDakika * 60;
      _seansBaslangicZamani = DateTime.now(); // Yeni etüt için başlangıç zamanını güncelle
      _toggleTimer();
    });
  }

  void _molaSorDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 5, sigmaY: 5),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: Text(
            "Etüt $_tamamlananEtut Bitti! ☕",
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.bold,
            ),
          ),
          content: Text(
            "${widget.molaDakika} dakika mola verebilir veya hemen derse dönebilirsin.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                _molaBitti();
              },
              child: const Text("Molayı Atla"),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _molaBaslat();
              },
              child: const Text("Mola Ver"),
            ),
          ],
        ),
      ),
    );
  }

  void _molaBaslat() {
    setState(() {
      _molaModu = true;
      _kalanSaniye = widget.molaDakika * 60;
      _toggleTimer();
    });
  }

  void _tebrikDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: const Color(0xFF1E293B),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          title: const Text(
            "Tebrikler! 🎉",
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
          content: Text(
            "${widget.toplamEtut} etütlük seansını başarıyla tamamladın.",
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Ana Sayfaya Dön"),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    double progress =
        _kalanSaniye /
        (_molaModu ? (widget.molaDakika * 60) : (widget.odakDakika * 60));
    Color themeColor = _molaModu
        ? const Color(0xFF14B8A6)
        : const Color(0xFF4F46E5);

    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF0F172A), Color(0xFF1E293B)],
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
              ),
            ),
          ),
          SafeArea(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    color: themeColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: themeColor.withOpacity(0.3)),
                  ),
                  child: Text(
                    _molaModu
                        ? "MOLA ZAMANI ☕"
                        : "ETÜT ${_tamamlananEtut + 1} / ${widget.toplamEtut}",
                    style: TextStyle(
                      color: themeColor,
                      fontWeight: FontWeight.w900,
                      fontSize: 12,
                      letterSpacing: 1,
                    ),
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  '${widget.ders} • ${widget.konu}',
                  style: const TextStyle(
                    color: Colors.white54,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 60),
                Stack(
                  alignment: Alignment.center,
                  children: [
                    if (_isRunning)
                      ScaleTransition(
                        scale: Tween(
                          begin: 1.0,
                          end: 1.1,
                        ).animate(_pulseController),
                        child: Container(
                          width: 260,
                          height: 260,
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: themeColor.withOpacity(0.15),
                              width: 2,
                            ),
                          ),
                        ),
                      ),
                    SizedBox(
                      width: 280,
                      height: 280,
                      child: CircularProgressIndicator(
                        value: progress,
                        strokeWidth: 8,
                        backgroundColor: Colors.white.withOpacity(0.05),
                        color: themeColor,
                        strokeCap: StrokeCap.round,
                      ),
                    ),
                    Text(
                      '${(_kalanSaniye ~/ 60).toString().padLeft(2, '0')}:${(_kalanSaniye % 60).toString().padLeft(2, '0')}',
                      style: const TextStyle(
                        fontSize: 80,
                        fontWeight: FontWeight.w100,
                        color: Colors.white,
                        letterSpacing: -2,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 80),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    IconButton(
                      onPressed: () => Navigator.pop(context),
                      icon: const Icon(
                        Icons.close_rounded,
                        color: Colors.white38,
                        size: 30,
                      ),
                    ),
                    const SizedBox(width: 40),
                    GestureDetector(
                      onTap: _toggleTimer,
                      child: Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: themeColor,
                          boxShadow: [
                            BoxShadow(
                              color: themeColor.withOpacity(0.4),
                              blurRadius: 20,
                            ),
                          ],
                        ),
                        child: Icon(
                          _isRunning
                              ? Icons.pause_rounded
                              : Icons.play_arrow_rounded,
                          color: Colors.white,
                          size: 45,
                        ),
                      ),
                    ),
                    const SizedBox(width: 40),
                    IconButton(
                      onPressed: _akisKontrol,
                      icon: Icon(
                        Icons.bolt_rounded,
                        color: _molaModu
                            ? Colors.tealAccent
                            : Colors.amberAccent,
                        size: 35,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

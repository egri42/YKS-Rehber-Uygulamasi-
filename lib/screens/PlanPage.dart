import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:confetti/confetti.dart';
import '../plan_store.dart';
import '../data/curriculum_data.dart';


class PlanPage extends StatefulWidget {
  const PlanPage({super.key});
  @override
  State<PlanPage> createState() => _PlanPageState();
}

class _PlanPageState extends State<PlanPage> {
  final double _saatYukseklik = 90.0;
  late ConfettiController _confettiController;
  final PlanStore _store = PlanStore();

  @override
  void initState() {
    super.initState();
    _confettiController = ConfettiController(
      duration: const Duration(seconds: 2),
    );
    _store.addListener(_onStoreChanged);
  }

  void _onStoreChanged() => setState(() {});

  @override
  void dispose() {
    _store.removeListener(_onStoreChanged);
    _confettiController.dispose();
    super.dispose();
  }

  double _saatToPos(TimeOfDay t) =>
      ((t.hour - 7) + (t.minute / 60.0)) * _saatYukseklik;

  double _getDurYuks(TimeOfDay b, TimeOfDay bi) {
    double bD = b.hour + b.minute / 60.0;
    double biD = bi.hour + bi.minute / 60.0;
    double fark = biD - bD;
    return (fark > 0.4 ? fark : 0.4) * _saatYukseklik;
  }

  @override
  Widget build(BuildContext context) {
    List<PlanModel> gunlukPlanlar = _store.planlar
        .where(
          (p) =>
              p.tarih.year == _store.secilenGun.year &&
              p.tarih.month == _store.secilenGun.month &&
              p.tarih.day == _store.secilenGun.day,
        )
        .toList();

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        title: const Text(
          'Günlük Planım',
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
            child: Column(
              children: [
                _buildDateBar(),
                Expanded(
                  child: SingleChildScrollView(
                    physics: const BouncingScrollPhysics(),
                    padding: const EdgeInsets.fromLTRB(20, 10, 20, 100),
                    child: SizedBox(
                      height: _saatYukseklik * 17,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Column(
                            children: List.generate(
                              17,
                              (i) => _buildTimelineGridRow(i + 7),
                            ),
                          ),
                          ...gunlukPlanlar
                              .map((p) => _buildPlanCard(p))
                              .toList(),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
          Align(
            alignment: Alignment.topCenter,
            child: ConfettiWidget(
              confettiController: _confettiController,
              blastDirectionality: BlastDirectionality.explosive,
              shouldLoop: false,
              colors: const [
                Colors.green,
                Colors.blue,
                Colors.pink,
                Colors.orange,
                Colors.purple,
              ],
            ),
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

  Widget _buildTimelineGridRow(int h) {
    return GestureDetector(
      onTap: () => _yeniPlanDialog(hour: h),
      behavior: HitTestBehavior.opaque,
      child: Container(
        height: _saatYukseklik,
        decoration: BoxDecoration(
          border: Border(
            top: BorderSide(color: const Color(0xFF64748B).withOpacity(0.1)),
          ),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 4),
              child: SizedBox(
                width: 45,
                child: Text(
                  "$h:00",
                  style: TextStyle(
                    color: const Color(0xFF64748B).withOpacity(0.4),
                    fontSize: 11,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPlanCard(PlanModel p) {
    double top = _saatToPos(p.baslangic);
    double height = _getDurYuks(p.baslangic, p.bitis);

    // Sadece bitiş saati geçmiş veya şu an devam eden planlar işaretlenebilir
    final now = DateTime.now();
    final bitisMin = p.bitis.hour * 60 + p.bitis.minute;
    final simdiMin = now.hour * 60 + now.minute;
    
    final bugunTarih = DateTime(now.year, now.month, now.day);
    final planTarih = DateTime(p.tarih.year, p.tarih.month, p.tarih.day);

    bool islemYapilabilirMi = false;
    if (planTarih.isBefore(bugunTarih)) {
      islemYapilabilirMi = true; // Geçmiş gün
    } else if (planTarih.isAtSameMomentAs(bugunTarih)) {
      islemYapilabilirMi = bitisMin <= simdiMin; // Bugünse saati kontrol et
    } else {
      islemYapilabilirMi = false; // Gelecek gün
    }

    Color kartRengi;
    Color kenarRengi;
    if (p.isDone) {
      kartRengi = Colors.green.withOpacity(0.25);
      kenarRengi = Colors.green;
    } else if (!islemYapilabilirMi) {
      // Gelecekte olan plan: biraz soluk ama görünür
      kartRengi = p.renk.withOpacity(0.18);
      kenarRengi = p.renk.withOpacity(0.55);
    } else {
      kartRengi = p.renk.withOpacity(0.12);
      kenarRengi = p.renk;
    }

    return Positioned(
      top: top,
      left: 55,
      right: 0,
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          GestureDetector(
            onTap: islemYapilabilirMi
                ? () {
                    _store.tamamlandiToggle(p.id, isDone: !p.isDone);
                    if (!p.isDone) _confettiController.play();
                  }
                : null, // Gelecekteki plan: dokunulmaz
            onLongPress: () => _store.planSil(p.id),
            child: _glassBox(
              borderRadius: 16,
              padding: EdgeInsets.symmetric(
                  horizontal: 12, vertical: height < 45 ? 2 : 8),
              color: kartRengi,
              border: Border(left: BorderSide(color: kenarRengi, width: 6)),
              height: height,
              child: Stack(
                children: [
                  FittedBox(
                    fit: BoxFit.scaleDown,
                    alignment: Alignment.centerLeft,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          p.ders,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            color: p.isDone
                                ? Colors.green.shade900
                                : islemYapilabilirMi
                                    ? p.renk
                                    : p.renk.withOpacity(0.4),
                            fontSize: height < 45 ? 12 : 14,
                            decoration: p.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                        Text(
                          p.konu,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontSize: height < 45 ? 10 : 11,
                            color: islemYapilabilirMi
                                ? Colors.black54
                                : Colors.black26,
                            decoration: p.isDone
                                ? TextDecoration.lineThrough
                                : null,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Positioned(
                    bottom: 0,
                    right: 0,
                    child: p.isDone
                        ? const Icon(
                            Icons.check_circle,
                            color: Colors.green,
                            size: 16,
                          )
                        : !islemYapilabilirMi
                            ? Icon(
                                Icons.lock_outline_rounded,
                                size: 14,
                                color: p.renk.withOpacity(0.35),
                              )
                            : const SizedBox.shrink(),
                  ),
                ],
              ),
            ),
          ),
          if (p.baslangic.minute != 0)
            Positioned(
              left: -55,
              top: -8,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                decoration: BoxDecoration(
                  color: kenarRengi,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  p.baslangic.format(context),
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 9,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildDateBar() {
    // Geçmişteki 7 gün + bugün + gelecekteki 7 gün = 15 gün
    const int gecmisGunSayisi = 7;
    const int toplamGunSayisi = 15; // 7 geçmiş + 1 bugün + 7 gelecek
    final now = DateTime.now();

    // Bugünü ortada göstermek için başlangıç scroll pozisyonu
    // Her kart 65 genişlik + 16 margin (8+8) = 81 piksel
    const double kartGenislik = 81.0;
    final ScrollController scrollController = ScrollController(
      initialScrollOffset: gecmisGunSayisi * kartGenislik - kartGenislik,
    );

    return SizedBox(
      height: 100,
      child: ListView.builder(
        controller: scrollController,
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 15),
        itemCount: toplamGunSayisi,
        itemBuilder: (context, index) {
          DateTime d = DateTime(now.year, now.month, now.day)
              .add(Duration(days: index - gecmisGunSayisi));
          bool s = _store.secilenGun.day == d.day &&
              _store.secilenGun.month == d.month &&
              _store.secilenGun.year == d.year;
          bool bugun = d.day == now.day &&
              d.month == now.month &&
              d.year == now.year;
          return GestureDetector(
            onTap: () => _store.setSecilenGun(d),
            child: _glassBox(
              width: 65,
              borderRadius: 24,
              margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 10),
              color: s
                  ? const Color(0xFF4F46E5)
                  : Colors.white.withOpacity(0.3),
              border: bugun && !s
                  ? Border.all(color: const Color(0xFF4F46E5).withOpacity(0.5), width: 2)
                  : null,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    DateFormat('E', 'tr_TR').format(d),
                    style: TextStyle(
                      color: s ? Colors.white70 : const Color(0xFF64748B),
                      fontSize: 11,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    "${d.day}",
                    style: TextStyle(
                      color: s ? Colors.white : const Color(0xFF0F172A),
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  if (bugun)
                    Container(
                      margin: const EdgeInsets.only(top: 4),
                      width: 5,
                      height: 5,
                      decoration: BoxDecoration(
                        color: s ? Colors.white : const Color(0xFF4F46E5),
                        shape: BoxShape.circle,
                      ),
                    ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _yeniPlanDialog({int? hour, PlanModel? eskiPlan}) {
    String? selD = eskiPlan?.ders;
    String? selK = eskiPlan?.konu;
    int startH = eskiPlan?.baslangic.hour ?? hour ?? 9;
    int startM = eskiPlan?.baslangic.minute ?? 0;
    int endH = eskiPlan?.bitis.hour ?? (startH + 1);
    int endM = eskiPlan?.bitis.minute ?? 0;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => StatefulBuilder(
        builder: (ctx, setMState) => Container(
          padding: EdgeInsets.only(
            bottom: MediaQuery.of(ctx).viewInsets.bottom + 32,
            left: 24,
            right: 24,
            top: 24,
          ),
          decoration: const BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.grey.shade300,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                eskiPlan == null ? "Yeni Plan Ekle" : "Düzenle",
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: Color(0xFF0F172A),
                ),
              ),
              const SizedBox(height: 20),
              DropdownButtonFormField<String>(
                decoration: _inputDeco("Ders Seç", Icons.school_rounded),
                value: selD,
                items: mufredat.keys
                    .toSet()
                    .toList()
                    .map((d) => DropdownMenuItem(value: d, child: Text(d)))
                    .toList(),
                onChanged: (val) => setMState(() {
                  selD = val;
                  selK = null;
                }),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                decoration: _inputDeco("Konu Seç", Icons.auto_stories_rounded),
                value: (selD != null && mufredat[selD]!.contains(selK))
                    ? selK
                    : null,
                items: selD == null
                    ? []
                    : mufredat[selD]!
                          .toSet()
                          .toList()
                          .map(
                            (k) => DropdownMenuItem(value: k, child: Text(k)),
                          )
                          .toList(),
                onChanged: (val) => setMState(() => selK = val),
              ),
              const SizedBox(height: 25),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _timePickerScroll(
                    "Başlangıç",
                    startH,
                    startM,
                    (h, m) => setMState(() {
                      startH = h;
                      startM = m;
                    }),
                  ),
                  const Icon(
                    Icons.arrow_forward_rounded,
                    color: Colors.grey,
                    size: 20,
                  ),
                  _timePickerScroll(
                    "Bitiş",
                    endH,
                    endM,
                    (h, m) => setMState(() {
                      endH = h;
                      endM = m;
                    }),
                  ),
                ],
              ),
              const SizedBox(height: 30),
              SizedBox(
                width: double.infinity,
                height: 60,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF4F46E5),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(20),
                    ),
                  ),
                  onPressed: () {
                    if (selD != null && selK != null) {
                      final yeniPlan = PlanModel(
                        id: DateTime.now().toString(),
                        ders: selD!,
                        konu: selK!,
                        baslangic: TimeOfDay(hour: startH, minute: startM),
                        bitis: TimeOfDay(hour: endH, minute: endM),
                        renk: dersRengi(selD),
                        tarih: _store.secilenGun,
                        isDone: false,
                      );
                      if (eskiPlan != null) {
                        _store.planGuncelle(eskiPlan, yeniPlan);
                      } else {
                        _store.planEkle(yeniPlan);
                      }
                      Navigator.pop(context);
                    }
                  },
                  child: const Text(
                    "Takvime İşle",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w900,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _timePickerScroll(
    String label,
    int h,
    int m,
    Function(int, int) onChanged,
  ) {
    return Column(
      children: [
        Text(
          label,
          style: const TextStyle(
            fontSize: 10,
            fontWeight: FontWeight.bold,
            color: Colors.grey,
          ),
        ),
        const SizedBox(height: 8),
        GestureDetector(
          onTap: () => _openScrollSelector(h, m, onChanged),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: const Color(0xFF4F46E5).withOpacity(0.05),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: const Color(0xFF4F46E5).withOpacity(0.1),
              ),
            ),
            child: Text(
              "${h.toString().padLeft(2, '0')}:${m.toString().padLeft(2, '0')}",
              style: const TextStyle(
                fontWeight: FontWeight.w900,
                fontSize: 16,
                color: Color(0xFF0F172A),
              ),
            ),
          ),
        ),
      ],
    );
  }

  void _openScrollSelector(
    int initialH,
    int initialM,
    Function(int, int) onChanged,
  ) {
    int tempH = initialH;
    int tempM = initialM;
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(32)),
      ),
      builder: (context) => Container(
        height: 300,
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text(
                  "Saat Seç",
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
                ),
                TextButton(
                  onPressed: () {
                    onChanged(tempH, tempM);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    "Tamam",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Color(0xFF4F46E5),
                    ),
                  ),
                ),
              ],
            ),
            Expanded(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) => tempH = index,
                      controller: FixedExtentScrollController(
                        initialItem: initialH,
                      ),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            index.toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        childCount: 24,
                      ),
                    ),
                  ),
                  const Text(
                    ":",
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  Expanded(
                    child: ListWheelScrollView.useDelegate(
                      itemExtent: 40,
                      physics: const FixedExtentScrollPhysics(),
                      onSelectedItemChanged: (index) => tempM = index * 5,
                      controller: FixedExtentScrollController(
                        initialItem: initialM ~/ 5,
                      ),
                      childDelegate: ListWheelChildBuilderDelegate(
                        builder: (context, index) => Center(
                          child: Text(
                            (index * 5).toString().padLeft(2, '0'),
                            style: const TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        childCount: 12,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDeco(String h, IconData i) => InputDecoration(
    prefixIcon: Icon(i, color: const Color(0xFF4F46E5)),
    hintText: h,
    filled: true,
    fillColor: const Color(0xFFF1F5F9),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(20),
      borderSide: BorderSide.none,
    ),
    contentPadding: const EdgeInsets.symmetric(vertical: 18),
  );

  Widget _glassBox({
    required Widget child,
    required double borderRadius,
    EdgeInsetsGeometry? padding,
    EdgeInsetsGeometry? margin,
    double? width,
    double? height,
    Color? color,
    BoxBorder? border,
  }) {
    return Container(
      width: width,
      height: height,
      margin: margin,
      padding: padding,
      decoration: BoxDecoration(
        color: color ?? Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(borderRadius),
        border:
            border ??
            Border.all(color: Colors.white.withOpacity(0.8), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.06),
            blurRadius: 12,
            offset: const Offset(0, 3),
          ),
        ],
      ),
      child: child,
    );
  }
}

import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

// --- PLAN MODELİ ---
class PlanModel {
  String id;
  String ders;
  String konu;
  TimeOfDay baslangic;
  TimeOfDay bitis;
  Color renk;
  bool isDone;
  DateTime tarih;

  PlanModel({
    required this.id,
    required this.ders,
    required this.konu,
    required this.baslangic,
    required this.bitis,
    required this.renk,
    required this.tarih,
    this.isDone = false,
  });

  // Firestore'a yazılacak format
  Map<String, dynamic> toFirestore() => {
    'ders': ders,
    'konu': konu,
    'baslangicSaat': baslangic.hour,
    'baslangicDakika': baslangic.minute,
    'bitisSaat': bitis.hour,
    'bitisDakika': bitis.minute,
    'renkDeger': renk.value,
    'isDone': isDone,
    'tarih': Timestamp.fromDate(tarih),
  };

  // Firestore dökümanından oluşturma
  factory PlanModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return PlanModel(
      id: doc.id,
      ders: data['ders'] ?? '',
      konu: data['konu'] ?? '',
      baslangic: TimeOfDay(
        hour: data['baslangicSaat'] ?? 9,
        minute: data['baslangicDakika'] ?? 0,
      ),
      bitis: TimeOfDay(
        hour: data['bitisSaat'] ?? 10,
        minute: data['bitisDakika'] ?? 0,
      ),
      renk: Color(data['renkDeger'] ?? 0xFF6366F1),
      isDone: data['isDone'] ?? false,
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

// --- FIRESTORE TABANLI PLAN DEPOSU (Singleton) ---
class PlanStore extends ChangeNotifier {
  static final PlanStore _instance = PlanStore._internal();
  factory PlanStore() => _instance;

  PlanStore._internal();

  CollectionReference? _koleksiyon;
  StreamSubscription? _subscription;
  String? _uid;

  final List<PlanModel> _planlar = [];
  List<PlanModel> get planlar => _planlar;

  DateTime _secilenGun = DateTime.now();
  DateTime get secilenGun => _secilenGun;

  void setSecilenGun(DateTime gun) {
    _secilenGun = gun;
    notifyListeners();
  }

  /// Kullanıcı giriş yaptığında çağrılır. Firestore dinlemesini başlatır.
  void initialize(String uid) {
    if (_uid == uid) return; // Aynı kullanıcı tekrar başlatılmasın
    dispose();
    _uid = uid;
    _koleksiyon = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('plans');
    _dinlemeBaslat();
  }

  /// Kullanıcı çıkış yaptığında çağrılır. Dinlemeyi durdurur ve verileri temizler.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _planlar.clear();
    _uid = null;
    _koleksiyon = null;
    notifyListeners();
  }

  // Firestore stream'ini dinle — her değişiklikte UI otomatik güncellenir
  void _dinlemeBaslat() {
    if (_koleksiyon == null) return;
    _subscription = _koleksiyon!.snapshots().listen(
      (snapshot) {
        _planlar.clear();
        for (final doc in snapshot.docs) {
          try {
            _planlar.add(PlanModel.fromFirestore(doc));
          } catch (_) {
            // Hatalı dökümanı atla
          }
        }
        notifyListeners();
      },
      onError: (error) {
        // Firestore erişim hatası (örn. permission denied) → uygulamayı çökertme
        debugPrint('PlanStore Firestore hatası: $error');
      },
    );
  }

  // Plan ekle
  Future<void> planEkle(PlanModel p) async {
    if (_koleksiyon == null) return;
    await _koleksiyon!.doc(p.id).set(p.toFirestore());
  }

  // Plan sil
  Future<void> planSil(String id) async {
    if (_koleksiyon == null) return;
    await _koleksiyon!.doc(id).delete();
  }

  // Plan güncelle
  Future<void> planGuncelle(PlanModel eski, PlanModel yeni) async {
    if (_koleksiyon == null) return;
    await _koleksiyon!.doc(eski.id).set(yeni.toFirestore());
  }

  // Tamamlandı toggle
  Future<void> tamamlandiToggle(String id, {required bool isDone}) async {
    if (_koleksiyon == null) return;
    await _koleksiyon!.doc(id).update({'isDone': isDone});
  }

  /// Bugün tamamlanmış planların toplam süresi (dakika).
  int bugunTamamlananPlanDakika() {
    final now = DateTime.now();
    return _planlar
        .where((p) =>
            p.tarih.year == now.year &&
            p.tarih.month == now.month &&
            p.tarih.day == now.day &&
            p.isDone)
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Bugünkü tüm planların toplam süresi (dakika).
  int bugunToplamPlanDakika() {
    final now = DateTime.now();
    return _planlar
        .where((p) =>
            p.tarih.year == now.year &&
            p.tarih.month == now.month &&
            p.tarih.day == now.day)
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Bugün planda en fazla süre ayrılan ders adını döndürür. Yoksa null.
  String? bugunEnCokPlanlananDers() {
    final now = DateTime.now();
    final bugunler = _planlar.where((p) =>
        p.tarih.year == now.year &&
        p.tarih.month == now.month &&
        p.tarih.day == now.day);

    if (bugunler.isEmpty) return null;

    final Map<String, int> dersToplamDk = {};
    for (final p in bugunler) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      final sure = (bitMin - basMin).abs();
      dersToplamDk[p.ders] = (dersToplamDk[p.ders] ?? 0) + sure;
    }

    return dersToplamDk.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Bugün planda en fazla SÜRE TAMAMLANAN (isDone=true) ders adını döndürür.
  String? bugunEnCokTamamlananDers() {
    final now = DateTime.now();
    final bugunTamamlananlar = _planlar.where((p) =>
        p.isDone &&
        p.tarih.year == now.year &&
        p.tarih.month == now.month &&
        p.tarih.day == now.day);

    if (bugunTamamlananlar.isEmpty) return null;

    final Map<String, int> dersToplamDk = {};
    for (final p in bugunTamamlananlar) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      final sure = (bitMin - basMin).abs();
      dersToplamDk[p.ders] = (dersToplamDk[p.ders] ?? 0) + sure;
    }

    return dersToplamDk.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }

  /// Şu andan itibaren en yakın tamamlanmamış planı döndürür (bugüne ait)
  PlanModel? siradakiGorev() {
    final now = DateTime.now();
    final bugun = _planlar.where((p) =>
        p.tarih.year == now.year &&
        p.tarih.month == now.month &&
        p.tarih.day == now.day &&
        !p.isDone);

    if (bugun.isEmpty) return null;

    // Şu andan sonra başlayacak olanlar
    final gelecek = bugun.where((p) {
      final baslangicDk = p.baslangic.hour * 60 + p.baslangic.minute;
      final simdiDk = now.hour * 60 + now.minute;
      return baslangicDk > simdiDk;
    }).toList();

    if (gelecek.isNotEmpty) {
      gelecek.sort((a, b) {
        final aMin = a.baslangic.hour * 60 + a.baslangic.minute;
        final bMin = b.baslangic.hour * 60 + b.baslangic.minute;
        return aMin.compareTo(bMin);
      });
      return gelecek.first;
    }

    // Şu an devam eden plan var mı?
    final devamEden = bugun.where((p) {
      final simdiDk = now.hour * 60 + now.minute;
      final basD = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitD = p.bitis.hour * 60 + p.bitis.minute;
      return simdiDk >= basD && simdiDk <= bitD;
    }).toList();

    if (devamEden.isNotEmpty) return devamEden.first;

    return null;
  }

  // --- HAFTALIK İSTATİSTİKLER ---

  /// Bu haftanın (Pazartesi-Pazar) başlangıç tarihini döndürür
  DateTime _getStartOfWeek() {
    final now = DateTime.now();
    return DateTime(now.year, now.month, now.day)
        .subtract(Duration(days: now.weekday - 1));
  }

  /// Bu hafta tamamlanan toplam dakika
  int haftalikTamamlananDakika() {
    final startOfWeek = _getStartOfWeek();
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _planlar
        .where((p) =>
            p.isDone &&
            p.tarih.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
            p.tarih.isBefore(endOfWeek))
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Bu hafta planlanan toplam dakika (hedefler için)
  int haftalikToplamPlanDakika() {
    final startOfWeek = _getStartOfWeek();
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    return _planlar
        .where((p) =>
            p.tarih.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
            p.tarih.isBefore(endOfWeek))
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Bu haftanın gün gün tamamlanan dakikalarını döndürür (Pazartesi'den Pazar'a 7 elemanlı liste)
  List<int> haftalikGunlukTamamlananDakikalar() {
    final startOfWeek = _getStartOfWeek();
    List<int> gunlukList = List.filled(7, 0);

    for (int i = 0; i < 7; i++) {
      final currentDay = startOfWeek.add(Duration(days: i));
      
      final oGunTamamlanan = _planlar.where((p) =>
          p.isDone &&
          p.tarih.year == currentDay.year &&
          p.tarih.month == currentDay.month &&
          p.tarih.day == currentDay.day);

      int sum = 0;
      for (var p in oGunTamamlanan) {
        final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
        final bitMin = p.bitis.hour * 60 + p.bitis.minute;
        sum += (bitMin - basMin).abs();
      }
      gunlukList[i] = sum;
    }

    return gunlukList;
  }

  // --- AYLIK İSTATİSTİKLER ---
  
  /// Belirtilen ayın (veya bu ayın) başlangıç tarihini döndürür
  DateTime _getStartOfMonth([DateTime? target]) {
    final t = target ?? DateTime.now();
    return DateTime(t.year, t.month, 1);
  }

  /// Bu ay (veya belirtilen ay) tamamlanan toplam dakika
  int aylikTamamlananDakika([DateTime? target]) {
    final startOfMonth = _getStartOfMonth(target);
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 1);
    
    return _planlar
        .where((p) =>
            p.isDone &&
            p.tarih.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) &&
            p.tarih.isBefore(endOfMonth))
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Bu ay planlanan toplam dakika
  int aylikToplamPlanDakika([DateTime? target]) {
    final startOfMonth = _getStartOfMonth(target);
    final endOfMonth = DateTime(startOfMonth.year, startOfMonth.month + 1, 1);
    
    return _planlar
        .where((p) =>
            p.tarih.isAfter(startOfMonth.subtract(const Duration(milliseconds: 1))) &&
            p.tarih.isBefore(endOfMonth))
        .fold(0, (sum, p) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      return sum + (bitMin - basMin).abs();
    });
  }

  /// Belirtilen ayın haftalık tamamlanan dakikalarını döndürür (4 haftalık veri)
  List<int> aylikHaftalikTamamlananDakikalar([DateTime? target]) {
    final startOfMonth = _getStartOfMonth(target);
    List<int> haftalikList = List.filled(4, 0);

    for (int i = 0; i < 4; i++) {
      final weekStart = startOfMonth.add(Duration(days: i * 7));
      final weekEnd = i == 3 ? DateTime(startOfMonth.year, startOfMonth.month + 1, 1) : weekStart.add(const Duration(days: 7)); // Son haftayı ay sonuna kadar uzat
      
      final oHaftaTamamlanan = _planlar.where((p) =>
          p.isDone &&
          p.tarih.isAfter(weekStart.subtract(const Duration(milliseconds: 1))) &&
          p.tarih.isBefore(weekEnd));

      int sum = 0;
      for (var p in oHaftaTamamlanan) {
        final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
        final bitMin = p.bitis.hour * 60 + p.bitis.minute;
        sum += (bitMin - basMin).abs();
      }
      haftalikList[i] = sum;
    }

    return haftalikList;
  }

  // --- ANALİZ VE STREAK ---

  /// Çalışma serisi (Kaç gündür aralıksız plan tamamlanıyor)
  int guncelCalismaSerisi() {
    if (_planlar.isEmpty) return 0;
    
    // Tarihe göre eşsiz ve tamamlanmış plan içeren günleri bul
    final tamamlananGunler = _planlar
        .where((p) => p.isDone)
        .map((p) => DateTime(p.tarih.year, p.tarih.month, p.tarih.day))
        .toSet()
        .toList();
        
    tamamlananGunler.sort((a, b) => b.compareTo(a)); // En yeniden eskiye

    if (tamamlananGunler.isEmpty) return 0;

    int streak = 0;
    DateTime kontrolGunu = DateTime(DateTime.now().year, DateTime.now().month, DateTime.now().day);

    // Eğer bugün henüz bir şey yapılmamışsa, düne bakarak başla
    if (!tamamlananGunler.contains(kontrolGunu)) {
      kontrolGunu = kontrolGunu.subtract(const Duration(days: 1));
    }

    for (final gun in tamamlananGunler) {
      if (gun.isAtSameMomentAs(kontrolGunu)) {
        streak++;
        kontrolGunu = kontrolGunu.subtract(const Duration(days: 1));
      } else {
        break; // Seri bozuldu
      }
    }

    return streak;
  }

  /// Belirtilen zaman dilimine göre derslerin tamamlanma süreleri
  Map<String, int> dersAnalizi(bool isAylik, [DateTime? target]) {
    final baslangic = isAylik ? _getStartOfMonth(target) : _getStartOfWeek();
    final bitis = isAylik ? DateTime(baslangic.year, baslangic.month + 1, 1) : baslangic.add(const Duration(days: 7));
    
    // Sistemdeki TÜM dersleri bul (geçmiş/gelecek fark etmeksizin)
    final Map<String, int> dersToplamDk = {};
    final tumDersler = _planlar.map((p) => p.ders).where((d) => d.trim().isNotEmpty).toSet();
    for (var ders in tumDersler) {
      dersToplamDk[ders] = 0; // Hepsini başlangıçta 0 dk olarak ekle
    }

    final donemPlanlari = _planlar.where((p) => 
        p.isDone && 
        p.tarih.isAfter(baslangic.subtract(const Duration(milliseconds: 1))) &&
        p.tarih.isBefore(bitis));

    for (final p in donemPlanlari) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      final sure = (bitMin - basMin).abs();
      
      dersToplamDk[p.ders] = (dersToplamDk[p.ders] ?? 0) + sure;
    }

    return dersToplamDk;
  }

  // =========================================================
  //  YOL HARİTASI ÖNERİLERİ
  // =========================================================

  /// 1) GÜNLÜK ÖNERİ — Bugün plana eklenmiş ama henüz yapılmadı (isDone=false) olan görevler.
  ///    Döndürdüğü harita: ders adı → toplam yapılmamış süre (dakika)
  Map<String, int> yapilmamisGorevler() {
    final now = DateTime.now();
    final bugunYapilmayanlar = _planlar.where((p) =>
        !p.isDone &&
        p.tarih.year == now.year &&
        p.tarih.month == now.month &&
        p.tarih.day == now.day);

    final Map<String, int> sonuc = {};
    for (final p in bugunYapilmayanlar) {
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      final sure = (bitMin - basMin).abs();
      sonuc[p.ders] = (sonuc[p.ders] ?? 0) + sure;
    }
    return sonuc;
  }

  /// Bugün yapılmamış görevlerin konu detaylarını da döndürür.
  List<PlanModel> yapilmamisGorevListesi() {
    final now = DateTime.now();
    return _planlar.where((p) =>
        !p.isDone &&
        p.tarih.year == now.year &&
        p.tarih.month == now.month &&
        p.tarih.day == now.day).toList()
      ..sort((a, b) {
        final aMin = a.baslangic.hour * 60 + a.baslangic.minute;
        final bMin = b.baslangic.hour * 60 + b.baslangic.minute;
        return aMin.compareTo(bMin);
      });
  }

  /// 2) HAFTALIK ÖNERİ — Bu hafta hangi ders en az çalışılmış?
  ///    Döndürür: {dersAdı: tamamlananDakika} — en az çalışılan en üstte (ascending sort)
  List<MapEntry<String, int>> haftalikAzCalisilanDersler() {
    final dersMap = dersAnalizi(false); // haftalık analiz
    if (dersMap.isEmpty) return [];

    final sirali = dersMap.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value)); // ascending (en az üstte)
    return sirali;
  }

  /// 3) AYLIK ÖNERİ — Geçen aya kıyasla hangi dersler düştü?
  ///    Döndürür: {dersAdı: farkDakika (negatif = düşüş)}
  List<MapEntry<String, int>> aylikKarsilastirma() {
    final buAy = dersAnalizi(true);
    final gecenAyTarih = DateTime(DateTime.now().year, DateTime.now().month - 1, 1);
    final gecenAy = dersAnalizi(true, gecenAyTarih);

    // Tüm derslerin birleşim kümesi
    final tumDersler = {...buAy.keys, ...gecenAy.keys};

    final Map<String, int> farklar = {};
    for (final ders in tumDersler) {
      final buAyDk = buAy[ders] ?? 0;
      final gecenAyDk = gecenAy[ders] ?? 0;
      farklar[ders] = buAyDk - gecenAyDk; // pozitif = artış, negatif = düşüş
    }

    // En çok düşen en üstte
    final sirali = farklar.entries.toList()
      ..sort((a, b) => a.value.compareTo(b.value));
    return sirali;
  }

  /// 4) KONU BAZLI — Bu hafta plana eklenip hiç tamamlanmayan konular
  ///    Döndürür: [{ders, konu, planSure}] — tamamlanmamış konular
  List<Map<String, dynamic>> haftaninAksatilanKonulari() {
    final startOfWeek = _getStartOfWeek();
    final endOfWeek = startOfWeek.add(const Duration(days: 7));

    // Bu haftanın tüm planlarını al
    final haftaninPlanlari = _planlar.where((p) =>
        p.tarih.isAfter(startOfWeek.subtract(const Duration(milliseconds: 1))) &&
        p.tarih.isBefore(endOfWeek));

    // Konu bazlı: planlanan süre vs tamamlanan süre
    final Map<String, int> konuPlanlanan = {}; // "ders|konu" → toplam planlanan dk
    final Map<String, int> konuTamamlanan = {}; // "ders|konu" → toplam tamamlanan dk

    for (final p in haftaninPlanlari) {
      final key = '${p.ders}|${p.konu}';
      final basMin = p.baslangic.hour * 60 + p.baslangic.minute;
      final bitMin = p.bitis.hour * 60 + p.bitis.minute;
      final sure = (bitMin - basMin).abs();

      konuPlanlanan[key] = (konuPlanlanan[key] ?? 0) + sure;
      if (p.isDone) {
        konuTamamlanan[key] = (konuTamamlanan[key] ?? 0) + sure;
      }
    }

    // Hiç tamamlanmamış veya çok az tamamlanmış konular
    final List<Map<String, dynamic>> aksatilanlar = [];
    for (final entry in konuPlanlanan.entries) {
      final tamamlanan = konuTamamlanan[entry.key] ?? 0;
      final tamamlanmaOrani = entry.value > 0 ? tamamlanan / entry.value : 0;

      if (tamamlanmaOrani < 0.3) {
        // %30'dan az tamamlanmış = aksatılmış
        final parts = entry.key.split('|');
        aksatilanlar.add({
          'ders': parts[0],
          'konu': parts.length > 1 ? parts[1] : '',
          'planSure': entry.value,
          'tamamlanan': tamamlanan,
          'oran': tamamlanmaOrani,
        });
      }
    }

    // En çok aksatılan en üstte
    aksatilanlar.sort((a, b) =>
        (a['oran'] as double).compareTo(b['oran'] as double));

    return aksatilanlar;
  }

  /// 5) KONU TEKRAR ÖNERİSİ — Son 14 günde en son ne zaman çalışıldığını bulur
  ///    Döndürür: [{ders, konu, gunOnce}] — uzun süredir çalışılmayan konular
  List<Map<String, dynamic>> uzunSuredirCalisilmayanKonular() {
    final now = DateTime.now();
    final ikiHaftaOnce = now.subtract(const Duration(days: 14));

    // Son 14 günün tamamlanan planlarını al
    final sonPlanlari = _planlar.where((p) =>
        p.isDone &&
        p.tarih.isAfter(ikiHaftaOnce.subtract(const Duration(milliseconds: 1))));

    // Her ders+konu için en son çalışılan tarihi bul
    final Map<String, DateTime> sonCalisilma = {};
    for (final p in sonPlanlari) {
      final key = '${p.ders}|${p.konu}';
      if (!sonCalisilma.containsKey(key) || p.tarih.isAfter(sonCalisilma[key]!)) {
        sonCalisilma[key] = p.tarih;
      }
    }

    // Sistemdeki TÜM benzersiz ders+konu çiftlerini bul
    final tumKonular = _planlar
        .where((p) => p.konu.trim().isNotEmpty)
        .map((p) => '${p.ders}|${p.konu}')
        .toSet();

    final List<Map<String, dynamic>> sonuc = [];
    for (final key in tumKonular) {
      final parts = key.split('|');
      final ders = parts[0];
      final konu = parts.length > 1 ? parts[1] : '';

      if (sonCalisilma.containsKey(key)) {
        final gunFarki = now.difference(sonCalisilma[key]!).inDays;
        if (gunFarki >= 5) {
          // 5+ gündür çalışılmamış
          sonuc.add({
            'ders': ders,
            'konu': konu,
            'gunOnce': gunFarki,
          });
        }
      } else {
        // Hiç tamamlanmamış ama planda var
        sonuc.add({
          'ders': ders,
          'konu': konu,
          'gunOnce': 99, // Hiç çalışılmamış olarak işaretle
        });
      }
    }

    // En uzun süredir çalışılmayan en üstte
    sonuc.sort((a, b) => (b['gunOnce'] as int).compareTo(a['gunOnce'] as int));

    return sonuc;
  }
}


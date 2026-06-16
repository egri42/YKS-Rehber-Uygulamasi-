import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// Tek bir tamamlanan Pomodoro seansını temsil eder.
class StudySession {
  final String id;
  final String ders;
  final int odakDakika;
  final DateTime tarih;

  StudySession({
    required this.id,
    required this.ders,
    required this.odakDakika,
    required this.tarih,
  });

  Map<String, dynamic> toFirestore() => {
    'ders': ders,
    'odakDakika': odakDakika,
    'tarih': Timestamp.fromDate(tarih),
  };

  factory StudySession.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StudySession(
      id: doc.id,
      ders: data['ders'] ?? '',
      odakDakika: data['odakDakika'] ?? 0,
      tarih: (data['tarih'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }
}

/// Pomodoro seanslarını bellekte ve Firestore'da tutan singleton Store.
class StudySessionStore extends ChangeNotifier {
  static final StudySessionStore _instance = StudySessionStore._internal();
  factory StudySessionStore() => _instance;

  StudySessionStore._internal();

  CollectionReference? _koleksiyon;
  StreamSubscription? _subscription;
  String? _uid;

  final List<StudySession> _seanslar = [];

  /// Kullanıcı giriş yaptığında çağrılır. Firestore dinlemesini başlatır.
  void initialize(String uid) {
    if (_uid == uid) return;
    dispose();
    _uid = uid;
    _koleksiyon = FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('study_sessions');
    _dinlemeBaslat();
  }

  /// Kullanıcı çıkış yaptığında çağrılır. Dinlemeyi durdurur ve verileri temizler.
  void dispose() {
    _subscription?.cancel();
    _subscription = null;
    _seanslar.clear();
    _uid = null;
    _koleksiyon = null;
    notifyListeners();
  }

  void _dinlemeBaslat() {
    if (_koleksiyon == null) return;
    _subscription = _koleksiyon!.snapshots().listen(
      (snapshot) {
        _seanslar.clear();
        for (final doc in snapshot.docs) {
          try {
            _seanslar.add(StudySession.fromFirestore(doc));
          } catch (_) {}
        }
        notifyListeners();
      },
      onError: (error) {
        debugPrint('StudySessionStore Firestore hatası: $error');
      },
    );
  }

  /// Yeni bir tamamlanmış seans ekler (Firestore'a yazar).
  Future<void> seansEkle(String ders, int odakDakika) async {
    if (_koleksiyon == null) return;
    final docRef = _koleksiyon!.doc(); // Otomatik ID
    final seans = StudySession(
      id: docRef.id,
      ders: ders,
      odakDakika: odakDakika,
      tarih: DateTime.now(),
    );
    await docRef.set(seans.toFirestore());
  }

  /// Sadece bugünkü seansları döndürür.
  List<StudySession> bugunkunSeanslar() {
    final now = DateTime.now();
    return _seanslar.where((s) {
      return s.tarih.year == now.year &&
          s.tarih.month == now.month &&
          s.tarih.day == now.day;
    }).toList();
  }

  /// Bugün Pomodoro ile geçirilen toplam odak süresi (dakika).
  int bugunToplamOdakDakika() {
    return bugunkunSeanslar().fold(0, (sum, s) => sum + s.odakDakika);
  }

  /// Bugün kaç farklı Pomodoro seansı tamamlandı.
  int bugunSeansAdedi() => bugunkunSeanslar().length;

  /// Bugün ortalama odaklanma süresi (dakika). Seans yoksa 0.
  int bugunOrtalamaOdak() {
    final seanslar = bugunkunSeanslar();
    if (seanslar.isEmpty) return 0;
    final toplam = seanslar.fold(0, (sum, s) => sum + s.odakDakika);
    return (toplam / seanslar.length).round();
  }

  /// Bugün en çok çalışılan ders adını döndürür. Yoksa null.
  String? bugunEnCokCalisilaniDers() {
    final seanslar = bugunkunSeanslar();
    if (seanslar.isEmpty) return null;

    final Map<String, int> dersToplamDk = {};
    for (final s in seanslar) {
      dersToplamDk[s.ders] = (dersToplamDk[s.ders] ?? 0) + s.odakDakika;
    }

    return dersToplamDk.entries
        .reduce((a, b) => a.value >= b.value ? a : b)
        .key;
  }
}

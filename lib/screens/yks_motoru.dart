// MEHMET EMİN EĞRİ 231213053  HİBRİT KARAR DESTEK MEKANİZMALI DERS TAKİP UYGULAMASI

class YksSonuc {
  final double tytPuan; final double sayPuan; final double eaPuan; final double sozPuan;
  final String tytSiralama; final String saySiralama; final String eaSiralama; final String sozSiralama;

  YksSonuc({
    required this.tytPuan, required this.sayPuan, required this.eaPuan, required this.sozPuan,
    required this.tytSiralama, required this.saySiralama, required this.eaSiralama, required this.sozSiralama,
  });
}

class YksMotoru {
  static YksSonuc hesapla({
    required double obp, required String secilenYil,
    double tytTr = 0, double tytSos = 0, double tytMat = 0, double tytFen = 0,
    double aytMat = 0, double aytFiz = 0, double aytKim = 0, double aytBiyo = 0,
    double aytEdb = 0, double aytTar1 = 0, double aytCog1 = 0,
    double aytTar2 = 0, double aytCog2 = 0, double aytFel = 0, double aytDin = 0,
  }) {
    double obpK = (obp * 0.6).clamp(30.0, 60.0);

    // --- DEĞİŞKEN TANIMLARI ---
    double bTyt, bSay, bEa, bSoz;
    double tK_tr, tK_sos, tK_mat, tK_fen; // TYT Puanı Katsayıları
    double sK_tr, sK_sos, sK_mat, sK_fen, aK_matS, aK_fiz, aK_kim, aK_biy; // Sayısal
    double eK_tr, eK_sos, eK_mat, eK_fen, aK_matE, aK_edb, aK_tar1, aK_cog1; // EA
    double zK_tr, zK_sos, zK_mat, zK_fen, aK_edbZ, aK_tar1Z, aK_cog1Z, aK_tar2, aK_cog2, aK_fel, aK_din; // Sözel

    if (secilenYil == "2024") {
      bTyt = 144.953; bSay = 133.28; bEa = 132.28; bSoz = 130.36;
      // TYT Tablosu
      tK_tr = 2.91; tK_sos = 2.94; tK_mat = 2.93; tK_fen = 3.15;
      // Sayısal Tablosu
      sK_tr = 1.11; sK_sos = 1.12; sK_mat = 1.11; sK_fen = 1.20;
      aK_matS = 3.19; aK_fiz = 2.43; aK_kim = 3.07; aK_biy = 2.51;
      // EA Tablosu
      eK_tr = 1.14; eK_sos = 1.15; eK_mat = 1.15; eK_fen = 1.23;
      aK_matE = 3.28; aK_edb = 2.83; aK_tar1 = 2.38; aK_cog1 = 2.54;
      // Sözel Tablosu
      zK_tr = 1.23; zK_sos = 1.24; zK_mat = 1.24; zK_fen = 1.33;
      aK_edbZ = 3.06; aK_tar1Z = 2.57; aK_cog1Z = 2.74;
      aK_tar2 = 3.16; aK_cog2 = 2.82; aK_fel = 3.85; aK_din = 3.13;

    } else {
      bTyt = 145.47; bSay = 132.87; bEa = 129.34; bSoz = 129.61;
      tK_tr = 2.83; tK_sos = 2.99; tK_mat = 3.28; tK_fen = 2.53;
      sK_tr = 1.20; sK_sos = 1.27; sK_mat = 1.39; sK_fen = 1.07;
      aK_matS = 2.89; aK_fiz = 2.46; aK_kim = 2.53; aK_biy = 2.61;
      eK_tr = 1.19; eK_sos = 1.26; eK_mat = 1.38; eK_fen = 1.07;
      aK_matE = 2.88; aK_edb = 2.94; aK_tar1 = 2.53; aK_cog1 = 2.85;
      zK_tr = 1.13; zK_sos = 1.19; zK_mat = 1.31; zK_fen = 1.01;
      aK_edbZ = 2.79; aK_tar1Z = 2.39; aK_cog1Z = 2.70; aK_tar2 = 3.80; aK_cog2 = 2.47; aK_fel = 3.76; aK_din = 2.36;
    }

    // --- HESAPLAMA MOTORU (Yerleştirme Puanları) ---
    // TYT Yerleştirme
    double tytP = bTyt + (tytTr * tK_tr) + (tytSos * tK_sos) + (tytMat * tK_mat) + (tytFen * tK_fen) + obpK;

    // SAY Yerleştirme
    double sayP = bSay + (tytTr * sK_tr) + (tytSos * sK_sos) + (tytMat * sK_mat) + (tytFen * sK_fen) +
        (aytMat * aK_matS) + (aytFiz * aK_fiz) + (aytKim * aK_kim) + (aytBiyo * aK_biy) + obpK;

    // EA Yerleştirme
    double eaP = bEa + (tytTr * eK_tr) + (tytSos * eK_sos) + (tytMat * eK_mat) + (tytFen * eK_fen) +
        (aytMat * aK_matE) + (aytEdb * aK_edb) + (aytTar1 * aK_tar1) + (aytCog1 * aK_cog1) + obpK;

    // SÖZ Yerleştirme
    double sozP = bSoz + (tytTr * zK_tr) + (tytSos * zK_sos) + (tytMat * zK_mat) + (tytFen * zK_fen) +
        (aytEdb * aK_edbZ) + (aytTar1 * aK_tar1Z) + (aytCog1 * aK_cog1Z) +
        (aytTar2 * aK_tar2) + (aytCog2 * aK_cog2) + (aytFel * aK_fel) + (aytDin * aK_din) + obpK;

    // --- SIRALAMA VERİ SEÇİMİ ---
    Map<double, int> sayT = (secilenYil == "2024") ? _s24 : _s25;
    Map<double, int> eaT = (secilenYil == "2024") ? _e24 : _e25;
    Map<double, int> szT = (secilenYil == "2024") ? _sz24 : _sz25;
    Map<double, int> tytT = (secilenYil == "2024") ? _tyt24 : _tyt25;

    return YksSonuc(
      tytPuan: tytP.clamp(0, 560), sayPuan: sayP.clamp(0, 560), eaPuan: eaP.clamp(0, 560), sozPuan: sozP.clamp(0, 560),
      tytSiralama: _bul(tytP, tytT), saySiralama: _bul(sayP, sayT),
      eaSiralama: _bul(eaP, eaT), sozSiralama: _bul(sozP, szT),
    );
  }

  // --- RESMİ SIRALAMA VERİLERİ ---
  static final Map<double, int> _tyt24 = {550:59, 530:3017, 510:12996, 490:29976, 470:53253, 450:82281, 410:163769, 350:412255, 300:761711, 250:1652661};
  static final Map<double, int> _s24 = {550:162, 530:2271, 510:7029, 490:14673, 470:25274, 450:38578, 410:72418, 390:93485, 350:148110, 300:300531, 250:531055};
  static final Map<double, int> _e24 = {550:5, 530:80, 510:340, 490:940, 470:1992, 450:4269, 410:24612, 350:126223, 300:422338, 250:831379};
  static final Map<double, int> _sz24 = {550:3, 530:31, 510:142, 490:476, 470:1292, 450:3424, 430:8952, 410:21706, 390:45376, 370:83547, 350:139921, 330:219810, 310:328161, 290:471676, 270:652313, 250:860119};
  static final Map<double, int> _tyt25 = {550:14, 530:601, 510:3648, 490:11733, 470:27141, 450:52500, 430:88915, 410:137133, 390:201126, 370:286158, 350:397823, 330:545280, 310:737144, 290:976188, 270:1251236, 250:1542701};
  static final Map<double, int> _s25 = {550:57, 530:1930, 510:7081, 490:16140, 470:29410, 450:46142, 430:65449, 410:87117, 390:111498, 370:139619, 350:174355, 330:217778, 310:274252, 290:348397, 270:449880, 250:596635};
  static final Map<double, int> _e25 = {550:4, 530:58, 510:261, 490:742, 470:1629, 450:3422, 430:8145, 410:20244, 390:42590, 370:76959, 350:125389, 330:192949, 310:287630, 290:418975, 270:592803, 250:806796};
  static final Map<double, int> _sz25 = {550:1, 530:7, 510:26, 490:77, 470:254, 450:721, 430:1926, 410:5036, 390:12522, 370:28323, 350:57848, 330:108894, 310:190203, 290:309551, 270:468930, 250:658973};

  static String _bul(double p, Map<double, int>? t) {
    if (t == null || t.isEmpty) return "N/A";
    double maxP = t.keys.reduce((a, b) => a > b ? a : b);
    double minP = t.keys.reduce((a, b) => a < b ? a : b);
    if (p >= maxP) return t[maxP].toString();
    if (p <= minP) return "${t[minP]}+";
    double uP = maxP; int uS = t[maxP]!;
    double aP = minP; int aS = t[minP]!;
    t.forEach((k, v) {
      if (k >= p && k <= uP) { uP = k; uS = v; }
      if (k <= p && k >= aP) { aP = k; aS = v; }
    });
    int res = (uP == aP) ? uS : uS + (((uP - p) / (uP - aP)) * (aS - uS)).round();
    return res.toString().replaceAllMapped(RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'), (m) => '${m[1]}.');
  }
}
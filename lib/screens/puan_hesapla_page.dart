import 'package:flutter/material.dart';
import 'yks_motoru.dart';

class PuanHesaplaPage extends StatefulWidget {
  const PuanHesaplaPage({super.key});
  @override
  State<PuanHesaplaPage> createState() => _PuanHesaplaPageState();
}

class _PuanHesaplaPageState extends State<PuanHesaplaPage> {
  String _yil = "2025";
  double _obp = 85.0;

  // TYT Netleri
  double _tr = 30, _mat = 25, _sos = 15, _fen = 10;

  // AYT Sayısal Netleri
  double _aMat = 20, _aFiz = 5, _aKim = 5, _aBio = 5;

  // AYT Sosyal-1 Netleri (EA & SÖZ)
  double _aEdb = 15, _aTar1 = 5, _aCog1 = 4;

  // AYT Sosyal-2 Netleri (SADECE SÖZEL)
  double _aTar2 = 5, _aCog2 = 5, _aFel = 6, _aDin = 6;

  @override
  Widget build(BuildContext context) {
    var s = YksMotoru.hesapla(
      obp: _obp,
      secilenYil: _yil,
      tytTr: _tr,
      tytMat: _mat,
      tytSos: _sos,
      tytFen: _fen,
      aytMat: _aMat,
      aytFiz: _aFiz,
      aytKim: _aKim,
      aytBiyo: _aBio,
      aytEdb: _aEdb,
      aytTar1: _aTar1,
      aytCog1: _aCog1,
      aytTar2: _aTar2,
      aytCog2: _aCog2,
      aytFel: _aFel,
      aytDin: _aDin,
    );

    return Scaffold(
      backgroundColor: const Color(0xFFF5F7FA),
      appBar: AppBar(
        title: const Text("YKS Sıralama Tahmini"),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.only(bottom: 180),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: SegmentedButton<String>(
                segments: const [
                  ButtonSegment(value: "2025", label: Text("2025")),
                  ButtonSegment(value: "2024", label: Text("2024")),
                ],
                selected: {_yil},
                onSelectionChanged: (v) => setState(() => _yil = v.first),
              ),
            ),

            _section("TYT NETLERİN", [
              _card(
                "OBP (Diploma Notu)",
                _obp,
                50,
                100,
                (v) => setState(() => _obp = v),
                isObp: true,
              ),
              _card("Türkçe", _tr, 0, 40, (v) => setState(() => _tr = v)),
              _card("Matematik", _mat, 0, 40, (v) => setState(() => _mat = v)),
              _card(
                "Sosyal Bilimler",
                _sos,
                0,
                20,
                (v) => setState(() => _sos = v),
              ),
              _card(
                "Fen Bilimleri",
                _fen,
                0,
                20,
                (v) => setState(() => _fen = v),
              ),
            ]),

            _section("AYT SAYISAL", [
              _card(
                "AYT Matematik",
                _aMat,
                0,
                40,
                (v) => setState(() => _aMat = v),
              ),
              _card("Fizik", _aFiz, 0, 14, (v) => setState(() => _aFiz = v)),
              _card("Kimya", _aKim, 0, 13, (v) => setState(() => _aKim = v)),
              _card("Biyoloji", _aBio, 0, 13, (v) => setState(() => _aBio = v)),
            ]),

            _section("AYT EDEBİYAT & SOSYAL-1", [
              _card("Edebiyat", _aEdb, 0, 24, (v) => setState(() => _aEdb = v)),
              _card(
                "Tarih-1",
                _aTar1,
                0,
                10,
                (v) => setState(() => _aTar1 = v),
              ),
              _card(
                "Coğrafya-1",
                _aCog1,
                0,
                6,
                (v) => setState(() => _aCog1 = v),
              ),
            ]),

            _section("AYT SOSYAL-2 (SÖZEL İÇİN)", [
              _card(
                "Tarih-2",
                _aTar2,
                0,
                11,
                (v) => setState(() => _aTar2 = v),
              ),
              _card(
                "Coğrafya-2",
                _aCog2,
                0,
                11,
                (v) => setState(() => _aCog2 = v),
              ),
              _card(
                "Felsefe Grubu",
                _aFel,
                0,
                12,
                (v) => setState(() => _aFel = v),
              ),
              _card(
                "Din Kültürü",
                _aDin,
                0,
                6,
                (v) => setState(() => _aDin = v),
              ),
            ]),
          ],
        ),
      ),
      bottomSheet: _buildBottomResultPanel(s),
    );
  }

  Widget _section(String t, List<Widget> c) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(20, 24, 0, 8),
          child: Text(
            t,
            style: const TextStyle(
              fontWeight: FontWeight.bold,
              color: Colors.indigo,
              fontSize: 13,
              letterSpacing: 1.1,
            ),
          ),
        ),
        ...c,
      ],
    );
  }

  // --- KESİN 0.25 HASSASİYETİ SAĞLAYAN KART ---
  Widget _card(
    String title,
    double value,
    double min,
    double max,
    Function(double) onChanged, {
    bool isObp = false,
  }) {
    // Netler için 0.25 (x4), OBP için 0.1 (x10) bölme
    int div = isObp ? ((max - min) * 10).toInt() : ((max - min) * 4).toInt();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(color: Colors.black.withOpacity(0.02), blurRadius: 5),
        ],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(title, style: const TextStyle(fontWeight: FontWeight.w500)),
              Text(
                value.toStringAsFixed(isObp ? 1 : 2),
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.indigo,
                ),
              ),
            ],
          ),
          Slider(
            value: value,
            min: min,
            max: max,
            divisions: div > 0 ? div : 1,
            activeColor: Colors.indigo,
            onChanged: (double newValue) {
              // Matematiksel yuvarlama: 0.25'e zorluyoruz
              double step = isObp ? 10.0 : 4.0;
              double roundedValue = (newValue * step).round() / step;
              onChanged(roundedValue);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBottomResultPanel(YksSonuc s) {
    return Container(
      height: 170,
      width: double.infinity,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 20)],
      ),
      child: Column(
        children: [
          const SizedBox(height: 10),
          Container(
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.grey[300],
              borderRadius: BorderRadius.circular(2),
            ),
          ),
          Expanded(
            child: GridView.count(
              crossAxisCount: 2,
              childAspectRatio: 2.8,
              physics: const NeverScrollableScrollPhysics(),
              children: [
                _resItem("TYT YER.", s.tytPuan, s.tytSiralama, Colors.teal),
                _resItem(
                  "SAYISAL YER.",
                  s.sayPuan,
                  s.saySiralama,
                  Colors.pinkAccent,
                ),
                _resItem(
                  "EA YERLEŞTİRME",
                  s.eaPuan,
                  s.eaSiralama,
                  Colors.blueAccent,
                ),
                _resItem(
                  "SÖZEL YER.",
                  s.sozPuan,
                  s.sozSiralama,
                  Colors.orangeAccent,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _resItem(String t, double p, String s, Color c) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Text(
          t,
          style: TextStyle(color: c, fontWeight: FontWeight.bold, fontSize: 10),
        ),
        Text(
          p.toStringAsFixed(1),
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900),
        ),
        Text(
          s,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.bold,
            color: Colors.black87,
          ),
        ),
      ],
    );
  }
}

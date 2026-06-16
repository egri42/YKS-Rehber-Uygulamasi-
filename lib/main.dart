import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'package:flutter/material.dart';
import 'screens/home_page.dart';
import 'screens/study_tracking_page.dart';
import 'screens/pomodoro_page.dart';
import 'screens/PlanPage.dart';
import 'screens/auth_page.dart';
import 'plan_store.dart';
import 'logic/study_session_store.dart';
import 'services/auth_service.dart';
import 'package:intl/date_symbol_data_local.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // 1. Firebase'i başlatıyoruz
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // 2. Türkçe tarih formatı ayarı
  await initializeDateFormatting('tr_TR', null);

  // 3. Uygulamayı çalıştırıyoruz
  runApp(const YksRehberApp());
}

class YksRehberApp extends StatelessWidget {
  const YksRehberApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'YKS Rehber',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.deepPurple),
      home: const AuthWrapper(),
    );
  }
}

/// Auth durumuna göre giriş sayfası veya ana ekranı gösterir.
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      initialData: AuthService().currentUser,
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        // Bağlantı bekleniyor
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        // Kullanıcı giriş yapmışsa store'ları başlat ve ana ekranı göster
        if (snapshot.hasData && snapshot.data != null) {
          final uid = snapshot.data!.uid;
          PlanStore().initialize(uid);
          StudySessionStore().initialize(uid);
          return const MainScreen();
        }

        // Kullanıcı giriş yapmamışsa auth sayfasını göster
        PlanStore().dispose();
        StudySessionStore().dispose();
        return const AuthPage();
      },
    );
  }
}

class MainScreen extends StatefulWidget {
  const MainScreen({super.key});

  @override
  _MainScreenState createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  final List<Widget> _pages = [
    const HomePage(),
    const PlanPage(),
    const StudyTrackingPage(),
    const PomodoroPage(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        type: BottomNavigationBarType.fixed,
        currentIndex: _selectedIndex,
        selectedItemColor:
            Colors.indigoAccent,
        unselectedItemColor: Colors.grey,
        onTap: _onItemTapped,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home_rounded),
            label: 'Anasayfa',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.calendar_month_rounded),
            label: 'Plan',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.analytics_rounded),
            label: 'Takip',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.timer_rounded),
            label: 'Pomodoro',
          ),
        ],
      ),
    );
  }
}

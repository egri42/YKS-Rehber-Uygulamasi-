import 'package:firebase_auth/firebase_auth.dart';

/// Firebase Authentication işlemlerini yöneten Singleton servis sınıfı.
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Mevcut oturum açmış kullanıcı (null = giriş yapılmamış).
  User? get currentUser => _auth.currentUser;

  /// Mevcut kullanıcının UID'si. Giriş yapılmamışsa null.
  String? get uid => _auth.currentUser?.uid;

  /// Auth durumundaki değişiklikleri dinler.
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  /// E-posta ve şifre ile yeni kullanıcı oluşturur.
  Future<UserCredential> register(String email, String password) async {
    return await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// E-posta ve şifre ile giriş yapar.
  Future<UserCredential> login(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  /// Oturumu kapatır.
  Future<void> logout() async {
    await _auth.signOut();
  }
}

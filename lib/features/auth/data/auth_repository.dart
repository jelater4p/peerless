// Kayıt, giriş, e-posta doğrulama ve şifre işlemleri (Supabase Auth).
// Doğrulama ve şifre sıfırlama e-postadaki 6 haneli kodla yapılır;
// böylece derin link (deep link) kurulumu gerekmez.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';

class AuthRepository {
  AuthRepository(this._client);
  final SupabaseClient _client;

  GoTrueClient get _auth => _client.auth;

  Future<void> signIn({required String email, required String password}) =>
      _auth.signInWithPassword(email: email.trim(), password: password);

  /// Kayıt sonrası oturum açılmaz; e-postaya doğrulama kodu gider.
  Future<void> signUp({required String email, required String password, required String locale}) =>
      _auth.signUp(email: email.trim(), password: password, data: {'locale': locale});

  Future<void> verifySignUp({required String email, required String code}) =>
      _auth.verifyOTP(type: OtpType.signup, email: email.trim(), token: code.trim());

  Future<void> resendSignUpCode(String email) => _auth.resend(type: OtpType.signup, email: email.trim());

  Future<void> sendPasswordResetCode(String email) => _auth.resetPasswordForEmail(email.trim());

  /// Koddan sonra oturum açılır ve yeni şifre hemen kaydedilir.
  Future<void> resetPassword({required String email, required String code, required String newPassword}) async {
    await _auth.verifyOTP(type: OtpType.recovery, email: email.trim(), token: code.trim());
    await _auth.updateUser(UserAttributes(password: newPassword));
  }

  Future<void> changePassword(String newPassword) => _auth.updateUser(UserAttributes(password: newPassword));

  /// Yeni adrese doğrulama kodu gider; kodla onaylanınca değişir.
  Future<void> requestEmailChange(String newEmail) => _auth.updateUser(UserAttributes(email: newEmail.trim()));

  Future<void> verifyEmailChange({required String newEmail, required String code}) =>
      _auth.verifyOTP(type: OtpType.emailChange, email: newEmail.trim(), token: code.trim());

  Future<void> signOut() => _auth.signOut();

  String? get currentEmail => _auth.currentUser?.email;
}

final authRepositoryProvider = Provider<AuthRepository>((ref) => AuthRepository(ref.watch(supabaseProvider)));

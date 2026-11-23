// Oturum durumu: kim giriş yaptı, profil kurulumu bitti mi, banlı mı?
// Router bu duruma bakarak kullanıcıyı doğru ekrana yönlendirir.
import 'dart:async';
import 'dart:convert';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../features/profile/data/profile.dart';
import '../../features/profile/data/profile_repository.dart';
import '../errors/error_text.dart';
import '../settings/app_settings.dart';
import '../supabase/supabase_providers.dart';

enum SessionStatus {
  /// Açılışta oturum kontrol ediliyor.
  loading,

  /// Giriş yapılmamış.
  signedOut,

  /// Giriş yapılmış ama nickname seçilmemiş (onboarding).
  needsNickname,

  /// Her şey hazır.
  ready,

  /// İnternet yok ve önbellekte profil de yok.
  offline,
}

@immutable
class SessionState {
  const SessionState(this.status, [this.profile, this.wasBanned = false, this.onboarding = false]);
  final SessionStatus status;
  final Profile? profile;

  /// Nickname yeni seçildi; profil fotoğrafı + biyografi adımı gösterilecek.
  final bool onboarding;

  /// Hesap banlandığı için oturum kapatıldıysa giriş ekranında uyarı gösterilir.
  final bool wasBanned;

  bool get isAdmin => profile?.isAdmin ?? false;
}

class SessionController extends Notifier<SessionState> {
  static const _kCachedProfile = 'cached_profile';
  StreamSubscription<AuthState>? _sub;
  int _loadSeq = 0;
  bool _bannedNotice = false;

  SupabaseClient get _client => ref.read(supabaseProvider);

  @override
  SessionState build() {
    _sub = _client.auth.onAuthStateChange.listen((data) {
      switch (data.event) {
        case AuthChangeEvent.initialSession:
        case AuthChangeEvent.signedIn:
        case AuthChangeEvent.userUpdated:
        case AuthChangeEvent.signedOut:
          refresh();
        default:
          break;
      }
    });
    ref.onDispose(() => _sub?.cancel());
    return const SessionState(SessionStatus.loading);
  }

  /// Profili sunucudan yeniden okur ve durumu günceller.
  Future<void> refresh() async {
    final seq = ++_loadSeq;
    final user = _client.auth.currentUser;
    if (user == null) {
      _clearCache();
      state = SessionState(SessionStatus.signedOut, null, _bannedNotice);
      _bannedNotice = false;
      return;
    }
    try {
      final profile = await ref.read(profileRepositoryProvider).getMyProfile();
      if (seq != _loadSeq) return; // daha yeni bir yükleme başladı
      if (profile == null || profile.isBanned) {
        // Banlı hesap: oturum kapatılır, tekrar giriş yapılamaz.
        _bannedNotice = profile?.isBanned ?? false;
        await _client.auth.signOut();
        return;
      }
      _cache(profile);
      state = SessionState(profile.hasNickname ? SessionStatus.ready : SessionStatus.needsNickname, profile);
    } catch (e) {
      if (seq != _loadSeq) return;
      final cached = _readCache(user.id);
      if (isNetworkError(e) && cached != null && cached.hasNickname) {
        // Çevrimdışı açılış: son bilinen profille devam.
        state = SessionState(SessionStatus.ready, cached);
      } else {
        // İnternet yok (veya sunucu hatası): açılış ekranında "tekrar dene".
        state = const SessionState(SessionStatus.offline);
      }
    }
  }

  /// Profil değiştikten sonra ekranlardan çağrılır.
  void setProfile(Profile profile, {bool onboarding = false}) {
    _cache(profile);
    state = SessionState(
      profile.hasNickname ? SessionStatus.ready : SessionStatus.needsNickname,
      profile,
      false,
      onboarding || state.onboarding,
    );
  }

  /// Onboarding'in son adımı (fotoğraf + biyografi) bitti veya atlandı.
  void finishOnboarding() {
    state = SessionState(state.status, state.profile);
  }

  void _cache(Profile p) =>
      ref.read(sharedPreferencesProvider).setString(_kCachedProfile, jsonEncode(p.toJson()));

  void _clearCache() => ref.read(sharedPreferencesProvider).remove(_kCachedProfile);

  Profile? _readCache(String uid) {
    final raw = ref.read(sharedPreferencesProvider).getString(_kCachedProfile);
    if (raw == null) return null;
    final p = Profile.fromJson(jsonDecode(raw) as Map<String, dynamic>);
    return p.id == uid ? p : null;
  }
}

final sessionProvider = NotifierProvider<SessionController, SessionState>(SessionController.new);

/// Giriş yapmış kullanıcının profili (yoksa null).
final myProfileProvider = Provider<Profile?>((ref) => ref.watch(sessionProvider).profile);

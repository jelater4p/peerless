import 'dart:async';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../core/config/env.dart';
import '../../core/router/app_router.dart';
import 'data/notification_repository.dart';

/// Okunmamış bildirim sayısı (alt navigasyondaki rozet).
/// Yeni bildirim satırı eklenince Supabase Realtime ile anında yenilenir.
class UnreadCountController extends Notifier<int> {
  RealtimeChannel? _channel;

  @override
  int build() {
    final repo = ref.watch(notificationRepositoryProvider);
    try {
      _channel = repo.subscribe(refresh);
    } catch (_) {}
    ref.onDispose(() => _channel?.unsubscribe());
    Future.microtask(refresh);
    return 0;
  }

  Future<void> refresh() async {
    try {
      final n = await ref.read(notificationRepositoryProvider).unreadCount();
      if (ref.mounted) state = n;
    } catch (_) {
      // Çevrimdışıyken son değer kalır.
    }
  }

  void clear() => state = 0;
}

final unreadCountProvider = NotifierProvider<UnreadCountController, int>(UnreadCountController.new);

/// Firebase Cloud Messaging: izin ister, cihaz anahtarını kaydeder,
/// bildirime dokunulunca ilgili içeriği açar.
class PushService {
  PushService(this._ref);
  final Ref _ref;
  bool _started = false;
  final _subs = <StreamSubscription<dynamic>>[];

  Future<void> start() async {
    if (_started || !Env.hasFirebase) return;
    _started = true;
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp(
          options: const FirebaseOptions(
            apiKey: Env.firebaseApiKey,
            appId: Env.firebaseAppId,
            messagingSenderId: Env.firebaseSenderId,
            projectId: Env.firebaseProjectId,
          ),
        );
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final repo = _ref.read(notificationRepositoryProvider);
      // Not: firebase_messaging 17 yeni bir register()/onRegistered (FID) API'si
      // getirdi. Sunucudaki FCM v1 gönderimi klasik kayıt anahtarıyla (token)
      // kanıtlanmış şekilde çalıştığı için bilinçli olarak klasik API kullanılıyor.
      // ignore: deprecated_member_use
      final token = await messaging.getToken();
      if (token != null) await repo.registerDeviceToken(token);
      _subs
        // ignore: deprecated_member_use
        ..add(messaging.onTokenRefresh.listen(repo.registerDeviceToken))
        ..add(FirebaseMessaging.onMessage.listen((_) => _ref.read(unreadCountProvider.notifier).refresh()))
        ..add(FirebaseMessaging.onMessageOpenedApp.listen(_open));
      final initial = await messaging.getInitialMessage();
      if (initial != null) _open(initial);
    } catch (e) {
      debugPrint('Push başlatılamadı: $e');
    }
  }

  void _open(RemoteMessage message) {
    final router = _ref.read(routerProvider);
    final postId = message.data['post_id'] as String?;
    if (postId != null && postId.isNotEmpty) {
      router.push(Routes.post(postId));
    } else {
      router.go(Routes.notifications);
    }
  }

  /// Çıkış yapmadan önce: bu cihaza artık bildirim gitmesin.
  Future<void> stop() async {
    for (final s in _subs) {
      await s.cancel();
    }
    _subs.clear();
    if (!_started) return;
    _started = false;
    try {
      // ignore: deprecated_member_use
      final token = await FirebaseMessaging.instance.getToken();
      if (token != null) await _ref.read(notificationRepositoryProvider).removeDeviceToken(token);
      // ignore: deprecated_member_use
      await FirebaseMessaging.instance.deleteToken();
    } catch (_) {}
  }
}

final pushServiceProvider = Provider<PushService>((ref) => PushService(ref));

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

/// Tüm veri erişiminin geçtiği Supabase istemcisi.
final supabaseProvider = Provider<SupabaseClient>((ref) => Supabase.instance.client);

/// Giriş yapmış kullanıcının id'si (yoksa null). Oturum değişince yeniden hesaplanır.
final currentUserIdProvider = Provider<String?>((ref) {
  ref.watch(authEventsProvider);
  return ref.watch(supabaseProvider).auth.currentUser?.id;
});

/// Supabase oturum olayları (giriş, çıkış, token yenileme...).
final authEventsProvider = StreamProvider<AuthState>((ref) {
  return ref.watch(supabaseProvider).auth.onAuthStateChange;
});

/// Supabase Storage'daki herkese açık dosya URL'sinden dosya yolunu çıkarır.
/// ör. `.../object/public/post-images/<uid>/<post>/a.jpg` → `<uid>/<post>/a.jpg`
String? storagePathFromUrl(String url, String bucket) {
  final marker = '/object/public/$bucket/';
  final i = url.indexOf(marker);
  if (i < 0) return null;
  final path = url.substring(i + marker.length);
  final q = path.indexOf('?');
  return Uri.decodeComponent(q < 0 ? path : path.substring(0, q));
}

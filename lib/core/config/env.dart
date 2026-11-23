// Gizli olmayan ama koda gömülmemesi gereken ayarlar, derleme sırasında
// env.json dosyasından gelir:
//   flutter run --dart-define-from-file=env.json
// env.json git'e eklenmez; şablonu env.example.json.
abstract final class Env {
  static const supabaseUrl = String.fromEnvironment('SUPABASE_URL');
  /// Supabase > Project Settings > API Keys: "Publishable key" (sb_publishable_...)
  /// ya da eski "anon public" anahtarı. İkisi de istemcide kullanılmak içindir;
  /// asıl koruma veritabanındaki RLS kurallarıdır. service_role / secret key ASLA buraya yazılmaz.
  static const supabaseKey = String.fromEnvironment('SUPABASE_PUBLISHABLE_KEY');

  static const firebaseApiKey = String.fromEnvironment('FIREBASE_API_KEY');
  static const firebaseAppId = String.fromEnvironment('FIREBASE_APP_ID');
  static const firebaseSenderId = String.fromEnvironment('FIREBASE_MESSAGING_SENDER_ID');
  static const firebaseProjectId = String.fromEnvironment('FIREBASE_PROJECT_ID');

  static bool get hasSupabase => supabaseUrl.isNotEmpty && supabaseKey.isNotEmpty;

  /// Firebase ayarları yoksa push bildirimleri kapalı çalışır (uygulama içi bildirimler sürer).
  static bool get hasFirebase =>
      firebaseApiKey.isNotEmpty && firebaseAppId.isNotEmpty && firebaseSenderId.isNotEmpty && firebaseProjectId.isNotEmpty;

  /// İletişim adresi (Ayarlar > Hakkında). Yasal metinlerle birlikte güncellenir.
  static const contactEmail = String.fromEnvironment('CONTACT_EMAIL', defaultValue: 'iletisim@ornek.com');
}

// Peerless — uygulamanın başlangıç noktası.
// Çalıştırma: flutter run --dart-define-from-file=env.json
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import 'app.dart';
import 'core/config/env.dart';
import 'core/settings/app_settings.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final prefs = await SharedPreferences.getInstance();
  _registerFontLicenses();

  if (!Env.hasSupabase) {
    runApp(const MissingConfigApp());
    return;
  }

  await Supabase.initialize(url: Env.supabaseUrl, publishableKey: Env.supabaseKey);

  runApp(
    ProviderScope(
      overrides: [sharedPreferencesProvider.overrideWithValue(prefs)],
      // Hata alan istekleri otomatik tekrar etme; kullanıcı "Tekrar dene"ye basar.
      retry: (_, _) => null,
      child: const PeerlessApp(),
    ),
  );
}

/// Paketlenen fontların lisansları Ayarlar > Hakkında > Açık kaynak lisansları'nda görünür.
void _registerFontLicenses() {
  const fonts = {
    'Inter': 'Inter-OFL.txt',
    'Tinos': 'Tinos-OFL.txt',
    'Playfair Display': 'PlayfairDisplay-OFL.txt',
    'Kaushan Script': 'KaushanScript-OFL.txt',
    'DejaVu Serif': 'DejaVu-LICENSE.txt',
  };
  LicenseRegistry.addLicense(() async* {
    for (final e in fonts.entries) {
      final text = await rootBundle.loadString('assets/fonts/licenses/${e.value}');
      yield LicenseEntryWithLineBreaks([e.key], text);
    }
  });
}

/// env.json verilmeden çalıştırılırsa ne yapılacağını söyler.
class MissingConfigApp extends StatelessWidget {
  const MissingConfigApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: EdgeInsets.all(24),
            child: Text(
              'Supabase ayarları bulunamadı.\n\n'
              'env.example.json dosyasını env.json olarak kopyalayıp doldur, sonra:\n'
              'flutter run --dart-define-from-file=env.json',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

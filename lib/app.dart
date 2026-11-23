import 'package:flutter_localizations/flutter_localizations.dart' as framework;
import 'package:flutter_quill/flutter_quill.dart' show FlutterQuillLocalizations;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'core/l10n.dart';
import 'core/router/app_router.dart';
import 'core/settings/app_settings.dart';
import 'core/theme/app_theme.dart';
import 'core/theme/tokens.dart';
import 'core/widgets/common.dart';

class PeerlessApp extends ConsumerWidget {
  const PeerlessApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(appSettingsProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'Peerless',
      debugShowCheckedModeBanner: false,
      scaffoldMessengerKey: scaffoldMessengerKey,
      routerConfig: router,
      // Koyu tema varsayılan; açık tema ikinci seçenek.
      theme: AppTheme.build(PeerlessPalette.light),
      darkTheme: AppTheme.build(PeerlessPalette.dark),
      themeMode: settings.theme == AppThemeChoice.dark ? ThemeMode.dark : ThemeMode.light,
      // Dil: kullanıcı seçmediyse telefonun dili (TR değilse EN).
      locale: settings.locale,
      supportedLocales: AppLocalizations.supportedLocales,
      localeResolutionCallback: (device, supported) {
        if (device?.languageCode == 'tr') return const Locale('tr');
        return const Locale('en');
      },
      localizationsDelegates: const [
        AppLocalizations.delegate,
        ...GlobalMaterialLocalizations.delegates,
        // Editör (flutter_quill) henüz eski Material paketini kullanıyor:
        // onun metinleri için framework çevirileri de eklenir.
        // ignore: deprecated_member_use
        framework.GlobalMaterialLocalizations.delegate,
        // ignore: deprecated_member_use
        framework.GlobalCupertinoLocalizations.delegate,
        FlutterQuillLocalizations.delegate,
      ],
    );
  }
}

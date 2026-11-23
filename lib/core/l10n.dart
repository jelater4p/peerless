import 'package:material_ui/material_ui.dart';

import '../l10n/app_localizations.dart';

export '../l10n/app_localizations.dart';

extension L10nContext on BuildContext {
  /// Çeviri metinleri: context.l10n.save gibi. Metinler lib/l10n/*.arb dosyalarında.
  AppLocalizations get l10n => AppLocalizations.of(this);
}

// KVKK aydınlatma metni ve kullanım koşulları.
// TASLAKTIR: hukuki görüş değildir; Google Play'e yüklemeden önce
// köşeli parantezli yerler doldurulup bir hukukçuya kontrol ettirilmelidir.
// Metinler lib/features/settings/legal_texts.dart dosyasında.
import 'package:material_ui/material_ui.dart';

import '../../../core/l10n.dart';
import '../../../core/theme/app_theme.dart';
import '../../../core/theme/tokens.dart';
import '../legal_texts.dart';

enum LegalDoc {
  kvkk,
  terms;

  static LegalDoc fromName(String? v) => v == 'terms' ? LegalDoc.terms : LegalDoc.kvkk;
}

class LegalScreen extends StatelessWidget {
  const LegalScreen({super.key, required this.doc});
  final LegalDoc doc;

  @override
  Widget build(BuildContext context) {
    final l = context.l10n;
    final text = doc == LegalDoc.kvkk ? kvkkText : termsText;
    return Scaffold(
      appBar: AppBar(title: Text(doc == LegalDoc.kvkk ? l.privacyNotice : l.termsOfUse)),
      body: ListView(
        padding: const EdgeInsets.all(Space.space4),
        children: [
          if (l.localeName != 'tr')
            Padding(
              padding: const EdgeInsets.only(bottom: Space.space4),
              child: Text(l.legalTurkishOnly, style: context.text.bodySmall),
            ),
          for (final block in text.split('\n\n'))
            Padding(
              padding: const EdgeInsets.only(bottom: Space.space3),
              child: block.startsWith('# ')
                  ? Text(block.substring(2), style: context.text.titleMedium)
                  : Text(block, style: context.text.bodyMedium?.copyWith(height: 1.5)),
            ),
        ],
      ),
    );
  }
}

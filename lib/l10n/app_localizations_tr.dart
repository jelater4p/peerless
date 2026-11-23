// ignore: unused_import
import 'package:intl/intl.dart' as intl;

import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Turkish (`tr`).
class AppLocalizationsTr extends AppLocalizations {
  AppLocalizationsTr([String locale = 'tr']) : super(locale);

  @override
  String get ok => 'Tamam';

  @override
  String get cancel => 'Vazgeç';

  @override
  String get save => 'Kaydet';

  @override
  String get saved => 'Kaydedildi';

  @override
  String get retry => 'Tekrar dene';

  @override
  String get close => 'Kapat';

  @override
  String get delete => 'Sil';

  @override
  String get edit => 'Düzenle';

  @override
  String get remove => 'Kaldır';

  @override
  String get skip => 'Atla';

  @override
  String get next => 'İleri';

  @override
  String get finish => 'Bitir';

  @override
  String get continueLabel => 'Devam';

  @override
  String get later => 'Sonra';

  @override
  String get download => 'İndir';

  @override
  String get view => 'Görüntüle';

  @override
  String get send => 'Gönder';

  @override
  String get update => 'Güncelle';

  @override
  String get publish => 'Yayınla';

  @override
  String get discard => 'Vazgeç';

  @override
  String get settings => 'Ayarlar';

  @override
  String get edited => 'düzenlendi';

  @override
  String get deletedUser => 'Silinmiş kullanıcı';

  @override
  String get untitled => 'Başlıksız';

  @override
  String get pinned => 'Sabitlendi';

  @override
  String get emptyList => 'Burada henüz bir şey yok';

  @override
  String get offlineBanner => 'Bağlantı yok';

  @override
  String get showingCached => 'İnternet yok; son kaydedilen hali gösteriliyor.';

  @override
  String get timeJustNow => 'az önce';

  @override
  String timeMinutes(int count) {
    return '$count dk önce';
  }

  @override
  String timeHours(int count) {
    return '$count sa önce';
  }

  @override
  String timeDays(int count) {
    return '$count gün önce';
  }

  @override
  String get navFeed => 'Akış';

  @override
  String get navSearch => 'Arama';

  @override
  String get navWrite => 'Yaz';

  @override
  String get navNotifications => 'Bildirimler';

  @override
  String get navProfile => 'Profil';

  @override
  String get typeQuote => 'Alıntı';

  @override
  String get typeThought => 'Düşünce';

  @override
  String get typeThesis => 'Tez';

  @override
  String get typeProject => 'Proje';

  @override
  String get typeQuotes => 'Alıntı';

  @override
  String get typeThoughts => 'Düşünce';

  @override
  String get typeTheses => 'Tez';

  @override
  String get typeProjects => 'Proje';

  @override
  String get typeQuoteHint => 'Bir kitaptan, yazardan cümleler ve senin notun';

  @override
  String get typeThoughtHint => 'Aklından geçenler, kısa ya da uzun';

  @override
  String get typeThesisHint => 'Bir fikri savunan, gerekçeli bir yazı';

  @override
  String get typeProjectHint => 'Üzerinde çalıştığın bir iş, görsellerle';

  @override
  String get writeWhat => 'Ne yazmak istersin?';

  @override
  String get myDrafts => 'Taslaklarım';

  @override
  String get intro1Title => 'Kendi kütüphaneni kur';

  @override
  String get intro1Body =>
      'Alıntılar, düşünceler, tezler ve projeler. Profilin, herkesin okuyabileceği kişisel kütüphanendir.';

  @override
  String get intro2Title => 'Okumaya odaklan';

  @override
  String get intro2Body =>
      'Sade bir arayüz, sana uygun font ve tema. Metin öne çıkar, gerisi geri çekilir.';

  @override
  String get intro3Title => 'Keşfet ve tartış';

  @override
  String get intro3Body =>
      'Türlere, etiketlere ve popüler içeriklere göz at; yorum yap, beğen, kaydet.';

  @override
  String get getStarted => 'Başla';

  @override
  String get email => 'E-posta';

  @override
  String get password => 'Şifre';

  @override
  String get newPassword => 'Yeni şifre';

  @override
  String get code => 'Kod';

  @override
  String get signIn => 'Giriş yap';

  @override
  String get signUp => 'Kayıt ol';

  @override
  String get signOut => 'Çıkış yap';

  @override
  String get signOutConfirm => 'Çıkış yapılsın mı?';

  @override
  String get signInTitle => 'Tekrar hoş geldin';

  @override
  String get signInSubtitle => 'Kütüphanene devam etmek için giriş yap.';

  @override
  String get signUpTitle => 'Hesap oluştur';

  @override
  String get signUpSubtitle =>
      'E-posta adresine bir doğrulama kodu göndereceğiz.';

  @override
  String get noAccount => 'Hesabın yok mu?';

  @override
  String get forgotPassword => 'Şifremi unuttum';

  @override
  String get termsOfUse => 'Kullanım koşullarını';

  @override
  String get and => ' ve ';

  @override
  String get privacyNotice => 'KVKK aydınlatma metnini';

  @override
  String get acceptSuffix => ' okudum, kabul ediyorum.';

  @override
  String get ageConfirm => '16 yaşından büyüğüm.';

  @override
  String get verifyTitle => 'E-postanı doğrula';

  @override
  String verifySubtitle(String email) {
    return '$email adresine gönderdiğimiz kodu gir.';
  }

  @override
  String get verify => 'Doğrula';

  @override
  String get resendCode => 'Kodu tekrar gönder';

  @override
  String resendCodeIn(int seconds) {
    return 'Kodu tekrar gönder ($seconds sn)';
  }

  @override
  String get codeResent => 'Yeni kod gönderildi';

  @override
  String get checkSpam => 'Gelmediyse spam klasörüne de bak.';

  @override
  String get forgotTitle => 'Şifreni sıfırla';

  @override
  String get forgotSubtitle =>
      'Hesabının e-posta adresini yaz; sana bir kod gönderelim.';

  @override
  String forgotCodeSent(String email) {
    return '$email adresine gelen kodu ve yeni şifreni gir.';
  }

  @override
  String get sendCode => 'Kod gönder';

  @override
  String get updatePassword => 'Şifreyi güncelle';

  @override
  String get passwordUpdated => 'Şifren güncellendi';

  @override
  String get setupNicknameTitle => 'Seni nasıl tanıyalım?';

  @override
  String get setupNicknameSubtitle =>
      '@nickname benzersizdir ve profil adresin olur. Görünen adını istediğin gibi yazabilirsin.';

  @override
  String get nickname => 'Nickname';

  @override
  String get nicknameHelp => '3–20 karakter: a-z, 0-9, _ ve .';

  @override
  String get displayName => 'Görünen ad';

  @override
  String get displayNameHelp => 'Profilinde ve içeriklerinde görünür';

  @override
  String get setupProfileTitle => 'Profilini tamamla';

  @override
  String get setupProfileSubtitle =>
      'Bir fotoğraf ve kısa bir biyografi ekle. İstersen sonra da yapabilirsin.';

  @override
  String get bio => 'Biyografi';

  @override
  String get bioHelp => 'En fazla 160 karakter';

  @override
  String get pickFromGallery => 'Galeriden seç';

  @override
  String get takePhoto => 'Fotoğraf çek';

  @override
  String get cropAvatar => 'Profil fotoğrafı';

  @override
  String get cropCover => 'Kapak görseli';

  @override
  String get errGeneric => 'Bir şeyler ters gitti. Lütfen tekrar dene.';

  @override
  String get errOffline => 'İnternet bağlantısı yok.';

  @override
  String get errRequired => 'Bu alan gerekli';

  @override
  String get errInvalidEmail => 'Geçerli bir e-posta adresi yaz';

  @override
  String errPasswordShort(int min) {
    return 'Şifre en az $min karakter olmalı';
  }

  @override
  String get errInvalidCredentials => 'E-posta veya şifre hatalı';

  @override
  String get errEmailNotConfirmed => 'E-posta adresin henüz doğrulanmamış';

  @override
  String get errEmailExists => 'Bu e-posta ile zaten bir hesap var';

  @override
  String get errWeakPassword => 'Şifre çok zayıf';

  @override
  String get errSamePassword => 'Yeni şifre eskisiyle aynı olamaz';

  @override
  String get errCodeInvalid => 'Kod hatalı ya da süresi dolmuş';

  @override
  String get errRateLimit =>
      'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.';

  @override
  String get errBanned => 'Bu hesap kurallara aykırılık nedeniyle kapatıldı.';

  @override
  String get errAcceptRequired => 'Devam etmek için iki kutuyu da işaretle';

  @override
  String get errNicknameTaken => 'Bu nickname alınmış';

  @override
  String get errNicknameReserved =>
      'Bu nickname yakın zamanda bırakıldı; 30 gün boyunca alınamaz';

  @override
  String get errNicknameTooSoon => 'Nickname 30 günde bir değiştirilebilir';

  @override
  String get errTooManyTags => 'En fazla 5 etiket ekleyebilirsin';

  @override
  String get errTooManyImages => 'Bir içerikte en fazla 5 görsel olabilir';

  @override
  String get errTagTooLong => 'Etiket en fazla 30 karakter olabilir';

  @override
  String get errTitleRequired => 'Yayınlamak için bir başlık yaz';

  @override
  String get errBodyRequired => 'Yayınlamak için metin yaz';

  @override
  String get errNotAllowed => 'Bunu yapmaya iznin yok';

  @override
  String get errDuplicate => 'Bu kayıt zaten var';

  @override
  String get errInvalidInput => 'Girilen bilgi geçersiz';

  @override
  String get errUpload => 'Görsel yüklenemedi';

  @override
  String get updateTitle => 'Yeni sürüm var';

  @override
  String updateAvailable(String version) {
    return 'Peerless $version hazır. İndirip kurabilirsin.';
  }

  @override
  String updateRequired(String version) {
    return 'Devam etmek için Peerless $version sürümünü kurman gerekiyor.';
  }

  @override
  String get sort => 'Sıralama';

  @override
  String get sortLatest => 'En yeni';

  @override
  String get sortPopular => 'Popüler';

  @override
  String get tabAll => 'Tümü';

  @override
  String get popularHint => 'Son 7 günün en çok beğenilen içerikleri';

  @override
  String get emptyFeed => 'Henüz içerik yok';

  @override
  String get emptyPopular => 'Bu hafta henüz popüler içerik yok';

  @override
  String get emptyFeedHint =>
      'İlk paylaşımı sen yap: ortadaki Yaz butonuna dokun.';

  @override
  String get readingSettings => 'Okuma ayarları';

  @override
  String get font => 'Font';

  @override
  String get textSize => 'Yazı boyutu';

  @override
  String get sizeSmall => 'Küçük';

  @override
  String get sizeMedium => 'Orta';

  @override
  String get sizeLarge => 'Büyük';

  @override
  String get lineSpacing => 'Satır aralığı';

  @override
  String get lineNarrow => 'Dar';

  @override
  String get lineNormal => 'Normal';

  @override
  String get lineWide => 'Geniş';

  @override
  String get readingTheme => 'Okuma teması';

  @override
  String get themeDark => 'Koyu';

  @override
  String get themeLight => 'Açık';

  @override
  String get themeSepia => 'Sepya';

  @override
  String get like => 'Beğen';

  @override
  String get unlike => 'Beğeniyi geri al';

  @override
  String get comment => 'Yorum yap';

  @override
  String get bookmark => 'Kaydet';

  @override
  String get removeBookmark => 'Kaydedilenlerden çıkar';

  @override
  String get bookmarkAdded => 'Kaydedilenlere eklendi';

  @override
  String get bookmarkRemoved => 'Kaydedilenlerden çıkarıldı';

  @override
  String get pinToProfile => 'Profilime sabitle';

  @override
  String get unpin => 'Sabitlemeyi kaldır';

  @override
  String get pinnedDone => 'Profiline sabitlendi';

  @override
  String get unpinned => 'Sabitleme kaldırıldı';

  @override
  String get deletePostTitle => 'İçerik silinsin mi?';

  @override
  String get deletePostBody =>
      'Bu işlem geri alınamaz; yorumlar ve beğeniler de silinir.';

  @override
  String get postDeleted => 'İçerik silindi';

  @override
  String get report => 'Şikayet et';

  @override
  String get viewProfile => 'Profili gör';

  @override
  String get personalNote => 'Kişisel yorum';

  @override
  String get postNotFound => 'İçerik bulunamadı';

  @override
  String get postNotFoundHint =>
      'Silinmiş, kaldırılmış ya da erişimin olmayan bir içerik olabilir.';

  @override
  String get postRemovedNotice =>
      'Bu içerik kurallara aykırı bulunduğu için yayından kaldırıldı. Yalnızca sen görebilirsin.';

  @override
  String commentsCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count yorum',
      zero: 'Yorum yok',
    );
    return '$_temp0';
  }

  @override
  String get noComments => 'İlk yorumu sen yaz.';

  @override
  String get reply => 'Yanıtla';

  @override
  String get writeComment => 'Yorum yaz…';

  @override
  String replyingTo(String name) {
    return '$name adlı kişiye yanıt';
  }

  @override
  String get editComment => 'Yorumu düzenle';

  @override
  String get deleteCommentTitle => 'Yorum silinsin mi?';

  @override
  String get reportSentTitle => 'Teşekkürler';

  @override
  String get reportSentBody =>
      'Admine iletilmiştir. İçerik sahibine gerekli işlem yapılacaktır.';

  @override
  String get reportAlready => 'Bu içeriği zaten şikayet ettin';

  @override
  String get block => 'Engelle';

  @override
  String get unblock => 'Engeli kaldır';

  @override
  String blockConfirmTitle(String name) {
    return '$name engellensin mi?';
  }

  @override
  String get blockConfirmBody =>
      'Onun içeriklerini ve yorumlarını görmezsin. O da senin içeriklerine yorum, beğeni ve @bahsetme yapamaz.';

  @override
  String blocked(String name) {
    return '$name engellendi';
  }

  @override
  String unblocked(String name) {
    return '$name için engel kaldırıldı';
  }

  @override
  String get youBlockedUser => 'Bu kişiyi engelledin';

  @override
  String get youBlockedUserHint =>
      'İçeriklerini görmek için menüden engeli kaldırabilirsin.';

  @override
  String get editProfile => 'Profili düzenle';

  @override
  String get bookmarks => 'Kaydedilenler';

  @override
  String get userNotFound => 'Kullanıcı bulunamadı';

  @override
  String get emptyLibrary => 'Kütüphanesi henüz boş';

  @override
  String get emptyMyLibrary => 'Kütüphanen henüz boş. İlk içeriğini yaz!';

  @override
  String get emptyType => 'Bu türde içerik yok';

  @override
  String get emptyBookmarks => 'Kaydedilen içerik yok';

  @override
  String get emptyBookmarksHint =>
      'Bir içeriği okurken yer imi ikonuna dokun. Bu liste yalnızca sana görünür.';

  @override
  String get changePhoto => 'Fotoğrafı değiştir';

  @override
  String get changeCover => 'Kapağı değiştir';

  @override
  String get nicknameChangeRule =>
      'Nickname 30 günde bir değiştirilebilir; eski nickname 30 gün boyunca başkasına verilmez.';

  @override
  String nicknameNextChange(String date) {
    return 'Nickname\'ini $date tarihinden sonra değiştirebilirsin.';
  }

  @override
  String get adminPanel => 'Admin paneli';

  @override
  String get titleHint => 'Başlık';

  @override
  String get bodyHint => 'Yazmaya başla…';

  @override
  String get quoteBodyHint => 'Alıntıyı buraya yaz…';

  @override
  String get personalNoteHint =>
      'Alıntının altında görünen notun (isteğe bağlı)';

  @override
  String get addCover => 'Kapak ekle';

  @override
  String get gallery => 'Görsel galerisi';

  @override
  String get galleryOnlyProject =>
      'Galeri yalnızca projelerde olabilir; önce galeri görsellerini kaldır.';

  @override
  String get tags => 'Etiketler';

  @override
  String get tagHint => 'Etiket ekle (virgül ya da boşlukla)';

  @override
  String tagRule(int max) {
    return 'En fazla $max etiket; mevcut etiketler önerilir.';
  }

  @override
  String imageLimitInfo(int count, int max) {
    return 'Görseller: $count/$max (kapak + metin içi + galeri)';
  }

  @override
  String get saving => 'Kaydediliyor…';

  @override
  String get savedDraft => 'Taslak kaydedildi';

  @override
  String get saveFailed => 'Kaydedilemedi';

  @override
  String get published => 'Yayınlandı';

  @override
  String get updated => 'Güncellendi';

  @override
  String get deleteDraftTitle => 'Taslak silinsin mi?';

  @override
  String get discardChangesTitle => 'Değişiklikler kaydedilmedi';

  @override
  String get discardChangesBody => 'Çıkarsan yaptığın değişiklikler kaybolur.';

  @override
  String get noDrafts => 'Taslak yok';

  @override
  String get noDraftsHint => 'Yazdıkların otomatik olarak taslak kaydedilir.';

  @override
  String get fmtHeading => 'Başlık';

  @override
  String get fmtBold => 'Kalın';

  @override
  String get fmtItalic => 'İtalik';

  @override
  String get fmtQuote => 'Alıntı bloğu';

  @override
  String get fmtBullets => 'Liste';

  @override
  String get fmtNumbers => 'Numaralı liste';

  @override
  String get addLink => 'Link ekle';

  @override
  String get addImage => 'Görsel ekle';

  @override
  String get undo => 'Geri al';

  @override
  String get redo => 'Yinele';

  @override
  String get searchHint => 'Kişi veya içerik ara';

  @override
  String get recentSearches => 'Son aramalar';

  @override
  String get popularThisWeek => 'Haftanın popüler içerikleri';

  @override
  String get people => 'Kişiler';

  @override
  String get posts => 'İçerikler';

  @override
  String get noResults => 'Sonuç bulunamadı';

  @override
  String get noPostResults => 'Bu aramayla eşleşen içerik yok';

  @override
  String notifComment(String user) {
    return '$user içeriğine yorum yaptı';
  }

  @override
  String notifReply(String user) {
    return '$user yorumuna yanıt verdi';
  }

  @override
  String notifLike(String user) {
    return '$user içeriğini beğendi';
  }

  @override
  String notifMention(String user) {
    return '$user bir yorumda senden bahsetti';
  }

  @override
  String get noNotifications => 'Bildirim yok';

  @override
  String get noNotificationsHint =>
      'Yorum, yanıt, beğeni ve bahsetmeler burada görünür.';

  @override
  String get moderationNoticeTitle => 'Moderasyon bildirimi';

  @override
  String get moderationRemoved =>
      'İçeriğin kurallara aykırı bulunduğu için kaldırıldı.';

  @override
  String get moderationWarned => 'Hesabına resmi bir uyarı verildi.';

  @override
  String get moderationBanned => 'Hesabın kalıcı olarak kapatıldı.';

  @override
  String get moderationGeneric =>
      'Hesabınla ilgili bir moderasyon bildirimi var.';

  @override
  String get adminNote => 'Admin notu';

  @override
  String get viewPost => 'İçeriği gör';

  @override
  String get reports => 'Şikayetler';

  @override
  String get appVersion => 'Uygulama sürümü';

  @override
  String get noOpenReports => 'Bekleyen şikayet yok';

  @override
  String get reportTargetPost => 'İçerik';

  @override
  String get reportTargetComment => 'Yorum';

  @override
  String get reportTargetProfile => 'Profil';

  @override
  String reportCount(int count) {
    String _temp0 = intl.Intl.pluralLogic(
      count,
      locale: localeName,
      other: '$count şikayet',
      one: '1 şikayet',
    );
    return '$_temp0';
  }

  @override
  String get dismiss => 'Reddet';

  @override
  String get removeContent => 'İçeriği kaldır';

  @override
  String get warn => 'Uyarı ver';

  @override
  String get ban => 'Kalıcı ban';

  @override
  String get adminNoteOptional => 'Not (isteğe bağlı, kullanıcıya gösterilir)';

  @override
  String get moderationDone => 'İşlem uygulandı';

  @override
  String get appVersionHelp =>
      'Kullanıcının sürümü \"son sürüm\"den eskiyse \"Yeni sürüm var\" uyarısı çıkar; \"en düşük sürüm\"den eskiyse kurmadan devam edemez.';

  @override
  String get latestVersion => 'Son sürüm';

  @override
  String get minVersion => 'En düşük sürüm';

  @override
  String get apkUrl => 'APK indirme linki';

  @override
  String get settingsAccount => 'Hesap';

  @override
  String get settingsNotifications => 'Bildirimler';

  @override
  String get settingsAppearance => 'Görünüm';

  @override
  String get settingsBlocked => 'Engellenen kullanıcılar';

  @override
  String get settingsAbout => 'Hakkında';

  @override
  String get changeEmail => 'E-postayı değiştir';

  @override
  String get newEmail => 'Yeni e-posta';

  @override
  String emailChangeCodeSent(String email) {
    return '$email adresine gönderilen kodu gir.';
  }

  @override
  String get emailChanged => 'E-posta adresin değişti';

  @override
  String get changePassword => 'Şifreyi değiştir';

  @override
  String get deleteAccount => 'Hesabı sil';

  @override
  String get deleteAccountHint => '30 gün sonra kesinleşir';

  @override
  String get deleteAccountConfirmTitle => 'Hesabın silinsin mi?';

  @override
  String get deleteAccountConfirmBody =>
      'Hesabın ve tüm verilerin 30 gün sonra kalıcı olarak silinir. Bu sürede tekrar giriş yaparsan talep iptal olur.';

  @override
  String get deleteAccountRequested =>
      'Silme talebin alındı. 30 gün içinde giriş yaparsan iptal olur.';

  @override
  String get notifSettingComment => 'İçeriğime yorum';

  @override
  String get notifSettingReply => 'Yorumuma yanıt';

  @override
  String get notifSettingLike => 'İçeriğim beğenildi';

  @override
  String get notifSettingMention => '@bahsedilme';

  @override
  String get notifSettingModeration =>
      'Moderasyon bildirimleri (uyarı, içerik kaldırma) her zaman uygulama içinde gösterilir.';

  @override
  String get language => 'Dil';

  @override
  String get languageSystem => 'Telefonun dili';

  @override
  String get theme => 'Tema';

  @override
  String get noBlockedUsers => 'Engellediğin kimse yok';

  @override
  String versionLabel(String version) {
    return 'Sürüm $version';
  }

  @override
  String get openSourceLicenses => 'Açık kaynak lisansları';

  @override
  String get contact => 'İletişim';

  @override
  String get legalTurkishOnly =>
      'This text is currently available in Turkish only.';
}

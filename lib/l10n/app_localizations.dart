import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_tr.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('tr'),
  ];

  /// No description provided for @ok.
  ///
  /// In tr, this message translates to:
  /// **'Tamam'**
  String get ok;

  /// No description provided for @cancel.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get cancel;

  /// No description provided for @save.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get save;

  /// No description provided for @saved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedildi'**
  String get saved;

  /// No description provided for @retry.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar dene'**
  String get retry;

  /// No description provided for @close.
  ///
  /// In tr, this message translates to:
  /// **'Kapat'**
  String get close;

  /// No description provided for @delete.
  ///
  /// In tr, this message translates to:
  /// **'Sil'**
  String get delete;

  /// No description provided for @edit.
  ///
  /// In tr, this message translates to:
  /// **'Düzenle'**
  String get edit;

  /// No description provided for @remove.
  ///
  /// In tr, this message translates to:
  /// **'Kaldır'**
  String get remove;

  /// No description provided for @skip.
  ///
  /// In tr, this message translates to:
  /// **'Atla'**
  String get skip;

  /// No description provided for @next.
  ///
  /// In tr, this message translates to:
  /// **'İleri'**
  String get next;

  /// No description provided for @finish.
  ///
  /// In tr, this message translates to:
  /// **'Bitir'**
  String get finish;

  /// No description provided for @continueLabel.
  ///
  /// In tr, this message translates to:
  /// **'Devam'**
  String get continueLabel;

  /// No description provided for @later.
  ///
  /// In tr, this message translates to:
  /// **'Sonra'**
  String get later;

  /// No description provided for @download.
  ///
  /// In tr, this message translates to:
  /// **'İndir'**
  String get download;

  /// No description provided for @view.
  ///
  /// In tr, this message translates to:
  /// **'Görüntüle'**
  String get view;

  /// No description provided for @send.
  ///
  /// In tr, this message translates to:
  /// **'Gönder'**
  String get send;

  /// No description provided for @update.
  ///
  /// In tr, this message translates to:
  /// **'Güncelle'**
  String get update;

  /// No description provided for @publish.
  ///
  /// In tr, this message translates to:
  /// **'Yayınla'**
  String get publish;

  /// No description provided for @discard.
  ///
  /// In tr, this message translates to:
  /// **'Vazgeç'**
  String get discard;

  /// No description provided for @settings.
  ///
  /// In tr, this message translates to:
  /// **'Ayarlar'**
  String get settings;

  /// No description provided for @edited.
  ///
  /// In tr, this message translates to:
  /// **'düzenlendi'**
  String get edited;

  /// No description provided for @deletedUser.
  ///
  /// In tr, this message translates to:
  /// **'Silinmiş kullanıcı'**
  String get deletedUser;

  /// No description provided for @untitled.
  ///
  /// In tr, this message translates to:
  /// **'Başlıksız'**
  String get untitled;

  /// No description provided for @pinned.
  ///
  /// In tr, this message translates to:
  /// **'Sabitlendi'**
  String get pinned;

  /// No description provided for @emptyList.
  ///
  /// In tr, this message translates to:
  /// **'Burada henüz bir şey yok'**
  String get emptyList;

  /// No description provided for @offlineBanner.
  ///
  /// In tr, this message translates to:
  /// **'Bağlantı yok'**
  String get offlineBanner;

  /// No description provided for @showingCached.
  ///
  /// In tr, this message translates to:
  /// **'İnternet yok; son kaydedilen hali gösteriliyor.'**
  String get showingCached;

  /// No description provided for @timeJustNow.
  ///
  /// In tr, this message translates to:
  /// **'az önce'**
  String get timeJustNow;

  /// No description provided for @timeMinutes.
  ///
  /// In tr, this message translates to:
  /// **'{count} dk önce'**
  String timeMinutes(int count);

  /// No description provided for @timeHours.
  ///
  /// In tr, this message translates to:
  /// **'{count} sa önce'**
  String timeHours(int count);

  /// No description provided for @timeDays.
  ///
  /// In tr, this message translates to:
  /// **'{count} gün önce'**
  String timeDays(int count);

  /// No description provided for @navFeed.
  ///
  /// In tr, this message translates to:
  /// **'Akış'**
  String get navFeed;

  /// No description provided for @navSearch.
  ///
  /// In tr, this message translates to:
  /// **'Arama'**
  String get navSearch;

  /// No description provided for @navWrite.
  ///
  /// In tr, this message translates to:
  /// **'Yaz'**
  String get navWrite;

  /// No description provided for @navNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get navNotifications;

  /// No description provided for @navProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get navProfile;

  /// No description provided for @typeQuote.
  ///
  /// In tr, this message translates to:
  /// **'Alıntı'**
  String get typeQuote;

  /// No description provided for @typeThought.
  ///
  /// In tr, this message translates to:
  /// **'Düşünce'**
  String get typeThought;

  /// No description provided for @typeThesis.
  ///
  /// In tr, this message translates to:
  /// **'Tez'**
  String get typeThesis;

  /// No description provided for @typeProject.
  ///
  /// In tr, this message translates to:
  /// **'Proje'**
  String get typeProject;

  /// No description provided for @typeQuotes.
  ///
  /// In tr, this message translates to:
  /// **'Alıntı'**
  String get typeQuotes;

  /// No description provided for @typeThoughts.
  ///
  /// In tr, this message translates to:
  /// **'Düşünce'**
  String get typeThoughts;

  /// No description provided for @typeTheses.
  ///
  /// In tr, this message translates to:
  /// **'Tez'**
  String get typeTheses;

  /// No description provided for @typeProjects.
  ///
  /// In tr, this message translates to:
  /// **'Proje'**
  String get typeProjects;

  /// No description provided for @typeQuoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir kitaptan, yazardan cümleler ve senin notun'**
  String get typeQuoteHint;

  /// No description provided for @typeThoughtHint.
  ///
  /// In tr, this message translates to:
  /// **'Aklından geçenler, kısa ya da uzun'**
  String get typeThoughtHint;

  /// No description provided for @typeThesisHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir fikri savunan, gerekçeli bir yazı'**
  String get typeThesisHint;

  /// No description provided for @typeProjectHint.
  ///
  /// In tr, this message translates to:
  /// **'Üzerinde çalıştığın bir iş, görsellerle'**
  String get typeProjectHint;

  /// No description provided for @writeWhat.
  ///
  /// In tr, this message translates to:
  /// **'Ne yazmak istersin?'**
  String get writeWhat;

  /// No description provided for @myDrafts.
  ///
  /// In tr, this message translates to:
  /// **'Taslaklarım'**
  String get myDrafts;

  /// No description provided for @intro1Title.
  ///
  /// In tr, this message translates to:
  /// **'Kendi kütüphaneni kur'**
  String get intro1Title;

  /// No description provided for @intro1Body.
  ///
  /// In tr, this message translates to:
  /// **'Alıntılar, düşünceler, tezler ve projeler. Profilin, herkesin okuyabileceği kişisel kütüphanendir.'**
  String get intro1Body;

  /// No description provided for @intro2Title.
  ///
  /// In tr, this message translates to:
  /// **'Okumaya odaklan'**
  String get intro2Title;

  /// No description provided for @intro2Body.
  ///
  /// In tr, this message translates to:
  /// **'Sade bir arayüz, sana uygun font ve tema. Metin öne çıkar, gerisi geri çekilir.'**
  String get intro2Body;

  /// No description provided for @intro3Title.
  ///
  /// In tr, this message translates to:
  /// **'Keşfet ve tartış'**
  String get intro3Title;

  /// No description provided for @intro3Body.
  ///
  /// In tr, this message translates to:
  /// **'Türlere, etiketlere ve popüler içeriklere göz at; yorum yap, beğen, kaydet.'**
  String get intro3Body;

  /// No description provided for @getStarted.
  ///
  /// In tr, this message translates to:
  /// **'Başla'**
  String get getStarted;

  /// No description provided for @email.
  ///
  /// In tr, this message translates to:
  /// **'E-posta'**
  String get email;

  /// No description provided for @password.
  ///
  /// In tr, this message translates to:
  /// **'Şifre'**
  String get password;

  /// No description provided for @newPassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre'**
  String get newPassword;

  /// No description provided for @code.
  ///
  /// In tr, this message translates to:
  /// **'Kod'**
  String get code;

  /// No description provided for @signIn.
  ///
  /// In tr, this message translates to:
  /// **'Giriş yap'**
  String get signIn;

  /// No description provided for @signUp.
  ///
  /// In tr, this message translates to:
  /// **'Kayıt ol'**
  String get signUp;

  /// No description provided for @signOut.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yap'**
  String get signOut;

  /// No description provided for @signOutConfirm.
  ///
  /// In tr, this message translates to:
  /// **'Çıkış yapılsın mı?'**
  String get signOutConfirm;

  /// No description provided for @signInTitle.
  ///
  /// In tr, this message translates to:
  /// **'Tekrar hoş geldin'**
  String get signInTitle;

  /// No description provided for @signInSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanene devam etmek için giriş yap.'**
  String get signInSubtitle;

  /// No description provided for @signUpTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesap oluştur'**
  String get signUpTitle;

  /// No description provided for @signUpSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresine bir doğrulama kodu göndereceğiz.'**
  String get signUpSubtitle;

  /// No description provided for @noAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın yok mu?'**
  String get noAccount;

  /// No description provided for @forgotPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifremi unuttum'**
  String get forgotPassword;

  /// No description provided for @termsOfUse.
  ///
  /// In tr, this message translates to:
  /// **'Kullanım koşullarını'**
  String get termsOfUse;

  /// No description provided for @and.
  ///
  /// In tr, this message translates to:
  /// **' ve '**
  String get and;

  /// No description provided for @privacyNotice.
  ///
  /// In tr, this message translates to:
  /// **'KVKK aydınlatma metnini'**
  String get privacyNotice;

  /// No description provided for @acceptSuffix.
  ///
  /// In tr, this message translates to:
  /// **' okudum, kabul ediyorum.'**
  String get acceptSuffix;

  /// No description provided for @ageConfirm.
  ///
  /// In tr, this message translates to:
  /// **'16 yaşından büyüğüm.'**
  String get ageConfirm;

  /// No description provided for @verifyTitle.
  ///
  /// In tr, this message translates to:
  /// **'E-postanı doğrula'**
  String get verifyTitle;

  /// No description provided for @verifySubtitle.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine gönderdiğimiz kodu gir.'**
  String verifySubtitle(String email);

  /// No description provided for @verify.
  ///
  /// In tr, this message translates to:
  /// **'Doğrula'**
  String get verify;

  /// No description provided for @resendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder'**
  String get resendCode;

  /// No description provided for @resendCodeIn.
  ///
  /// In tr, this message translates to:
  /// **'Kodu tekrar gönder ({seconds} sn)'**
  String resendCodeIn(int seconds);

  /// No description provided for @codeResent.
  ///
  /// In tr, this message translates to:
  /// **'Yeni kod gönderildi'**
  String get codeResent;

  /// No description provided for @checkSpam.
  ///
  /// In tr, this message translates to:
  /// **'Gelmediyse spam klasörüne de bak.'**
  String get checkSpam;

  /// No description provided for @forgotTitle.
  ///
  /// In tr, this message translates to:
  /// **'Şifreni sıfırla'**
  String get forgotTitle;

  /// No description provided for @forgotSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabının e-posta adresini yaz; sana bir kod gönderelim.'**
  String get forgotSubtitle;

  /// No description provided for @forgotCodeSent.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine gelen kodu ve yeni şifreni gir.'**
  String forgotCodeSent(String email);

  /// No description provided for @sendCode.
  ///
  /// In tr, this message translates to:
  /// **'Kod gönder'**
  String get sendCode;

  /// No description provided for @updatePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi güncelle'**
  String get updatePassword;

  /// No description provided for @passwordUpdated.
  ///
  /// In tr, this message translates to:
  /// **'Şifren güncellendi'**
  String get passwordUpdated;

  /// No description provided for @setupNicknameTitle.
  ///
  /// In tr, this message translates to:
  /// **'Seni nasıl tanıyalım?'**
  String get setupNicknameTitle;

  /// No description provided for @setupNicknameSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'@nickname benzersizdir ve profil adresin olur. Görünen adını istediğin gibi yazabilirsin.'**
  String get setupNicknameSubtitle;

  /// No description provided for @nickname.
  ///
  /// In tr, this message translates to:
  /// **'Nickname'**
  String get nickname;

  /// No description provided for @nicknameHelp.
  ///
  /// In tr, this message translates to:
  /// **'3–20 karakter: a-z, 0-9, _ ve .'**
  String get nicknameHelp;

  /// No description provided for @displayName.
  ///
  /// In tr, this message translates to:
  /// **'Görünen ad'**
  String get displayName;

  /// No description provided for @displayNameHelp.
  ///
  /// In tr, this message translates to:
  /// **'Profilinde ve içeriklerinde görünür'**
  String get displayNameHelp;

  /// No description provided for @setupProfileTitle.
  ///
  /// In tr, this message translates to:
  /// **'Profilini tamamla'**
  String get setupProfileTitle;

  /// No description provided for @setupProfileSubtitle.
  ///
  /// In tr, this message translates to:
  /// **'Bir fotoğraf ve kısa bir biyografi ekle. İstersen sonra da yapabilirsin.'**
  String get setupProfileSubtitle;

  /// No description provided for @bio.
  ///
  /// In tr, this message translates to:
  /// **'Biyografi'**
  String get bio;

  /// No description provided for @bioHelp.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 160 karakter'**
  String get bioHelp;

  /// No description provided for @pickFromGallery.
  ///
  /// In tr, this message translates to:
  /// **'Galeriden seç'**
  String get pickFromGallery;

  /// No description provided for @takePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğraf çek'**
  String get takePhoto;

  /// No description provided for @cropAvatar.
  ///
  /// In tr, this message translates to:
  /// **'Profil fotoğrafı'**
  String get cropAvatar;

  /// No description provided for @cropCover.
  ///
  /// In tr, this message translates to:
  /// **'Kapak görseli'**
  String get cropCover;

  /// No description provided for @errGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Bir şeyler ters gitti. Lütfen tekrar dene.'**
  String get errGeneric;

  /// No description provided for @errOffline.
  ///
  /// In tr, this message translates to:
  /// **'İnternet bağlantısı yok.'**
  String get errOffline;

  /// No description provided for @errRequired.
  ///
  /// In tr, this message translates to:
  /// **'Bu alan gerekli'**
  String get errRequired;

  /// No description provided for @errInvalidEmail.
  ///
  /// In tr, this message translates to:
  /// **'Geçerli bir e-posta adresi yaz'**
  String get errInvalidEmail;

  /// No description provided for @errPasswordShort.
  ///
  /// In tr, this message translates to:
  /// **'Şifre en az {min} karakter olmalı'**
  String errPasswordShort(int min);

  /// No description provided for @errInvalidCredentials.
  ///
  /// In tr, this message translates to:
  /// **'E-posta veya şifre hatalı'**
  String get errInvalidCredentials;

  /// No description provided for @errEmailNotConfirmed.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresin henüz doğrulanmamış'**
  String get errEmailNotConfirmed;

  /// No description provided for @errEmailExists.
  ///
  /// In tr, this message translates to:
  /// **'Bu e-posta ile zaten bir hesap var'**
  String get errEmailExists;

  /// No description provided for @errWeakPassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifre çok zayıf'**
  String get errWeakPassword;

  /// No description provided for @errSamePassword.
  ///
  /// In tr, this message translates to:
  /// **'Yeni şifre eskisiyle aynı olamaz'**
  String get errSamePassword;

  /// No description provided for @errCodeInvalid.
  ///
  /// In tr, this message translates to:
  /// **'Kod hatalı ya da süresi dolmuş'**
  String get errCodeInvalid;

  /// No description provided for @errRateLimit.
  ///
  /// In tr, this message translates to:
  /// **'Çok fazla deneme yapıldı. Biraz sonra tekrar dene.'**
  String get errRateLimit;

  /// No description provided for @errBanned.
  ///
  /// In tr, this message translates to:
  /// **'Bu hesap kurallara aykırılık nedeniyle kapatıldı.'**
  String get errBanned;

  /// No description provided for @errAcceptRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için iki kutuyu da işaretle'**
  String get errAcceptRequired;

  /// No description provided for @errNicknameTaken.
  ///
  /// In tr, this message translates to:
  /// **'Bu nickname alınmış'**
  String get errNicknameTaken;

  /// No description provided for @errNicknameReserved.
  ///
  /// In tr, this message translates to:
  /// **'Bu nickname yakın zamanda bırakıldı; 30 gün boyunca alınamaz'**
  String get errNicknameReserved;

  /// No description provided for @errNicknameTooSoon.
  ///
  /// In tr, this message translates to:
  /// **'Nickname 30 günde bir değiştirilebilir'**
  String get errNicknameTooSoon;

  /// No description provided for @errTooManyTags.
  ///
  /// In tr, this message translates to:
  /// **'En fazla 5 etiket ekleyebilirsin'**
  String get errTooManyTags;

  /// No description provided for @errTooManyImages.
  ///
  /// In tr, this message translates to:
  /// **'Bir içerikte en fazla 5 görsel olabilir'**
  String get errTooManyImages;

  /// No description provided for @errTagTooLong.
  ///
  /// In tr, this message translates to:
  /// **'Etiket en fazla 30 karakter olabilir'**
  String get errTagTooLong;

  /// No description provided for @errTitleRequired.
  ///
  /// In tr, this message translates to:
  /// **'Yayınlamak için bir başlık yaz'**
  String get errTitleRequired;

  /// No description provided for @errBodyRequired.
  ///
  /// In tr, this message translates to:
  /// **'Yayınlamak için metin yaz'**
  String get errBodyRequired;

  /// No description provided for @errNotAllowed.
  ///
  /// In tr, this message translates to:
  /// **'Bunu yapmaya iznin yok'**
  String get errNotAllowed;

  /// No description provided for @errDuplicate.
  ///
  /// In tr, this message translates to:
  /// **'Bu kayıt zaten var'**
  String get errDuplicate;

  /// No description provided for @errInvalidInput.
  ///
  /// In tr, this message translates to:
  /// **'Girilen bilgi geçersiz'**
  String get errInvalidInput;

  /// No description provided for @errUpload.
  ///
  /// In tr, this message translates to:
  /// **'Görsel yüklenemedi'**
  String get errUpload;

  /// No description provided for @updateTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yeni sürüm var'**
  String get updateTitle;

  /// No description provided for @updateAvailable.
  ///
  /// In tr, this message translates to:
  /// **'Peerless {version} hazır. İndirip kurabilirsin.'**
  String updateAvailable(String version);

  /// No description provided for @updateRequired.
  ///
  /// In tr, this message translates to:
  /// **'Devam etmek için Peerless {version} sürümünü kurman gerekiyor.'**
  String updateRequired(String version);

  /// No description provided for @sort.
  ///
  /// In tr, this message translates to:
  /// **'Sıralama'**
  String get sort;

  /// No description provided for @sortLatest.
  ///
  /// In tr, this message translates to:
  /// **'En yeni'**
  String get sortLatest;

  /// No description provided for @sortPopular.
  ///
  /// In tr, this message translates to:
  /// **'Popüler'**
  String get sortPopular;

  /// No description provided for @tabAll.
  ///
  /// In tr, this message translates to:
  /// **'Tümü'**
  String get tabAll;

  /// No description provided for @popularHint.
  ///
  /// In tr, this message translates to:
  /// **'Son 7 günün en çok beğenilen içerikleri'**
  String get popularHint;

  /// No description provided for @emptyFeed.
  ///
  /// In tr, this message translates to:
  /// **'Henüz içerik yok'**
  String get emptyFeed;

  /// No description provided for @emptyPopular.
  ///
  /// In tr, this message translates to:
  /// **'Bu hafta henüz popüler içerik yok'**
  String get emptyPopular;

  /// No description provided for @emptyFeedHint.
  ///
  /// In tr, this message translates to:
  /// **'İlk paylaşımı sen yap: ortadaki Yaz butonuna dokun.'**
  String get emptyFeedHint;

  /// No description provided for @readingSettings.
  ///
  /// In tr, this message translates to:
  /// **'Okuma ayarları'**
  String get readingSettings;

  /// No description provided for @font.
  ///
  /// In tr, this message translates to:
  /// **'Font'**
  String get font;

  /// No description provided for @textSize.
  ///
  /// In tr, this message translates to:
  /// **'Yazı boyutu'**
  String get textSize;

  /// No description provided for @sizeSmall.
  ///
  /// In tr, this message translates to:
  /// **'Küçük'**
  String get sizeSmall;

  /// No description provided for @sizeMedium.
  ///
  /// In tr, this message translates to:
  /// **'Orta'**
  String get sizeMedium;

  /// No description provided for @sizeLarge.
  ///
  /// In tr, this message translates to:
  /// **'Büyük'**
  String get sizeLarge;

  /// No description provided for @lineSpacing.
  ///
  /// In tr, this message translates to:
  /// **'Satır aralığı'**
  String get lineSpacing;

  /// No description provided for @lineNarrow.
  ///
  /// In tr, this message translates to:
  /// **'Dar'**
  String get lineNarrow;

  /// No description provided for @lineNormal.
  ///
  /// In tr, this message translates to:
  /// **'Normal'**
  String get lineNormal;

  /// No description provided for @lineWide.
  ///
  /// In tr, this message translates to:
  /// **'Geniş'**
  String get lineWide;

  /// No description provided for @readingTheme.
  ///
  /// In tr, this message translates to:
  /// **'Okuma teması'**
  String get readingTheme;

  /// No description provided for @themeDark.
  ///
  /// In tr, this message translates to:
  /// **'Koyu'**
  String get themeDark;

  /// No description provided for @themeLight.
  ///
  /// In tr, this message translates to:
  /// **'Açık'**
  String get themeLight;

  /// No description provided for @themeSepia.
  ///
  /// In tr, this message translates to:
  /// **'Sepya'**
  String get themeSepia;

  /// No description provided for @like.
  ///
  /// In tr, this message translates to:
  /// **'Beğen'**
  String get like;

  /// No description provided for @unlike.
  ///
  /// In tr, this message translates to:
  /// **'Beğeniyi geri al'**
  String get unlike;

  /// No description provided for @comment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yap'**
  String get comment;

  /// No description provided for @bookmark.
  ///
  /// In tr, this message translates to:
  /// **'Kaydet'**
  String get bookmark;

  /// No description provided for @removeBookmark.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenlerden çıkar'**
  String get removeBookmark;

  /// No description provided for @bookmarkAdded.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenlere eklendi'**
  String get bookmarkAdded;

  /// No description provided for @bookmarkRemoved.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenlerden çıkarıldı'**
  String get bookmarkRemoved;

  /// No description provided for @pinToProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profilime sabitle'**
  String get pinToProfile;

  /// No description provided for @unpin.
  ///
  /// In tr, this message translates to:
  /// **'Sabitlemeyi kaldır'**
  String get unpin;

  /// No description provided for @pinnedDone.
  ///
  /// In tr, this message translates to:
  /// **'Profiline sabitlendi'**
  String get pinnedDone;

  /// No description provided for @unpinned.
  ///
  /// In tr, this message translates to:
  /// **'Sabitleme kaldırıldı'**
  String get unpinned;

  /// No description provided for @deletePostTitle.
  ///
  /// In tr, this message translates to:
  /// **'İçerik silinsin mi?'**
  String get deletePostTitle;

  /// No description provided for @deletePostBody.
  ///
  /// In tr, this message translates to:
  /// **'Bu işlem geri alınamaz; yorumlar ve beğeniler de silinir.'**
  String get deletePostBody;

  /// No description provided for @postDeleted.
  ///
  /// In tr, this message translates to:
  /// **'İçerik silindi'**
  String get postDeleted;

  /// No description provided for @report.
  ///
  /// In tr, this message translates to:
  /// **'Şikayet et'**
  String get report;

  /// No description provided for @viewProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili gör'**
  String get viewProfile;

  /// No description provided for @personalNote.
  ///
  /// In tr, this message translates to:
  /// **'Kişisel yorum'**
  String get personalNote;

  /// No description provided for @postNotFound.
  ///
  /// In tr, this message translates to:
  /// **'İçerik bulunamadı'**
  String get postNotFound;

  /// No description provided for @postNotFoundHint.
  ///
  /// In tr, this message translates to:
  /// **'Silinmiş, kaldırılmış ya da erişimin olmayan bir içerik olabilir.'**
  String get postNotFoundHint;

  /// No description provided for @postRemovedNotice.
  ///
  /// In tr, this message translates to:
  /// **'Bu içerik kurallara aykırı bulunduğu için yayından kaldırıldı. Yalnızca sen görebilirsin.'**
  String get postRemovedNotice;

  /// No description provided for @commentsCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =0{Yorum yok} other{{count} yorum}}'**
  String commentsCount(int count);

  /// No description provided for @noComments.
  ///
  /// In tr, this message translates to:
  /// **'İlk yorumu sen yaz.'**
  String get noComments;

  /// No description provided for @reply.
  ///
  /// In tr, this message translates to:
  /// **'Yanıtla'**
  String get reply;

  /// No description provided for @writeComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum yaz…'**
  String get writeComment;

  /// No description provided for @replyingTo.
  ///
  /// In tr, this message translates to:
  /// **'{name} adlı kişiye yanıt'**
  String replyingTo(String name);

  /// No description provided for @editComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorumu düzenle'**
  String get editComment;

  /// No description provided for @deleteCommentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Yorum silinsin mi?'**
  String get deleteCommentTitle;

  /// No description provided for @reportSentTitle.
  ///
  /// In tr, this message translates to:
  /// **'Teşekkürler'**
  String get reportSentTitle;

  /// No description provided for @reportSentBody.
  ///
  /// In tr, this message translates to:
  /// **'Admine iletilmiştir. İçerik sahibine gerekli işlem yapılacaktır.'**
  String get reportSentBody;

  /// No description provided for @reportAlready.
  ///
  /// In tr, this message translates to:
  /// **'Bu içeriği zaten şikayet ettin'**
  String get reportAlready;

  /// No description provided for @block.
  ///
  /// In tr, this message translates to:
  /// **'Engelle'**
  String get block;

  /// No description provided for @unblock.
  ///
  /// In tr, this message translates to:
  /// **'Engeli kaldır'**
  String get unblock;

  /// No description provided for @blockConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'{name} engellensin mi?'**
  String blockConfirmTitle(String name);

  /// No description provided for @blockConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Onun içeriklerini ve yorumlarını görmezsin. O da senin içeriklerine yorum, beğeni ve @bahsetme yapamaz.'**
  String get blockConfirmBody;

  /// No description provided for @blocked.
  ///
  /// In tr, this message translates to:
  /// **'{name} engellendi'**
  String blocked(String name);

  /// No description provided for @unblocked.
  ///
  /// In tr, this message translates to:
  /// **'{name} için engel kaldırıldı'**
  String unblocked(String name);

  /// No description provided for @youBlockedUser.
  ///
  /// In tr, this message translates to:
  /// **'Bu kişiyi engelledin'**
  String get youBlockedUser;

  /// No description provided for @youBlockedUserHint.
  ///
  /// In tr, this message translates to:
  /// **'İçeriklerini görmek için menüden engeli kaldırabilirsin.'**
  String get youBlockedUserHint;

  /// No description provided for @editProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profili düzenle'**
  String get editProfile;

  /// No description provided for @bookmarks.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilenler'**
  String get bookmarks;

  /// No description provided for @userNotFound.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcı bulunamadı'**
  String get userNotFound;

  /// No description provided for @emptyLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanesi henüz boş'**
  String get emptyLibrary;

  /// No description provided for @emptyMyLibrary.
  ///
  /// In tr, this message translates to:
  /// **'Kütüphanen henüz boş. İlk içeriğini yaz!'**
  String get emptyMyLibrary;

  /// No description provided for @emptyType.
  ///
  /// In tr, this message translates to:
  /// **'Bu türde içerik yok'**
  String get emptyType;

  /// No description provided for @emptyBookmarks.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilen içerik yok'**
  String get emptyBookmarks;

  /// No description provided for @emptyBookmarksHint.
  ///
  /// In tr, this message translates to:
  /// **'Bir içeriği okurken yer imi ikonuna dokun. Bu liste yalnızca sana görünür.'**
  String get emptyBookmarksHint;

  /// No description provided for @changePhoto.
  ///
  /// In tr, this message translates to:
  /// **'Fotoğrafı değiştir'**
  String get changePhoto;

  /// No description provided for @changeCover.
  ///
  /// In tr, this message translates to:
  /// **'Kapağı değiştir'**
  String get changeCover;

  /// No description provided for @nicknameChangeRule.
  ///
  /// In tr, this message translates to:
  /// **'Nickname 30 günde bir değiştirilebilir; eski nickname 30 gün boyunca başkasına verilmez.'**
  String get nicknameChangeRule;

  /// No description provided for @nicknameNextChange.
  ///
  /// In tr, this message translates to:
  /// **'Nickname\'ini {date} tarihinden sonra değiştirebilirsin.'**
  String nicknameNextChange(String date);

  /// No description provided for @adminPanel.
  ///
  /// In tr, this message translates to:
  /// **'Admin paneli'**
  String get adminPanel;

  /// No description provided for @titleHint.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get titleHint;

  /// No description provided for @bodyHint.
  ///
  /// In tr, this message translates to:
  /// **'Yazmaya başla…'**
  String get bodyHint;

  /// No description provided for @quoteBodyHint.
  ///
  /// In tr, this message translates to:
  /// **'Alıntıyı buraya yaz…'**
  String get quoteBodyHint;

  /// No description provided for @personalNoteHint.
  ///
  /// In tr, this message translates to:
  /// **'Alıntının altında görünen notun (isteğe bağlı)'**
  String get personalNoteHint;

  /// No description provided for @addCover.
  ///
  /// In tr, this message translates to:
  /// **'Kapak ekle'**
  String get addCover;

  /// No description provided for @gallery.
  ///
  /// In tr, this message translates to:
  /// **'Görsel galerisi'**
  String get gallery;

  /// No description provided for @galleryOnlyProject.
  ///
  /// In tr, this message translates to:
  /// **'Galeri yalnızca projelerde olabilir; önce galeri görsellerini kaldır.'**
  String get galleryOnlyProject;

  /// No description provided for @tags.
  ///
  /// In tr, this message translates to:
  /// **'Etiketler'**
  String get tags;

  /// No description provided for @tagHint.
  ///
  /// In tr, this message translates to:
  /// **'Etiket ekle (virgül ya da boşlukla)'**
  String get tagHint;

  /// No description provided for @tagRule.
  ///
  /// In tr, this message translates to:
  /// **'En fazla {max} etiket; mevcut etiketler önerilir.'**
  String tagRule(int max);

  /// No description provided for @imageLimitInfo.
  ///
  /// In tr, this message translates to:
  /// **'Görseller: {count}/{max} (kapak + metin içi + galeri)'**
  String imageLimitInfo(int count, int max);

  /// No description provided for @saving.
  ///
  /// In tr, this message translates to:
  /// **'Kaydediliyor…'**
  String get saving;

  /// No description provided for @savedDraft.
  ///
  /// In tr, this message translates to:
  /// **'Taslak kaydedildi'**
  String get savedDraft;

  /// No description provided for @saveFailed.
  ///
  /// In tr, this message translates to:
  /// **'Kaydedilemedi'**
  String get saveFailed;

  /// No description provided for @published.
  ///
  /// In tr, this message translates to:
  /// **'Yayınlandı'**
  String get published;

  /// No description provided for @updated.
  ///
  /// In tr, this message translates to:
  /// **'Güncellendi'**
  String get updated;

  /// No description provided for @deleteDraftTitle.
  ///
  /// In tr, this message translates to:
  /// **'Taslak silinsin mi?'**
  String get deleteDraftTitle;

  /// No description provided for @discardChangesTitle.
  ///
  /// In tr, this message translates to:
  /// **'Değişiklikler kaydedilmedi'**
  String get discardChangesTitle;

  /// No description provided for @discardChangesBody.
  ///
  /// In tr, this message translates to:
  /// **'Çıkarsan yaptığın değişiklikler kaybolur.'**
  String get discardChangesBody;

  /// No description provided for @noDrafts.
  ///
  /// In tr, this message translates to:
  /// **'Taslak yok'**
  String get noDrafts;

  /// No description provided for @noDraftsHint.
  ///
  /// In tr, this message translates to:
  /// **'Yazdıkların otomatik olarak taslak kaydedilir.'**
  String get noDraftsHint;

  /// No description provided for @fmtHeading.
  ///
  /// In tr, this message translates to:
  /// **'Başlık'**
  String get fmtHeading;

  /// No description provided for @fmtBold.
  ///
  /// In tr, this message translates to:
  /// **'Kalın'**
  String get fmtBold;

  /// No description provided for @fmtItalic.
  ///
  /// In tr, this message translates to:
  /// **'İtalik'**
  String get fmtItalic;

  /// No description provided for @fmtQuote.
  ///
  /// In tr, this message translates to:
  /// **'Alıntı bloğu'**
  String get fmtQuote;

  /// No description provided for @fmtBullets.
  ///
  /// In tr, this message translates to:
  /// **'Liste'**
  String get fmtBullets;

  /// No description provided for @fmtNumbers.
  ///
  /// In tr, this message translates to:
  /// **'Numaralı liste'**
  String get fmtNumbers;

  /// No description provided for @addLink.
  ///
  /// In tr, this message translates to:
  /// **'Link ekle'**
  String get addLink;

  /// No description provided for @addImage.
  ///
  /// In tr, this message translates to:
  /// **'Görsel ekle'**
  String get addImage;

  /// No description provided for @undo.
  ///
  /// In tr, this message translates to:
  /// **'Geri al'**
  String get undo;

  /// No description provided for @redo.
  ///
  /// In tr, this message translates to:
  /// **'Yinele'**
  String get redo;

  /// No description provided for @searchHint.
  ///
  /// In tr, this message translates to:
  /// **'Kişi veya içerik ara'**
  String get searchHint;

  /// No description provided for @recentSearches.
  ///
  /// In tr, this message translates to:
  /// **'Son aramalar'**
  String get recentSearches;

  /// No description provided for @popularThisWeek.
  ///
  /// In tr, this message translates to:
  /// **'Haftanın popüler içerikleri'**
  String get popularThisWeek;

  /// No description provided for @people.
  ///
  /// In tr, this message translates to:
  /// **'Kişiler'**
  String get people;

  /// No description provided for @posts.
  ///
  /// In tr, this message translates to:
  /// **'İçerikler'**
  String get posts;

  /// No description provided for @noResults.
  ///
  /// In tr, this message translates to:
  /// **'Sonuç bulunamadı'**
  String get noResults;

  /// No description provided for @noPostResults.
  ///
  /// In tr, this message translates to:
  /// **'Bu aramayla eşleşen içerik yok'**
  String get noPostResults;

  /// No description provided for @notifComment.
  ///
  /// In tr, this message translates to:
  /// **'{user} içeriğine yorum yaptı'**
  String notifComment(String user);

  /// No description provided for @notifReply.
  ///
  /// In tr, this message translates to:
  /// **'{user} yorumuna yanıt verdi'**
  String notifReply(String user);

  /// No description provided for @notifLike.
  ///
  /// In tr, this message translates to:
  /// **'{user} içeriğini beğendi'**
  String notifLike(String user);

  /// No description provided for @notifMention.
  ///
  /// In tr, this message translates to:
  /// **'{user} bir yorumda senden bahsetti'**
  String notifMention(String user);

  /// No description provided for @noNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirim yok'**
  String get noNotifications;

  /// No description provided for @noNotificationsHint.
  ///
  /// In tr, this message translates to:
  /// **'Yorum, yanıt, beğeni ve bahsetmeler burada görünür.'**
  String get noNotificationsHint;

  /// No description provided for @moderationNoticeTitle.
  ///
  /// In tr, this message translates to:
  /// **'Moderasyon bildirimi'**
  String get moderationNoticeTitle;

  /// No description provided for @moderationRemoved.
  ///
  /// In tr, this message translates to:
  /// **'İçeriğin kurallara aykırı bulunduğu için kaldırıldı.'**
  String get moderationRemoved;

  /// No description provided for @moderationWarned.
  ///
  /// In tr, this message translates to:
  /// **'Hesabına resmi bir uyarı verildi.'**
  String get moderationWarned;

  /// No description provided for @moderationBanned.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın kalıcı olarak kapatıldı.'**
  String get moderationBanned;

  /// No description provided for @moderationGeneric.
  ///
  /// In tr, this message translates to:
  /// **'Hesabınla ilgili bir moderasyon bildirimi var.'**
  String get moderationGeneric;

  /// No description provided for @adminNote.
  ///
  /// In tr, this message translates to:
  /// **'Admin notu'**
  String get adminNote;

  /// No description provided for @viewPost.
  ///
  /// In tr, this message translates to:
  /// **'İçeriği gör'**
  String get viewPost;

  /// No description provided for @reports.
  ///
  /// In tr, this message translates to:
  /// **'Şikayetler'**
  String get reports;

  /// No description provided for @appVersion.
  ///
  /// In tr, this message translates to:
  /// **'Uygulama sürümü'**
  String get appVersion;

  /// No description provided for @noOpenReports.
  ///
  /// In tr, this message translates to:
  /// **'Bekleyen şikayet yok'**
  String get noOpenReports;

  /// No description provided for @reportTargetPost.
  ///
  /// In tr, this message translates to:
  /// **'İçerik'**
  String get reportTargetPost;

  /// No description provided for @reportTargetComment.
  ///
  /// In tr, this message translates to:
  /// **'Yorum'**
  String get reportTargetComment;

  /// No description provided for @reportTargetProfile.
  ///
  /// In tr, this message translates to:
  /// **'Profil'**
  String get reportTargetProfile;

  /// No description provided for @reportCount.
  ///
  /// In tr, this message translates to:
  /// **'{count, plural, =1{1 şikayet} other{{count} şikayet}}'**
  String reportCount(int count);

  /// No description provided for @dismiss.
  ///
  /// In tr, this message translates to:
  /// **'Reddet'**
  String get dismiss;

  /// No description provided for @removeContent.
  ///
  /// In tr, this message translates to:
  /// **'İçeriği kaldır'**
  String get removeContent;

  /// No description provided for @warn.
  ///
  /// In tr, this message translates to:
  /// **'Uyarı ver'**
  String get warn;

  /// No description provided for @ban.
  ///
  /// In tr, this message translates to:
  /// **'Kalıcı ban'**
  String get ban;

  /// No description provided for @adminNoteOptional.
  ///
  /// In tr, this message translates to:
  /// **'Not (isteğe bağlı, kullanıcıya gösterilir)'**
  String get adminNoteOptional;

  /// No description provided for @moderationDone.
  ///
  /// In tr, this message translates to:
  /// **'İşlem uygulandı'**
  String get moderationDone;

  /// No description provided for @appVersionHelp.
  ///
  /// In tr, this message translates to:
  /// **'Kullanıcının sürümü \"son sürüm\"den eskiyse \"Yeni sürüm var\" uyarısı çıkar; \"en düşük sürüm\"den eskiyse kurmadan devam edemez.'**
  String get appVersionHelp;

  /// No description provided for @latestVersion.
  ///
  /// In tr, this message translates to:
  /// **'Son sürüm'**
  String get latestVersion;

  /// No description provided for @minVersion.
  ///
  /// In tr, this message translates to:
  /// **'En düşük sürüm'**
  String get minVersion;

  /// No description provided for @apkUrl.
  ///
  /// In tr, this message translates to:
  /// **'APK indirme linki'**
  String get apkUrl;

  /// No description provided for @settingsAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesap'**
  String get settingsAccount;

  /// No description provided for @settingsNotifications.
  ///
  /// In tr, this message translates to:
  /// **'Bildirimler'**
  String get settingsNotifications;

  /// No description provided for @settingsAppearance.
  ///
  /// In tr, this message translates to:
  /// **'Görünüm'**
  String get settingsAppearance;

  /// No description provided for @settingsBlocked.
  ///
  /// In tr, this message translates to:
  /// **'Engellenen kullanıcılar'**
  String get settingsBlocked;

  /// No description provided for @settingsAbout.
  ///
  /// In tr, this message translates to:
  /// **'Hakkında'**
  String get settingsAbout;

  /// No description provided for @changeEmail.
  ///
  /// In tr, this message translates to:
  /// **'E-postayı değiştir'**
  String get changeEmail;

  /// No description provided for @newEmail.
  ///
  /// In tr, this message translates to:
  /// **'Yeni e-posta'**
  String get newEmail;

  /// No description provided for @emailChangeCodeSent.
  ///
  /// In tr, this message translates to:
  /// **'{email} adresine gönderilen kodu gir.'**
  String emailChangeCodeSent(String email);

  /// No description provided for @emailChanged.
  ///
  /// In tr, this message translates to:
  /// **'E-posta adresin değişti'**
  String get emailChanged;

  /// No description provided for @changePassword.
  ///
  /// In tr, this message translates to:
  /// **'Şifreyi değiştir'**
  String get changePassword;

  /// No description provided for @deleteAccount.
  ///
  /// In tr, this message translates to:
  /// **'Hesabı sil'**
  String get deleteAccount;

  /// No description provided for @deleteAccountHint.
  ///
  /// In tr, this message translates to:
  /// **'30 gün sonra kesinleşir'**
  String get deleteAccountHint;

  /// No description provided for @deleteAccountConfirmTitle.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın silinsin mi?'**
  String get deleteAccountConfirmTitle;

  /// No description provided for @deleteAccountConfirmBody.
  ///
  /// In tr, this message translates to:
  /// **'Hesabın ve tüm verilerin 30 gün sonra kalıcı olarak silinir. Bu sürede tekrar giriş yaparsan talep iptal olur.'**
  String get deleteAccountConfirmBody;

  /// No description provided for @deleteAccountRequested.
  ///
  /// In tr, this message translates to:
  /// **'Silme talebin alındı. 30 gün içinde giriş yaparsan iptal olur.'**
  String get deleteAccountRequested;

  /// No description provided for @notifSettingComment.
  ///
  /// In tr, this message translates to:
  /// **'İçeriğime yorum'**
  String get notifSettingComment;

  /// No description provided for @notifSettingReply.
  ///
  /// In tr, this message translates to:
  /// **'Yorumuma yanıt'**
  String get notifSettingReply;

  /// No description provided for @notifSettingLike.
  ///
  /// In tr, this message translates to:
  /// **'İçeriğim beğenildi'**
  String get notifSettingLike;

  /// No description provided for @notifSettingMention.
  ///
  /// In tr, this message translates to:
  /// **'@bahsedilme'**
  String get notifSettingMention;

  /// No description provided for @notifSettingModeration.
  ///
  /// In tr, this message translates to:
  /// **'Moderasyon bildirimleri (uyarı, içerik kaldırma) her zaman uygulama içinde gösterilir.'**
  String get notifSettingModeration;

  /// No description provided for @language.
  ///
  /// In tr, this message translates to:
  /// **'Dil'**
  String get language;

  /// No description provided for @languageSystem.
  ///
  /// In tr, this message translates to:
  /// **'Telefonun dili'**
  String get languageSystem;

  /// No description provided for @theme.
  ///
  /// In tr, this message translates to:
  /// **'Tema'**
  String get theme;

  /// No description provided for @noBlockedUsers.
  ///
  /// In tr, this message translates to:
  /// **'Engellediğin kimse yok'**
  String get noBlockedUsers;

  /// No description provided for @versionLabel.
  ///
  /// In tr, this message translates to:
  /// **'Sürüm {version}'**
  String versionLabel(String version);

  /// No description provided for @openSourceLicenses.
  ///
  /// In tr, this message translates to:
  /// **'Açık kaynak lisansları'**
  String get openSourceLicenses;

  /// No description provided for @contact.
  ///
  /// In tr, this message translates to:
  /// **'İletişim'**
  String get contact;

  /// No description provided for @legalTurkishOnly.
  ///
  /// In tr, this message translates to:
  /// **'This text is currently available in Turkish only.'**
  String get legalTurkishOnly;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'tr'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'tr':
      return AppLocalizationsTr();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}

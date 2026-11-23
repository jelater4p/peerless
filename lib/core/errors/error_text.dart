// Supabase'den gelen hataları kullanıcıya gösterilecek TR/EN metne çevirir.
// Veritabanı kısa kodlar gönderir (ör. 'nickname_reserved'); karşılıkları burada.
import 'dart:async';
import 'dart:io';

import 'package:supabase_flutter/supabase_flutter.dart';

import '../l10n.dart';

String errorText(AppLocalizations l, Object error) {
  if (error is AuthException) {
    switch (error.code) {
      case 'invalid_credentials':
        return l.errInvalidCredentials;
      case 'email_not_confirmed':
        return l.errEmailNotConfirmed;
      case 'user_already_exists':
      case 'email_exists':
        return l.errEmailExists;
      case 'weak_password':
        return l.errWeakPassword;
      case 'same_password':
        return l.errSamePassword;
      case 'otp_expired':
      case 'otp_disabled':
        return l.errCodeInvalid;
      case 'over_email_send_rate_limit':
      case 'over_request_rate_limit':
        return l.errRateLimit;
      case 'user_banned':
        return l.errBanned;
      case 'email_address_invalid':
      case 'validation_failed':
        return l.errInvalidEmail;
    }
    if (error is AuthRetryableFetchException) return l.errOffline;
    return error.message;
  }

  if (error is PostgrestException) {
    final m = error.message;
    const codes = <String, String Function(AppLocalizations)>{
      'nickname_reserved': _nicknameReserved,
      'nickname_change_too_soon': _nicknameTooSoon,
      'too_many_tags': _tooManyTags,
      'too_many_images': _tooManyImages,
      'gallery_only_project': _galleryOnlyProject,
      'invalid_parent': _generic,
      'cannot_unpublish': _generic,
      'pin_requires_published': _pinRequiresPublished,
      'not_admin': _notAllowed,
      'not_post_author': _notAllowed,
      'cannot_moderate_self': _notAllowed,
      'reports_once': _alreadyReported,
    };
    for (final e in codes.entries) {
      if (m.contains(e.key)) return e.value(l);
    }
    if (error.code == '23505') {
      return m.contains('nickname') ? l.errNicknameTaken : l.errDuplicate;
    }
    if (error.code == '42501' || m.contains('row-level security')) return l.errNotAllowed;
    if (error.code == '23514') return l.errInvalidInput;
    return l.errGeneric;
  }

  if (error is StorageException) return l.errUpload;
  if (isNetworkError(error)) return l.errOffline;
  return l.errGeneric;
}

/// İnternet yok / sunucuya ulaşılamıyor mu?
bool isNetworkError(Object error) {
  if (error is SocketException || error is TimeoutException || error is HandshakeException) return true;
  if (error is AuthRetryableFetchException) return true;
  final s = error.toString();
  return s.contains('SocketException') || s.contains('ClientException') || s.contains('Failed host lookup');
}

String _nicknameReserved(AppLocalizations l) => l.errNicknameReserved;
String _nicknameTooSoon(AppLocalizations l) => l.errNicknameTooSoon;
String _tooManyTags(AppLocalizations l) => l.errTooManyTags;
String _tooManyImages(AppLocalizations l) => l.errTooManyImages;
String _galleryOnlyProject(AppLocalizations l) => l.errGeneric;
String _pinRequiresPublished(AppLocalizations l) => l.errGeneric;
String _notAllowed(AppLocalizations l) => l.errNotAllowed;
String _alreadyReported(AppLocalizations l) => l.reportAlready;
String _generic(AppLocalizations l) => l.errGeneric;

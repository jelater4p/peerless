import 'package:material_ui/material_ui.dart';

/// profiles tablosundaki bir satır.
@immutable
class Profile {
  const Profile({
    required this.id,
    this.nickname,
    this.displayName,
    this.bio,
    this.avatarUrl,
    this.coverUrl,
    this.locale = 'tr',
    this.role = 'user',
    this.status = 'active',
    this.nicknameChangedAt,
    this.deletionRequestedAt,
    this.createdAt,
  });

  factory Profile.fromJson(Map<String, dynamic> j) => Profile(
        id: j['id'] as String,
        nickname: j['nickname'] as String?,
        displayName: j['display_name'] as String?,
        bio: j['bio'] as String?,
        avatarUrl: j['avatar_url'] as String?,
        coverUrl: j['cover_url'] as String?,
        locale: (j['locale'] as String?) ?? 'tr',
        role: (j['role'] as String?) ?? 'user',
        status: (j['status'] as String?) ?? 'active',
        nicknameChangedAt: _date(j['nickname_changed_at']),
        deletionRequestedAt: _date(j['deletion_requested_at']),
        createdAt: _date(j['created_at']),
      );

  final String id;
  final String? nickname;
  final String? displayName;
  final String? bio;
  final String? avatarUrl;
  final String? coverUrl;
  final String locale;
  final String role;
  final String status;
  final DateTime? nicknameChangedAt;
  final DateTime? deletionRequestedAt;
  final DateTime? createdAt;

  bool get isAdmin => role == 'admin' && status == 'active';
  bool get isBanned => status == 'banned';
  bool get hasNickname => nickname != null && nickname!.isNotEmpty;

  /// Görünen ad yoksa @nickname gösterilir.
  String get name => (displayName?.isNotEmpty ?? false) ? displayName! : '@${nickname ?? ''}';

  /// Nickname bir sonraki ne zaman değiştirilebilir? (null = şimdi)
  DateTime? get nextNicknameChangeAt {
    final c = nicknameChangedAt;
    if (c == null) return null;
    final next = c.add(const Duration(days: 30));
    return next.isAfter(DateTime.now()) ? next : null;
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'display_name': displayName,
        'bio': bio,
        'avatar_url': avatarUrl,
        'cover_url': coverUrl,
        'locale': locale,
        'role': role,
        'status': status,
      };
}

/// Kart ve yorumlarda yazar bilgisi için küçük profil.
@immutable
class ProfileSummary {
  const ProfileSummary({required this.id, this.nickname, this.displayName, this.avatarUrl});

  factory ProfileSummary.fromJson(Map<String, dynamic> j) => ProfileSummary(
        id: j['id'] as String,
        nickname: j['nickname'] as String?,
        displayName: j['display_name'] as String?,
        avatarUrl: j['avatar_url'] as String?,
      );

  final String id;
  final String? nickname;
  final String? displayName;
  final String? avatarUrl;

  String get name => (displayName?.isNotEmpty ?? false) ? displayName! : '@${nickname ?? ''}';
  String get handle => '@${nickname ?? ''}';

  Map<String, dynamic> toJson() => {
        'id': id,
        'nickname': nickname,
        'display_name': displayName,
        'avatar_url': avatarUrl,
      };

  /// PostgREST'te yazar bilgisini çekmek için seçim metni.
  static const select = 'id, nickname, display_name, avatar_url';
}

DateTime? _date(Object? v) => v == null ? null : DateTime.tryParse(v as String)?.toLocal();

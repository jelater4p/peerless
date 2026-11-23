import 'dart:typed_data';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/supabase/supabase_providers.dart';
import 'profile.dart';

class ProfileRepository {
  ProfileRepository(this._client);
  final SupabaseClient _client;

  String? get _uid => _client.auth.currentUser?.id;

  Future<Profile?> getMyProfile() async {
    final uid = _uid;
    if (uid == null) return null;
    final row = await _client.from('profiles').select().eq('id', uid).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<Profile?> getProfile(String id) async {
    final row = await _client.from('profiles').select().eq('id', id).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<Profile?> getProfileByNickname(String nickname) async {
    final row = await _client.from('profiles').select().eq('nickname', nickname.toLowerCase()).maybeSingle();
    return row == null ? null : Profile.fromJson(row);
  }

  Future<bool> isNicknameAvailable(String nickname) async {
    final res = await _client.rpc('is_nickname_available', params: {'p_nickname': nickname});
    return res == true;
  }

  /// Yalnızca izin verilen alanlar: nickname, display_name, bio, avatar_url, cover_url, locale.
  Future<void> update(Map<String, dynamic> fields) async {
    await _client.from('profiles').update(fields).eq('id', _uid!);
  }

  /// Profil fotoğrafı: `avatars/<uid>/avatar.jpg` (önbellek için sürüm eki).
  Future<String> uploadAvatar(Uint8List jpeg) => _upload('avatars', 'avatar.jpg', jpeg);

  /// Kapak görseli: `covers/<uid>/cover.jpg`
  Future<String> uploadCover(Uint8List jpeg) => _upload('covers', 'cover.jpg', jpeg);

  Future<String> _upload(String bucket, String name, Uint8List bytes) async {
    final path = '$_uid/$name';
    await _client.storage.from(bucket).uploadBinary(
          path,
          bytes,
          fileOptions: const FileOptions(contentType: 'image/jpeg', upsert: true),
        );
    final url = _client.storage.from(bucket).getPublicUrl(path);
    return '$url?v=${DateTime.now().millisecondsSinceEpoch}';
  }

  Future<void> removeStorageFile(String bucket, String name) async {
    await _client.storage.from(bucket).remove(['$_uid/$name']);
  }

  Future<void> requestAccountDeletion() => _client.rpc('request_account_deletion');

  // --- Engelleme -------------------------------------------------------

  Future<void> block(String userId) async {
    await _client.from('blocks').upsert({'blocker_id': _uid, 'blocked_id': userId});
  }

  Future<void> unblock(String userId) async {
    await _client.from('blocks').delete().eq('blocker_id', _uid!).eq('blocked_id', userId);
  }

  Future<bool> isBlocked(String userId) async {
    final row = await _client
        .from('blocks')
        .select('blocked_id')
        .eq('blocker_id', _uid!)
        .eq('blocked_id', userId)
        .maybeSingle();
    return row != null;
  }

  Future<List<ProfileSummary>> blockedUsers() async {
    final rows = await _client
        .from('blocks')
        .select('blocked:profiles!blocks_blocked_id_fkey(${ProfileSummary.select})')
        .eq('blocker_id', _uid!)
        .order('created_at', ascending: false);
    return rows
        .map((r) => r['blocked'])
        .whereType<Map<String, dynamic>>()
        .map(ProfileSummary.fromJson)
        .toList();
  }

  /// Kişi arama (nickname ve görünen ad).
  Future<List<Profile>> search(String query, {int limit = 3}) async {
    final rows = await _client.rpc('search_profiles', params: {'p_query': query, 'p_limit': limit});
    return (rows as List).map((r) => Profile.fromJson(r as Map<String, dynamic>)).toList();
  }
}

final profileRepositoryProvider =
    Provider<ProfileRepository>((ref) => ProfileRepository(ref.watch(supabaseProvider)));

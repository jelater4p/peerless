import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/cache/app_database.dart';
import '../auth/data/auth_repository.dart';
import '../notifications/notification_providers.dart';

/// Çıkış: önce bu cihazın push kaydı silinir, önbellek temizlenir, sonra oturum kapanır.
Future<void> signOutEverywhere(WidgetRef ref) async {
  await ref.read(pushServiceProvider).stop();
  try {
    await ref.read(appDatabaseProvider).clearAll();
  } catch (_) {}
  await ref.read(authRepositoryProvider).signOut();
}

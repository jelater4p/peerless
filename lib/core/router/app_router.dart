// Sayfa geçişleri (go_router). Oturum durumuna göre yönlendirme kuralları
// `redirect` içinde: tanıtım → giriş → nickname seçimi → ana akış.
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:material_ui/material_ui.dart';

import '../../features/admin/screens/admin_screen.dart';
import '../../features/auth/screens/forgot_password_screen.dart';
import '../../features/auth/screens/intro_screen.dart';
import '../../features/auth/screens/setup_nickname_screen.dart';
import '../../features/auth/screens/setup_profile_screen.dart';
import '../../features/auth/screens/sign_in_screen.dart';
import '../../features/auth/screens/sign_up_screen.dart';
import '../../features/auth/screens/splash_screen.dart';
import '../../features/auth/screens/verify_email_screen.dart';
import '../../features/editor/screens/drafts_screen.dart';
import '../../features/editor/screens/editor_screen.dart';
import '../../features/feed/screens/feed_screen.dart';
import '../../features/home/home_shell.dart';
import '../../features/notifications/screens/notifications_screen.dart';
import '../../features/post/data/post.dart';
import '../../features/post/screens/post_detail_screen.dart';
import '../../features/profile/screens/edit_profile_screen.dart';
import '../../features/profile/screens/profile_screen.dart';
import '../../features/search/screens/search_screen.dart';
import '../../features/settings/screens/about_screen.dart';
import '../../features/settings/screens/account_screen.dart';
import '../../features/settings/screens/appearance_screen.dart';
import '../../features/settings/screens/blocked_users_screen.dart';
import '../../features/settings/screens/legal_screen.dart';
import '../../features/settings/screens/notification_settings_screen.dart';
import '../../features/settings/screens/settings_screen.dart';
import '../session/session_controller.dart';
import '../settings/app_settings.dart';

final rootNavigatorKey = GlobalKey<NavigatorState>();

/// Sık kullanılan yollar.
abstract final class Routes {
  static const splash = '/splash';
  static const intro = '/intro';
  static const signIn = '/auth';
  static const signUp = '/auth/sign-up';
  static const verify = '/auth/verify';
  static const forgot = '/auth/forgot';
  static const setupNickname = '/setup/nickname';
  static const setupProfile = '/setup/profile';
  static const feed = '/feed';
  static const search = '/search';
  static const notifications = '/notifications';
  static const me = '/me';
  static const drafts = '/drafts';
  static const settings = '/settings';
  static const admin = '/admin';

  static String post(String id) => '/post/$id';
  static String user(String id) => '/u/$id';
  static String userByNickname(String nickname) => '/n/$nickname';
  static String editor({String? postId, PostType? type}) => Uri(
        path: '/editor',
        queryParameters: {'id': ?postId, 'type': ?type?.name},
      ).toString();
}

final routerProvider = Provider<GoRouter>((ref) {
  // Oturum veya tanıtım durumu değişince yönlendirme yeniden değerlendirilir.
  final refresh = ValueNotifier<int>(0);
  ref.listen(sessionProvider, (_, _) => refresh.value++);
  ref.listen(appSettingsProvider.select((s) => s.seenIntro), (_, _) => refresh.value++);
  ref.onDispose(refresh.dispose);

  return GoRouter(
    navigatorKey: rootNavigatorKey,
    initialLocation: Routes.splash,
    refreshListenable: refresh,
    redirect: (context, state) {
      final session = ref.read(sessionProvider);
      final seenIntro = ref.read(appSettingsProvider).seenIntro;
      final loc = state.matchedLocation;
      final atAuth = loc.startsWith('/auth');

      switch (session.status) {
        case SessionStatus.loading:
        case SessionStatus.offline:
          return loc == Routes.splash ? null : Routes.splash;
        case SessionStatus.signedOut:
          if (!seenIntro) return loc == Routes.intro ? null : Routes.intro;
          return atAuth ? null : Routes.signIn;
        case SessionStatus.needsNickname:
          return loc == Routes.setupNickname ? null : Routes.setupNickname;
        case SessionStatus.ready:
          if (session.onboarding) return loc == Routes.setupProfile ? null : Routes.setupProfile;
          if (atAuth || loc == Routes.splash || loc == Routes.intro || loc == Routes.setupNickname) {
            return Routes.feed;
          }
          if (loc.startsWith(Routes.admin) && !session.isAdmin) return Routes.feed;
          return null;
      }
    },
    routes: [
      GoRoute(path: Routes.splash, builder: (_, _) => const SplashScreen()),
      GoRoute(path: Routes.intro, builder: (_, _) => const IntroScreen()),
      GoRoute(
        path: Routes.signIn,
        builder: (_, _) => const SignInScreen(),
        routes: [
          GoRoute(path: 'sign-up', builder: (_, _) => const SignUpScreen()),
          GoRoute(
            path: 'verify',
            builder: (_, s) => VerifyEmailScreen(email: s.uri.queryParameters['email'] ?? ''),
          ),
          GoRoute(path: 'forgot', builder: (_, _) => const ForgotPasswordScreen()),
          GoRoute(
            path: 'legal/:doc',
            builder: (_, s) => LegalScreen(doc: LegalDoc.fromName(s.pathParameters['doc'])),
          ),
        ],
      ),
      GoRoute(path: Routes.setupNickname, builder: (_, _) => const SetupNicknameScreen()),
      GoRoute(path: Routes.setupProfile, builder: (_, _) => const SetupProfileScreen()),

      // Alt navigasyonlu ana bölüm: Akış · Arama · (Yaz) · Bildirimler · Profil
      StatefulShellRoute.indexedStack(
        builder: (_, _, shell) => HomeShell(navigationShell: shell),
        branches: [
          StatefulShellBranch(routes: [GoRoute(path: Routes.feed, builder: (_, _) => const FeedScreen())]),
          StatefulShellBranch(routes: [GoRoute(path: Routes.search, builder: (_, _) => const SearchScreen())]),
          StatefulShellBranch(
            routes: [GoRoute(path: Routes.notifications, builder: (_, _) => const NotificationsScreen())],
          ),
          StatefulShellBranch(routes: [GoRoute(path: Routes.me, builder: (_, _) => const MyProfileScreen())]),
        ],
      ),

      GoRoute(
        path: '/post/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => PostDetailScreen(postId: s.pathParameters['id']!),
      ),
      GoRoute(
        path: '/u/:id',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => ProfileScreen(userId: s.pathParameters['id']),
      ),
      GoRoute(
        path: '/n/:nickname',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => ProfileScreen(nickname: s.pathParameters['nickname']!),
      ),
      GoRoute(
        path: '/editor',
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, s) => EditorScreen(
          postId: s.uri.queryParameters['id'],
          initialType: s.uri.queryParameters['type'] == null
              ? null
              : PostType.fromName(s.uri.queryParameters['type']),
        ),
      ),
      GoRoute(path: Routes.drafts, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const DraftsScreen()),
      GoRoute(
        path: Routes.settings,
        parentNavigatorKey: rootNavigatorKey,
        builder: (_, _) => const SettingsScreen(),
        routes: [
          GoRoute(path: 'profile', builder: (_, _) => const EditProfileScreen()),
          GoRoute(path: 'account', builder: (_, _) => const AccountScreen()),
          GoRoute(path: 'notifications', builder: (_, _) => const NotificationSettingsScreen()),
          GoRoute(path: 'appearance', builder: (_, _) => const AppearanceScreen()),
          GoRoute(path: 'blocked', builder: (_, _) => const BlockedUsersScreen()),
          GoRoute(path: 'about', builder: (_, _) => const AboutScreen()),
          GoRoute(
            path: 'legal/:doc',
            builder: (_, s) => LegalScreen(doc: LegalDoc.fromName(s.pathParameters['doc'])),
          ),
        ],
      ),
      GoRoute(path: Routes.admin, parentNavigatorKey: rootNavigatorKey, builder: (_, _) => const AdminScreen()),
    ],
  );
});

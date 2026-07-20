import 'package:flutter/material.dart';

import '../screens/splash/splash_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/auth/forgot_password_screen.dart';
import '../screens/home/home_shell.dart';
import '../screens/home/search_screen.dart';
import '../screens/courses/course_details_screen.dart';
import '../screens/courses/pdf_viewer_screen.dart';
import '../screens/courses/video_player_screen.dart';
import '../screens/live/live_classes_screen.dart';
import '../screens/tests/test_list_screen.dart';
import '../screens/tests/test_attempt_screen.dart';
import '../screens/tests/test_result_screen.dart';
import '../screens/progress/leaderboard_screen.dart';
import '../screens/progress/achievements_screen.dart';
import '../screens/bookmarks/bookmarks_screen.dart';
import '../screens/downloads/downloads_screen.dart';
import '../screens/notifications/notifications_screen.dart';
import '../screens/profile/edit_profile_screen.dart';
import '../screens/settings/settings_screen.dart';
import '../screens/payments/checkout_screen.dart';
import '../screens/payments/payment_success_screen.dart';
import '../screens/payments/payment_failed_screen.dart';
import '../screens/payments/payment_history_screen.dart';
import '../screens/payments/my_purchases_screen.dart';
import '../screens/admin/admin_login_screen.dart';
import '../screens/admin/admin_dashboard_screen.dart';

class AppRoutes {
  static const splash = '/';
  static const login = '/login';
  static const signup = '/signup';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const search = '/search';
  static const courseDetails = '/course-details';
  static const pdfViewer = '/pdf-viewer';
  static const videoPlayer = '/video-player';
  static const liveClasses = '/live-classes';
  static const testList = '/test-list';
  static const testAttempt = '/test-attempt';
  static const testResult = '/test-result';
  static const leaderboard = '/leaderboard';
  static const achievements = '/achievements';
  static const bookmarks = '/bookmarks';
  static const downloads = '/downloads';
  static const notifications = '/notifications';
  static const editProfile = '/edit-profile';
  static const settings = '/settings';
  static const checkout = '/checkout';
  static const paymentSuccess = '/payment-success';
  static const paymentFailed = '/payment-failed';
  static const paymentHistory = '/payment-history';
  static const myPurchases = '/my-purchases';
  static const adminLogin = '/admin-login';
  static const adminDashboard = '/admin-dashboard';

  static Map<String, WidgetBuilder> routes = {
    splash: (_) => const SplashScreen(),
    login: (_) => const LoginScreen(),
    signup: (_) => const SignupScreen(),
    forgotPassword: (_) => const ForgotPasswordScreen(),
    home: (_) => const HomeShell(),
    search: (_) => const SearchScreen(),
    liveClasses: (_) => const LiveClassesScreen(),
    leaderboard: (_) => const LeaderboardScreen(),
    achievements: (_) => const AchievementsScreen(),
    bookmarks: (_) => const BookmarksScreen(),
    downloads: (_) => const DownloadsScreen(),
    notifications: (_) => const NotificationsScreen(),
    editProfile: (_) => const EditProfileScreen(),
    settings: (_) => const SettingsScreen(),
    paymentSuccess: (_) => const PaymentSuccessScreen(),
    paymentFailed: (_) => const PaymentFailedScreen(),
    paymentHistory: (_) => const PaymentHistoryScreen(),
    myPurchases: (_) => const MyPurchasesScreen(),
    adminLogin: (_) => const AdminLoginScreen(),
    adminDashboard: (_) => const AdminDashboardScreen(),
  };

  /// Routes that need an argument (courseId, testId, etc.) are generated here.
  static Route<dynamic>? onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case courseDetails:
        final courseId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CourseDetailsScreen(courseId: courseId));
      case pdfViewer:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
            builder: (_) => PdfViewerScreen(url: args['url']!, title: args['title'] ?? 'PDF'));
      case videoPlayer:
        final args = settings.arguments as Map<String, String>;
        return MaterialPageRoute(
            builder: (_) => VideoPlayerScreen(url: args['url']!, title: args['title'] ?? 'Video'));
      case testList:
        final type = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => TestListScreen(testType: type));
      case testAttempt:
        final testId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => TestAttemptScreen(testId: testId));
      case testResult:
        final args = settings.arguments as Map<String, dynamic>;
        return MaterialPageRoute(
            builder: (_) => TestResultScreen(score: args['score'], total: args['total']));
      case checkout:
        final courseId = settings.arguments as String;
        return MaterialPageRoute(builder: (_) => CheckoutScreen(courseId: courseId));
      default:
        return null;
    }
  }
}

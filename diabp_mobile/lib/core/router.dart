import 'package:go_router/go_router.dart';
import '../providers/auth_provider.dart';
import '../screens/home/home_screen.dart';
import '../screens/auth/login_screen.dart';
import '../screens/auth/signup_screen.dart';
import '../screens/bmi/bmi_screen.dart';
import '../screens/diet_plan/diet_plan_screen.dart';
import '../screens/records/health_records_screen.dart';
import '../screens/admin/db_viewer_screen.dart';
import '../screens/feedback/feedback_screen.dart';
import '../screens/chat/chatbot_screen.dart';

GoRouter createRouter(AuthProvider authProvider) {
  return GoRouter(
    initialLocation: '/',
    redirect: (context, state) {
      final isLoggedIn = authProvider.isLoggedIn;
      final isAuthRoute = state.matchedLocation == '/login' ||
          state.matchedLocation == '/signup';

      if (!isLoggedIn && !isAuthRoute && state.matchedLocation != '/') {
        return '/login';
      }
      return null;
    },
    routes: [
      GoRoute(path: '/', builder: (context, state) => const HomeScreen()),
      GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
      GoRoute(path: '/signup', builder: (context, state) => const SignupScreen()),
      GoRoute(path: '/bmi', builder: (context, state) => const BmiScreen()),
      GoRoute(path: '/diet-plan', builder: (context, state) => const DietPlanScreen()),
      GoRoute(path: '/records', builder: (context, state) => const HealthRecordsScreen()),
      GoRoute(path: '/admin', builder: (context, state) => const DbViewerScreen()),
      GoRoute(path: '/feedback', builder: (context, state) => const FeedbackScreen()),
      GoRoute(path: '/chat', builder: (context, state) => const ChatbotScreen()),
    ],
  );
}

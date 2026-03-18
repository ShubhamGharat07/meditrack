// import 'package:go_router/go_router.dart';
// import 'package:meditrack/views/auth/Forgotpassword_screen.dart';
// import 'package:meditrack/views/notification/notification_screen.dart';
// import 'package:meditrack/views/health_insurance/health_insurance_screen.dart';
// import '../providers/auth_provider.dart';
// import '../views/splash/splash_screen.dart';
// import '../views/onboarding/onboarding_screen.dart';
// import '../views/auth/login_screen.dart';
// import '../views/auth/register_screen.dart';
// import '../views/dashboard/dashboard_screen.dart';
// import '../views/medicines/medicine_list_screen.dart';
// import '../views/medicines/medicine_detail_screen.dart';
// import '../views/medicines/add_medicine_screen.dart';
// import '../views/doctors/doctors_screen.dart';
// import '../views/health_records/health_records_screen.dart';
// import '../views/ai_assistant/ai_assistant_screen.dart';
// import '../views/family/family_screen.dart';
// import '../views/family/family_member_detail_screen.dart';
// import '../views/family/add_edit_family_member_screen.dart';
// import '../views/analytics/analytics_screen.dart';
// import '../views/emergency/emergency_screen.dart';
// import '../views/profile/profile_screen.dart';
// import '../views/settings/settings_screen.dart';
// import '../widgets/common/bottom_nav_bar.dart';

// class AppRoutes {
//   static const String splash = '/';
//   static const String onboarding = '/onboarding';
//   static const String login = '/login';
//   static const String register = '/register';
//   static const String dashboard = '/dashboard';
//   static const String medicines = '/medicines';
//   static const String medicineDetail = '/medicines/detail/:id';
//   static const String addMedicine = '/medicines/add';
//   static const String healthRecords = '/health-records';
//   static const String aiAssistant = '/ai-assistant';
//   static const String profile = '/profile';
//   static const String settings = '/profile/settings';
//   static const String doctors = '/doctors';
//   static const String family = '/family';
//   static const String familyMemberDetail = '/family/detail/:id';
//   static const String addFamilyMember = '/family/add';
//   static const String editFamilyMember = '/family/edit/:id';
//   static const String analytics = '/analytics';
//   static const String emergency = '/emergency';
//   static const String notifications = '/notifications';
//   static const String healthInsurance = '/health-insurance'; // NEW
//   static const String forgotPassword = '/forgot-password';

//   static GoRouter router(AuthProvider authProvider) {
//     return GoRouter(
//       initialLocation: splash,
//       debugLogDiagnostics: false,
//       routes: [
//         GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
//         GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
//         GoRoute(path: login, builder: (_, __) => const LoginScreen()),
//         GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
//         GoRoute(
//           path: forgotPassword,
//           builder: (_, __) => const ForgotPasswordScreen(),
//         ),

//         // ── Bottom Nav Shell ──
//         ShellRoute(
//           builder: (context, state, child) => BottomNavBar(child: child),
//           routes: [
//             GoRoute(
//               path: dashboard,
//               builder: (_, __) => const DashboardScreen(),
//             ),
//             GoRoute(
//               path: medicines,
//               builder: (_, __) => const MedicineListScreen(),
//               routes: [
//                 GoRoute(
//                   path: 'detail/:id',
//                   builder: (context, state) {
//                     final id = state.pathParameters['id']!;
//                     return MedicineDetailScreen(medicineId: id);
//                   },
//                 ),
//               ],
//             ),
//             GoRoute(
//               path: healthRecords,
//               builder: (_, __) => const HealthRecordsScreen(),
//             ),
//             GoRoute(
//               path: aiAssistant,
//               builder: (_, __) => const AIAssistantScreen(),
//             ),
//             GoRoute(
//               path: profile,
//               builder: (_, __) => const ProfileScreen(),
//               routes: [
//                 GoRoute(
//                   path: 'settings',
//                   builder: (_, __) => const SettingsScreen(),
//                 ),
//               ],
//             ),
//           ],
//         ),

//         // ── Full Screen — No Bottom Nav ──
//         GoRoute(path: doctors, builder: (_, __) => const DoctorsScreen()),
//         GoRoute(path: analytics, builder: (_, __) => const AnalyticsScreen()),
//         GoRoute(path: emergency, builder: (_, __) => const EmergencyScreen()),
//         GoRoute(
//           path: notifications,
//           builder: (_, __) => const NotificationsScreen(),
//         ),
//         GoRoute(
//           path: addMedicine,
//           builder: (context, state) {
//             final memberId = state.uri.queryParameters['memberId'];
//             return AddMedicineScreen(memberId: memberId);
//           },
//         ),
//         GoRoute(
//           path: healthInsurance, // NEW
//           builder: (_, __) => const HealthInsuranceScreen(),
//         ),

//         // // ── Family — commented out ──
//         // GoRoute(path: family, builder: (_, __) => const FamilyScreen()),
//         // GoRoute(path: '/family/detail/:id', ...),
//         // GoRoute(path: '/family/add', ...),
//         // GoRoute(path: '/family/edit/:id', ...),
//       ],
//     );
//   }
// }

import 'package:go_router/go_router.dart';
import 'package:meditrack/views/auth/Forgotpassword_screen.dart';
import 'package:meditrack/views/notification/notification_screen.dart';
import 'package:meditrack/views/health_insurance/health_insurance_screen.dart';
import 'package:meditrack/views/profile/Editprofile.dart';
import '../providers/auth_provider.dart';
import '../views/splash/splash_screen.dart';
import '../views/onboarding/onboarding_screen.dart';
import '../views/auth/login_screen.dart';
import '../views/auth/register_screen.dart';
import '../views/dashboard/dashboard_screen.dart';
import '../views/medicines/medicine_list_screen.dart';
import '../views/medicines/medicine_detail_screen.dart';
import '../views/medicines/add_medicine_screen.dart';
import '../views/doctors/doctors_screen.dart';
import '../views/health_records/health_records_screen.dart';
import '../views/ai_assistant/ai_assistant_screen.dart';
import '../views/family/family_screen.dart';
import '../views/family/family_member_detail_screen.dart';
import '../views/family/add_edit_family_member_screen.dart';
import '../views/analytics/analytics_screen.dart';
import '../views/emergency/emergency_screen.dart';
import '../views/profile/profile_screen.dart';
import '../views/settings/settings_screen.dart';
import '../widgets/common/bottom_nav_bar.dart';

class AppRoutes {
  static const String splash = '/';
  static const String onboarding = '/onboarding';
  static const String login = '/login';
  static const String register = '/register';
  static const String dashboard = '/dashboard';
  static const String medicines = '/medicines';
  static const String medicineDetail = '/medicines/detail/:id';
  static const String addMedicine = '/medicines/add';
  static const String healthRecords = '/health-records';
  static const String aiAssistant = '/ai-assistant';
  static const String profile = '/profile';
  static const String settings = '/profile/settings';
  static const String editProfile = '/profile/edit';
  static const String doctors = '/doctors';
  static const String family = '/family';
  static const String familyMemberDetail = '/family/detail/:id';
  static const String addFamilyMember = '/family/add';
  static const String editFamilyMember = '/family/edit/:id';
  static const String analytics = '/analytics';
  static const String emergency = '/emergency';
  static const String notifications = '/notifications';
  static const String healthInsurance = '/health-insurance';
  static const String forgotPassword = '/forgot-password';

  static GoRouter router(AuthProvider authProvider) {
    return GoRouter(
      initialLocation: splash,
      debugLogDiagnostics: false,
      routes: [
        GoRoute(path: splash, builder: (_, __) => const SplashScreen()),
        GoRoute(path: onboarding, builder: (_, __) => const OnboardingScreen()),
        GoRoute(path: login, builder: (_, __) => const LoginScreen()),
        GoRoute(path: register, builder: (_, __) => const RegisterScreen()),
        GoRoute(
          path: forgotPassword,
          builder: (_, __) => const ForgotPasswordScreen(),
        ),

        // ── Bottom Nav Shell ──
        ShellRoute(
          builder: (context, state, child) => BottomNavBar(child: child),
          routes: [
            GoRoute(
              path: dashboard,
              builder: (_, __) => const DashboardScreen(),
            ),
            GoRoute(
              path: medicines,
              builder: (_, __) => const MedicineListScreen(),
              routes: [
                GoRoute(
                  path: 'detail/:id',
                  builder: (context, state) {
                    final id = state.pathParameters['id']!;
                    return MedicineDetailScreen(medicineId: id);
                  },
                ),
              ],
            ),
            GoRoute(
              path: healthRecords,
              builder: (_, __) => const HealthRecordsScreen(),
            ),
            GoRoute(
              path: aiAssistant,
              builder: (_, __) => const AIAssistantScreen(),
            ),
            GoRoute(
              path: profile,
              builder: (_, __) => const ProfileScreen(),
              routes: [
                GoRoute(
                  path: 'settings',
                  builder: (_, __) => const SettingsScreen(),
                ),
                GoRoute(
                  path: 'edit',
                  builder: (_, __) => const EditProfileScreen(),
                ),
              ],
            ),
          ],
        ),

        // ── Full Screen — No Bottom Nav ──
        GoRoute(path: doctors, builder: (_, __) => const DoctorsScreen()),
        GoRoute(path: analytics, builder: (_, __) => const AnalyticsScreen()),
        GoRoute(path: emergency, builder: (_, __) => const EmergencyScreen()),
        GoRoute(
          path: notifications,
          builder: (_, __) => const NotificationsScreen(),
        ),
        GoRoute(
          path: addMedicine,
          builder: (context, state) {
            final memberId = state.uri.queryParameters['memberId'];
            return AddMedicineScreen(memberId: memberId);
          },
        ),
        GoRoute(
          path: healthInsurance,
          builder: (_, __) => const HealthInsuranceScreen(),
        ),

        // // ── Family — commented out ──
        // GoRoute(path: family, builder: (_, __) => const FamilyScreen()),
        // GoRoute(path: '/family/detail/:id', ...),
        // GoRoute(path: '/family/add', ...),
        // GoRoute(path: '/family/edit/:id', ...),
      ],
    );
  }
}

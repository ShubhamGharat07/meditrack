import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:meditrack/firebase_options.dart';
import 'package:meditrack/providers/health_insurance_provider.dart';
import 'package:provider/provider.dart';
import 'providers/auth_provider.dart';
import 'providers/medicine_provider.dart';
import 'providers/doctor_provider.dart';
import 'providers/health_record_provider.dart';
import 'providers/family_provider.dart';
import 'providers/ai_provider.dart';
import 'providers/theme_provider.dart';
import 'core/constants/app_colors.dart';
import 'routes/app_routes.dart';
import 'services/notification/notification_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
  await dotenv.load(fileName: '.env');
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await NotificationService().initialize();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => MedicineProvider()),
        ChangeNotifierProvider(create: (_) => DoctorProvider()),
        ChangeNotifierProvider(create: (_) => HealthRecordProvider()),
        ChangeNotifierProvider(create: (_) => FamilyProvider()),
        ChangeNotifierProvider(create: (_) => AIProvider()),
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => HealthInsuranceProvider()),
      ],
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final _router;

  @override
  void initState() {
    super.initState();
    final authProvider = context.read<AuthProvider>();
    _router = AppRoutes.router(authProvider);
    Future.microtask(() => context.read<ThemeProvider>().loadTheme());
  }

  @override
  Widget build(BuildContext context) {
    final themeProvider = context.watch<ThemeProvider>();

    return MaterialApp.router(
      title: 'MediTrack',
      debugShowCheckedModeBanner: false,
      themeMode: themeProvider.themeMode,
      theme: _buildTheme(Brightness.light),
      darkTheme: _buildTheme(Brightness.dark),
      routerConfig: _router,
    );
  }
}

ThemeData _buildTheme(Brightness brightness) {
  final isDark = brightness == Brightness.dark;

  final bgColor = isDark ? const Color(0xFF121212) : const Color(0xFFF5F7FA);
  final surfaceColor = isDark
      ? const Color(0xFF1E1E2E)
      : const Color(0xFFFFFFFF);
  final onSurface = isDark ? const Color(0xFFE8E8F0) : const Color(0xFF212121);
  final onSurfaceVar = isDark
      ? const Color(0xFF9E9EAA)
      : const Color(0xFF757575);
  final outlineColor = isDark
      ? const Color(0xFF3A3A4E)
      : const Color(0xFFE0E0E0);

  final colorScheme = ColorScheme(
    brightness: brightness,
    primary: AppColors.primary,
    onPrimary: Colors.white,
    primaryContainer: isDark
        ? const Color(0xFF1A3A6E)
        : const Color(0xFFD6E4FF),
    onPrimaryContainer: isDark
        ? const Color(0xFFB8D0FF)
        : const Color(0xFF0D3B8E),
    secondary: AppColors.secondary,
    onSecondary: Colors.white,
    secondaryContainer: isDark
        ? const Color(0xFF004D5A)
        : const Color(0xFFCDF7FF),
    onSecondaryContainer: isDark
        ? const Color(0xFF9EEEFF)
        : const Color(0xFF00363F),
    surface: surfaceColor,
    onSurface: onSurface,
    surfaceVariant: isDark ? const Color(0xFF252535) : const Color(0xFFF0F4FF),
    onSurfaceVariant: onSurfaceVar,
    outline: outlineColor,
    outlineVariant: isDark ? const Color(0xFF2C2C3E) : const Color(0xFFEEEEEE),
    error: AppColors.error,
    onError: Colors.white,
    errorContainer: isDark ? const Color(0xFF8B1A1A) : const Color(0xFFFFDAD6),
    onErrorContainer: isDark
        ? const Color(0xFFFFDAD6)
        : const Color(0xFF8B1A1A),
    shadow: Colors.black,
    scrim: Colors.black,
    inverseSurface: isDark ? const Color(0xFFE8E8F0) : const Color(0xFF1E1E2E),
    onInverseSurface: isDark
        ? const Color(0xFF1E1E2E)
        : const Color(0xFFE8E8F0),
    inversePrimary: isDark ? const Color(0xFF9EBFFF) : const Color(0xFF1565C0),
  );

  return ThemeData(
    useMaterial3: true,
    brightness: brightness,
    colorScheme: colorScheme,
    scaffoldBackgroundColor: bgColor,
    cardTheme: CardThemeData(
      color: surfaceColor,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(12),
        side: isDark
            ? BorderSide(color: outlineColor.withOpacity(0.5), width: 0.5)
            : BorderSide.none,
      ),
    ),
    appBarTheme: AppBarTheme(
      backgroundColor: surfaceColor,
      foregroundColor: onSurface,
      elevation: 0,
      scrolledUnderElevation: 0,
      systemOverlayStyle: isDark
          ? SystemUiOverlayStyle.light
          : SystemUiOverlayStyle.dark,
    ),
    navigationBarTheme: NavigationBarThemeData(
      backgroundColor: surfaceColor,
      indicatorColor: AppColors.primary.withOpacity(0.15),
      iconTheme: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return IconThemeData(color: AppColors.primary);
        }
        return IconThemeData(color: onSurfaceVar);
      }),
      labelTextStyle: MaterialStateProperty.resolveWith((states) {
        if (states.contains(MaterialState.selected)) {
          return TextStyle(
            color: AppColors.primary,
            fontSize: 12,
            fontWeight: FontWeight.w600,
          );
        }
        return TextStyle(color: onSurfaceVar, fontSize: 12);
      }),
    ),
    inputDecorationTheme: InputDecorationTheme(
      labelStyle: TextStyle(color: onSurfaceVar, fontSize: 14),
      hintStyle: TextStyle(color: onSurfaceVar.withOpacity(0.6), fontSize: 12),
      floatingLabelStyle: const TextStyle(
        color: AppColors.primary,
        fontSize: 12,
      ),
    ),
    dialogTheme: DialogThemeData(
      backgroundColor: surfaceColor,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
    ),
    bottomSheetTheme: BottomSheetThemeData(
      backgroundColor: surfaceColor,
      modalBackgroundColor: surfaceColor,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
    ),
    dividerTheme: DividerThemeData(
      color: outlineColor,
      thickness: 0.5,
      space: 1,
    ),
    chipTheme: ChipThemeData(
      backgroundColor: isDark
          ? const Color(0xFF252535)
          : const Color(0xFFF0F4FF),
      labelStyle: TextStyle(color: onSurface),
      side: BorderSide(color: outlineColor.withOpacity(0.5), width: 0.5),
    ),
    iconTheme: IconThemeData(color: onSurfaceVar),
    floatingActionButtonTheme: const FloatingActionButtonThemeData(
      backgroundColor: AppColors.primary,
      foregroundColor: Colors.white,
    ),
    snackBarTheme: SnackBarThemeData(
      backgroundColor: isDark
          ? const Color(0xFF2C2C3E)
          : const Color(0xFF323232),
      contentTextStyle: const TextStyle(color: Colors.white),
      behavior: SnackBarBehavior.floating,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    ),
    switchTheme: SwitchThemeData(
      thumbColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected) ? AppColors.primary : null,
      ),
      trackColor: MaterialStateProperty.resolveWith(
        (s) => s.contains(MaterialState.selected)
            ? AppColors.primary.withOpacity(0.4)
            : null,
      ),
    ),
    progressIndicatorTheme: const ProgressIndicatorThemeData(
      color: AppColors.primary,
    ),
  );
}

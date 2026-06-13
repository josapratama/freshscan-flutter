import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:provider/provider.dart';
import 'core/constants/app_theme.dart';
import 'data/services/auth_service.dart';
import 'data/services/firestore_history_service.dart';
import 'presentation/pages/splash_page.dart';
import 'presentation/pages/home_page.dart';
import 'presentation/pages/login_page.dart';
import 'presentation/pages/scan_page.dart';
import 'presentation/pages/result_page.dart';
import 'presentation/pages/history_page.dart';
import 'data/models/scan_result_model.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load environment variables dari assets/.env
  await dotenv.load(fileName: 'assets/.env');

  // Inisialisasi Firebase
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  // Kunci orientasi ke portrait only
  await SystemChrome.setPreferredOrientations([
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);

  // Atur status bar
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const FreshScanApp());
}

class FreshScanApp extends StatelessWidget {
  const FreshScanApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthService()),
        ChangeNotifierProvider(create: (_) => FirestoreHistoryService()),
      ],
      child: MaterialApp(
        title: 'FreshScan',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,

        // ── Route Awal: SplashPage yang akan handle auth check ───────────────
        home: const SplashPage(),

        // ── Named Routes ─────────────────────────────────────────────────────
        routes: {
          SplashPage.routeName: (_) => const SplashPage(),
          LoginPage.routeName: (_) => const LoginPage(),
          HomePage.routeName: (_) => const HomePage(),
          HistoryPage.routeName: (_) => const HistoryPage(),
        },

        // ── Route Generator ──────────────────────────────────────────────────
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case ScanPage.routeName:
              final imagePath = settings.arguments as String?;
              if (imagePath != null) {
                return MaterialPageRoute(
                  builder: (_) => ScanPage(imagePath: imagePath),
                );
              }
              return _errorRoute('ScanPage membutuhkan imagePath');

            case ResultPage.routeName:
              final scanResult = settings.arguments as ScanResultModel?;
              if (scanResult != null) {
                return MaterialPageRoute(
                  builder: (_) => ResultPage(scanResult: scanResult),
                );
              }
              return _errorRoute('ResultPage membutuhkan ScanResultModel');

            default:
              return _errorRoute('Halaman tidak ditemukan: ${settings.name}');
          }
        },
      ),
    );
  }

  static Route<dynamic> _errorRoute(String message) {
    return MaterialPageRoute(
      builder: (_) => Scaffold(
        appBar: AppBar(title: const Text('Error')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.error_outline, size: 64, color: Colors.red),
                const SizedBox(height: 16),
                Text(message,
                    textAlign: TextAlign.center,
                    style: const TextStyle(fontSize: 16)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

/// Widget yang memutuskan route berdasarkan status auth
/// Digunakan oleh SplashPage setelah loading selesai
class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }
        if (snapshot.hasData && snapshot.data != null) {
          return const HomePage();
        }
        return const LoginPage();
      },
    );
  }
}

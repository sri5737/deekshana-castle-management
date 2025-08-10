import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'registration/screens/admin_login_screen.dart';
import 'registration/screens/hosteler_list_screen.dart';
import 'registration/providers/hosteler_provider.dart';
import 'registration/providers/auth_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => HostelerProvider()..loadHostelers()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
      ],
      child: MaterialApp(
        title: 'Deekshana Castle Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(
            seedColor: const Color(0xFF00D09C),
            primary: const Color(0xFF00D09C),
          ),
          textTheme: GoogleFonts.poppinsTextTheme().copyWith(
            displayLarge: GoogleFonts.poppins(fontSize: 48, fontWeight: FontWeight.w700, letterSpacing: -0.5),
            displayMedium: GoogleFonts.poppins(fontSize: 40, fontWeight: FontWeight.w700, letterSpacing: -0.25),
            headlineLarge: GoogleFonts.poppins(fontSize: 32, fontWeight: FontWeight.w700),
            headlineMedium: GoogleFonts.poppins(fontSize: 28, fontWeight: FontWeight.w600),
            titleLarge: GoogleFonts.poppins(fontSize: 22, fontWeight: FontWeight.w600),
            titleMedium: GoogleFonts.poppins(fontSize: 18, fontWeight: FontWeight.w600),
            bodyLarge: GoogleFonts.inter(fontSize: 16, fontWeight: FontWeight.w500, height: 1.4),
            bodyMedium: GoogleFonts.inter(fontSize: 14, fontWeight: FontWeight.w400, height: 1.5),
            labelLarge: GoogleFonts.poppins(fontSize: 16, fontWeight: FontWeight.w600),
          ),
          appBarTheme: const AppBarTheme(
            backgroundColor: Colors.transparent,
            foregroundColor: Colors.white,
            elevation: 0,
          ),
          inputDecorationTheme: InputDecorationTheme(
            filled: true,
            fillColor: const Color(0xFFF5F7F9),
            isDense: true,
            floatingLabelBehavior: FloatingLabelBehavior.never,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: BorderSide.none,
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(14),
              borderSide: const BorderSide(color: Color(0xFF00D09C), width: 1.5),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
          elevatedButtonTheme: ElevatedButtonThemeData(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF00D09C),
              foregroundColor: Colors.white,
              textStyle: GoogleFonts.poppins(
                fontSize: 14,
                fontWeight: FontWeight.w600,
                letterSpacing: 0.3,
              ),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
              elevation: 0,
              shadowColor: Colors.transparent,
              overlayColor: const Color(0xFF00B386).withValues(alpha: 0.08),
            ),
          ),
        ),
        debugShowCheckedModeBanner: false,
        initialRoute: '/',
        onGenerateRoute: (settings) {
          switch (settings.name) {
            case '/':
              return MaterialPageRoute(
                builder: (ctx) => Consumer<AuthProvider>(
                  builder: (ctx, auth, _) => AdminLoginScreen(
                    onLogin: (username) {
                      auth.login(username);
                      Navigator.pushReplacementNamed(ctx, '/hostelerList');
                    },
                  ),
                ),
              );
            case '/hostelerList':
              return MaterialPageRoute(
                builder: (ctx) => Consumer<AuthProvider>(
                  builder: (ctx, auth, _) {
                    if (!auth.isLoggedIn) {
                      return AdminLoginScreen(
                        onLogin: (username) {
                          auth.login(username);
                          Navigator.pushReplacementNamed(ctx, '/hostelerList');
                        },
                      );
                    }
                    final username = auth.username ?? '';
                    return HostelerListScreen(username: username);
                  },
                ),
              );
            default:
              return MaterialPageRoute(
                builder: (ctx) => Consumer<AuthProvider>(
                  builder: (ctx, auth, _) => AdminLoginScreen(
                    onLogin: (username) {
                      auth.login(username);
                      Navigator.pushReplacementNamed(ctx, '/hostelerList');
                    },
                  ),
                ),
              );
          }
        },
      ),
    );
  }
}
// ...removed default counter app code...

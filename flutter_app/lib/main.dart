import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'registration/admin_login_screen.dart';
import 'registration/hosteler_list_screen.dart';
import 'registration/hosteler_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Hive.initFlutter();
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => HostelerProvider()..loadHostelers(),
      child: MaterialApp(
        title: 'Deekshana Castle Management',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        ),
        initialRoute: '/',
        routes: {
          '/': (context) => const AdminLoginScreen(),
          '/hostelerList': (context) => const HostelerListScreen(),
        },
      ),
    );
  }
}
// ...removed default counter app code...

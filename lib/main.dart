import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:qr_reader/pages/home_page.dart';
import 'package:qr_reader/pages/login_page.dart';
import 'package:qr_reader/pages/mapa_page.dart';
import 'package:qr_reader/providers/scan_list_provider.dart';
import 'package:qr_reader/providers/ui_provider.dart';
import 'package:qr_reader/providers/user_provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://rqapmdhpavutdcthewdg.supabase.co',
    anonKey: 'sb_publishable_ei5mFE6UV2vUUPgs64B8Ig_d05yAKcE',
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => UiProvider()),
        ChangeNotifierProvider(create: (_) => UserProvider()),
        ChangeNotifierProxyProvider<UserProvider, ScanListProvider>(
          create: (_) =>
              ScanListProvider(UserProvider()), // valor inicial temporal
          update: (_, userProvider, previous) {
            return ScanListProvider(userProvider);
          },
        ),
      ],

      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'QR Reader',

        initialRoute: 'login',

        routes: {
          'login': (_) => LoginPage(),
          'home': (_) => HomePage(),
          'mapa': (_) => MapaPage(),
        },
        theme: ThemeData(
          primaryColor: Colors.deepPurple,
          floatingActionButtonTheme: FloatingActionButtonThemeData(
            backgroundColor: Colors.deepPurple,
          ),
        ),
      ),
    );
  }
}

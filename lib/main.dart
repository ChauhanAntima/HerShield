import 'dart:async';

import 'package:app_links/app_links.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';

import 'auth_wrapper.dart';
import 'child/forgot_password_screen.dart';

const Color _brandPrimary = Color(0xFF573A63);
const Color _brandSecondary = Color(0xFF367C78);
const Color _brandBackground = Color(0xFFF7F4F1);
const Color _brandSurface = Color(0xFFFFFDFC);

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp();
    runApp(MyApp(appLinks: AppLinks()));
  } catch (error) {
    runApp(FirebaseStartupErrorApp(error: error));
  }
}

class MyApp extends StatefulWidget {
  const MyApp({required this.appLinks, super.key});

  final AppLinks appLinks;
  static final navigatorKey = GlobalKey<NavigatorState>();

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  StreamSubscription<Uri>? _linkSubscription;
  String? _lastHandledCode;

  @override
  void initState() {
    super.initState();
    _linkSubscription = widget.appLinks.uriLinkStream.listen(_handleLink);
    unawaited(_readInitialLink());
  }

  Future<void> _readInitialLink() async {
    try {
      final initialLink = await widget.appLinks.getInitialLink();
      if (initialLink != null) _handleLink(initialLink);
    } catch (_) {
      // Ignore malformed or unavailable launch links.
    }
  }

  void _handleLink(Uri incomingUri) {
    var actionUri = incomingUri;
    final nestedLink = incomingUri.queryParameters['link'];
    if (nestedLink != null) actionUri = Uri.tryParse(nestedLink) ?? incomingUri;

    if (actionUri.queryParameters['mode'] != 'resetPassword') return;
    final code = actionUri.queryParameters['oobCode'];
    if (code == null || code.isEmpty || code == _lastHandledCode) return;
    _lastHandledCode = code;

    void openResetPage() {
      MyApp.navigatorKey.currentState?.push(
        MaterialPageRoute<void>(
          builder: (_) => ForgotPasswordScreen(oobCode: code),
        ),
      );
    }

    if (MyApp.navigatorKey.currentState == null) {
      WidgetsBinding.instance.addPostFrameCallback((_) => openResetPage());
    } else {
      openResetPage();
    }
  }

  @override
  void dispose() {
    _linkSubscription?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      navigatorKey: MyApp.navigatorKey,
      debugShowCheckedModeBanner: false,
      title: 'HerShield',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: _brandPrimary,
          brightness: Brightness.light,
          surface: _brandSurface,
        ).copyWith(
          primary: _brandPrimary,
          secondary: _brandSecondary,
          surface: _brandSurface,
          error: const Color(0xFFB8404A),
        ),
        scaffoldBackgroundColor: _brandBackground,
        primaryColor: _brandPrimary,
        appBarTheme: const AppBarTheme(
          backgroundColor: _brandPrimary,
          foregroundColor: Colors.white,
          elevation: 0,
          centerTitle: false,
          titleTextStyle: TextStyle(
            color: Colors.white,
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        cardTheme: CardThemeData(
          color: _brandSurface,
          elevation: 1,
          margin: EdgeInsets.zero,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
            side: const BorderSide(color: Color(0xFFECE5E9)),
          ),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: _brandSurface,
          contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9D0D8)),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: Color(0xFFD9D0D8)),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(16),
            borderSide: const BorderSide(color: _brandPrimary, width: 1.6),
          ),
          labelStyle: const TextStyle(color: Color(0xFF746B75)),
          hintStyle: const TextStyle(color: Color(0xFF938B94)),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            backgroundColor: _brandPrimary,
            foregroundColor: Colors.white,
            textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
          ),
        ),
        textButtonTheme: TextButtonThemeData(
          style: TextButton.styleFrom(foregroundColor: _brandPrimary),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: _brandSecondary,
          foregroundColor: Colors.white,
        ),
        progressIndicatorTheme: const ProgressIndicatorThemeData(color: _brandSecondary),
        bottomAppBarTheme: const BottomAppBarThemeData(
          color: _brandSurface,
          elevation: 8,
        ),
        bottomNavigationBarTheme: const BottomNavigationBarThemeData(
          backgroundColor: _brandSurface,
          selectedItemColor: _brandPrimary,
          unselectedItemColor: Color(0xFF938B94),
          type: BottomNavigationBarType.fixed,
          elevation: 8,
        ),
        snackBarTheme: const SnackBarThemeData(
          behavior: SnackBarBehavior.floating,
          backgroundColor: Color(0xFF342D37),
          contentTextStyle: TextStyle(color: Colors.white),
        ),
        useMaterial3: true,
      ),
      home: const AuthWrapper(),
    );
  }
}

class FirebaseStartupErrorApp extends StatelessWidget {
  const FirebaseStartupErrorApp({required this.error, super.key});

  final Object error;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'HerShield',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: _brandPrimary),
        scaffoldBackgroundColor: _brandBackground,
        useMaterial3: true,
      ),
      home: Scaffold(
        body: Center(
          child: Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              'The app could not connect to its services. Check your setup and try again.\n$error',
              textAlign: TextAlign.center,
            ),
          ),
        ),
      ),
    );
  }
}

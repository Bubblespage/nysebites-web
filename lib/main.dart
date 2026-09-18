import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'data/mock_products.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_login_screen.dart';

import 'screens/splash_screen.dart';
import 'screens/auth/reset_password_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Explicitly enforce Local Persistence so logins survive browser refreshes
  if (kIsWeb) {
    try {
      await FirebaseAuth.instance.setPersistence(Persistence.LOCAL);
    } catch (e) {
      debugPrint('Warning: Could not set local persistence (likely in-app browser). $e');
    }
  }

  // Prevent mobile browsers from locking into stale IndexedDB cache
  if (kIsWeb) {
    try {
      FirebaseFirestore.instance.settings = const Settings(
        persistenceEnabled: false,
        sslEnabled: true,
      );
    } catch (e) {
      debugPrint('Warning: Could not configure Firestore settings. $e');
    }
  }

  // Render UI first without blocking
  runApp(const NyseBitesApp());

  // Run auto-seed asynchronously in the background
  _seedMissingFirestoreProducts();
}

Future<void> _seedMissingFirestoreProducts() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final batch = firestore.batch();
    bool hasUpdates = false;

    for (final product in mockProducts) {
      final docRef = firestore.collection('products').doc('sku_${product.id}');
      final docSnap = await docRef.get();

      if (!docSnap.exists) {
        batch.set(docRef, {
          'id': 'sku_${product.id}',
          'order': product.order,
          'name': product.name,
          'category': product.category,
          'price': product.price,
          'priceBox6': product.priceBox6,
          'servingSize': product.servingSize,
          'description': product.description,
          'imgSrc': product.imgSrc,
          'icon': product.icon,
          'stock': product.category == 'cakes' ? 5 : 24,
          'active': true,
          'createdAt': FieldValue.serverTimestamp(),
        });
        hasUpdates = true;
      }
    }

    if (hasUpdates) {
      await batch.commit();
      debugPrint('Firestore auto-seed: Missing products added.');
    }
  } catch (e) {
    debugPrint('Firestore auto-seed error: $e');
  }
}

class NyseBitesApp extends StatelessWidget {
  const NyseBitesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Nyse Bites | Cookie & Cake Company',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xFFFDF9F3),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF3C2216),
          primary: const Color(0xFF3C2216),
          secondary: const Color(0xFF8E4A23),
          surface: const Color(0xFFFFFFFF),
        ),
        fontFamily: 'sans-serif',
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const HomeScreen(),
        '/admin': (context) => const AdminLoginScreen(),
      },
      onGenerateRoute: (settings) {
        // Handle deep linking for Firebase Auth action URLs
        final uri = Uri.parse(settings.name ?? '');
        if (uri.path == '/reset-password') {
          // Firebase appends query parameters like ?mode=resetPassword&oobCode=XYZ
          final oobCode = uri.queryParameters['oobCode'];
          if (oobCode != null) {
            return MaterialPageRoute(
              builder: (context) => ResetPasswordScreen(oobCode: oobCode),
            );
          }
        }
        return null;
      },
    );
  }
}
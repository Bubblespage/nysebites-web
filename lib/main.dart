import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firebase_options.dart';
import 'data/mock_products.dart';
import 'screens/home_screen.dart';
import 'screens/admin/admin_login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  // Render UI first without blocking
  runApp(const NyseBitesApp());

  // Run auto-seed asynchronously in the background
  _seedFirestoreProductsIfEmpty();
}

Future<void> _seedFirestoreProductsIfEmpty() async {
  try {
    final firestore = FirebaseFirestore.instance;
    final snapshot = await firestore.collection('products').limit(1).get();

    if (snapshot.docs.isEmpty) {
      final batch = firestore.batch();

      for (final product in mockProducts) {
        final docRef = firestore
            .collection('products')
            .doc('sku_${product.id}');

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
      }

      await batch.commit();
      debugPrint('Firestore auto-seed completed.');
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
        '/': (context) => const HomeScreen(),
        '/admin': (context) => const AdminLoginScreen(),
      },
    );
  }
}

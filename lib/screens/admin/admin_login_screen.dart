import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:ui';
import 'admin_dashboard_screen.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  // Premium Palette
  static const Color primaryDark = Color(0xFF111827); // Rich dark text
  static const Color brandCocoa = Color(0xFF3E2723); // Deep Espresso
  static const Color textMuted = Color(0xFF6B7280); // Gray muted text
  static const Color borderLight = Color(0xFFE5E7EB); // Soft gray border
  static const Color cardBg = Color(0xFFFAFAFA); // Crisp off-white

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();

  bool _obscure = true;
  bool _isLoading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    setState(() {
      _errorMessage = null;
      _isLoading = true;
    });

    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Please enter your email and passcode.';
      });
      return;
    }

    try {
      final UserCredential credential = await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      final String uid = credential.user!.uid;

      final DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .get();

      if (!userDoc.exists) {
        throw FirebaseAuthException(
          code: 'user-not-found',
          message: 'No staff account profile found in Firestore.',
        );
      }

      final data = userDoc.data() as Map<String, dynamic>;
      final String rawRole = (data['role'] ?? '').toString();

      String resolvedRole = 'Baker Admin';
      if (rawRole == 'super_admin' || rawRole == 'Super Admin') {
        resolvedRole = 'Super Admin';
      } else if (rawRole == 'order_dispatcher' || rawRole == 'rider') {
        resolvedRole = 'Order Dispatcher';
      }

      if (!mounted) return;
      setState(() => _isLoading = false);

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => AdminDashboardScreen(
            currentRole: resolvedRole,
            adminEmail: email,
          ),
        ),
      );
    } on FirebaseAuthException catch (e) {
      setState(() {
        _isLoading = false;
        if (e.code == 'user-not-found' ||
            e.code == 'invalid-credential' ||
            e.code == 'wrong-password') {
          _errorMessage =
              'Invalid staff credentials. Please check your passcode.';
        } else if (e.code == 'user-disabled') {
          _errorMessage = 'This staff account has been deactivated.';
        } else {
          _errorMessage = e.message ?? 'Authentication failed.';
        }
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
        _errorMessage = 'Error signing in. Please check your connection.';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final double screenWidth = mediaQuery.size.width;
    final bool isDesktop = screenWidth >= 900;
    final bool isSmallMobile = screenWidth < 400;

    return Scaffold(
      backgroundColor: cardBg,
      body: Row(
        children: [
          // Left Side: The Image Banner (Only visible on Desktop/Tablet)
          if (isDesktop)
            Expanded(
              flex: 5,
              child: Container(
                decoration: const BoxDecoration(
                  color: brandCocoa,
                  image: DecorationImage(
                    image: AssetImage('assets/images/premium_baked_goods.jpg'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Container(
                  // Dark overlay for contrast
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withOpacity(0.3),
                        Colors.black.withOpacity(0.7),
                      ],
                    ),
                  ),
                  padding: const EdgeInsets.all(60),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'Premium, Handcrafted\nBaked Goods.',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 42,
                          fontWeight: FontWeight.w900,
                          height: 1.1,
                          letterSpacing: -1,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'Welcome to the Nyse Bites internal management portal.\nAuthenticate to access live orders, custom cake reviews, and bakery stock.',
                        style: TextStyle(
                          color: Colors.white.withOpacity(0.85),
                          fontSize: 16,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

          // Right Side: The Clean Login Form
          Expanded(
            flex: 6,
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  stops: [0.0, 0.25, 0.55, 0.85, 1.0],
                  colors: [
                    Color(0xFFFAF2E9),
                    Color(0xFFFBF6F0),
                    Color(0xFFF8EFE4),
                    Color(0xFFF5E9DB),
                    Color(0xFFEFE2D2),
                  ],
                ),
              ),
              child: Stack(
                children: [
                // Mobile Background Image (Optional, if we want to show it on mobile)
                if (!isDesktop)
                  Positioned.fill(
                    child: Container(
                      decoration: const BoxDecoration(
                        color: brandCocoa,
                        image: DecorationImage(
                          image: AssetImage(
                            'assets/images/premium_baked_goods.jpg',
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                      child: Container(
                        color: Colors.black.withOpacity(
                          0.65,
                        ), // Heavy dark overlay for mobile text contrast
                      ),
                    ),
                  ),

                // Form Container
                Center(
                  child: SingleChildScrollView(
                    padding: EdgeInsets.symmetric(
                      horizontal: isSmallMobile ? 24 : (isDesktop ? 60 : 40),
                      vertical: 40,
                    ),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 420),
                      child: Container(
                        // On mobile, give it a glass effect card to pop off the background image. On desktop, it's just part of the clean background.
                        decoration: isDesktop
                            ? null
                            : BoxDecoration(
                                color: Colors.white.withOpacity(0.92),
                                borderRadius: BorderRadius.circular(24),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black.withOpacity(0.2),
                                    blurRadius: 40,
                                    offset: const Offset(0, 10),
                                  ),
                                ],
                              ),
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(
                            isDesktop ? 0 : 24,
                          ),
                          child: BackdropFilter(
                            filter: isDesktop
                                ? ImageFilter.blur(sigmaX: 0, sigmaY: 0)
                                : ImageFilter.blur(sigmaX: 10, sigmaY: 10),
                            child: Padding(
                              padding: EdgeInsets.all(
                                isDesktop ? 0 : (isSmallMobile ? 24 : 32),
                              ),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  // Brand Header
                                  Row(
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      Container(
                                        width: isSmallMobile ? 42 : 48,
                                        height: isSmallMobile ? 42 : 48,
                                        padding: const EdgeInsets.all(3),
                                        decoration: BoxDecoration(
                                          color: const Color(0xFFF8F0E5),
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: const Color(0xFFEADCCF),
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(8),
                                          child: Image.asset(
                                            'assets/images/logo.jpg',
                                            fit: BoxFit.contain,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 12),
                                      Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            'NYSE BITES.',
                                            style: TextStyle(
                                              fontFamily: 'sans-serif',
                                              fontSize: isSmallMobile ? 24 : 28,
                                              fontWeight: FontWeight.w900,
                                              letterSpacing: -0.5,
                                              height: 1.0,
                                              color: brandCocoa,
                                            ),
                                          ),
                                          const SizedBox(height: 4),
                                          Text(
                                            'STAFF PORTAL',
                                            style: TextStyle(
                                              fontFamily: 'sans-serif',
                                              fontSize: 10,
                                              fontWeight: FontWeight.w700,
                                              color: textMuted,
                                              letterSpacing: 2.0,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 48),

                                  // Email Input
                                  const Text(
                                    'Email Address',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark,
                                    ),
                                  ),
                                  TextField(
                                    controller: _emailController,
                                    keyboardType: TextInputType.emailAddress,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: primaryDark,
                                    ),
                                    decoration: InputDecoration(
                                      hintText: 'name@nysebites.com',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: textMuted.withOpacity(0.6),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: brandCocoa,
                                          width: 2,
                                        ),
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 28),

                                  // Passcode Input
                                  const Text(
                                    'Passcode',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w700,
                                      color: primaryDark,
                                    ),
                                  ),
                                  TextField(
                                    controller: _passwordController,
                                    obscureText: _obscure,
                                    style: const TextStyle(
                                      fontSize: 15,
                                      color: primaryDark,
                                    ),
                                    onSubmitted: (_) => _handleLogin(),
                                    decoration: InputDecoration(
                                      hintText: 'Enter your passcode',
                                      hintStyle: TextStyle(
                                        fontSize: 14,
                                        color: textMuted.withOpacity(0.6),
                                      ),
                                      contentPadding:
                                          const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                      enabledBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: borderLight,
                                          width: 1.5,
                                        ),
                                      ),
                                      focusedBorder: const UnderlineInputBorder(
                                        borderSide: BorderSide(
                                          color: brandCocoa,
                                          width: 2,
                                        ),
                                      ),
                                      suffixIcon: IconButton(
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                          size: 18,
                                          color: textMuted,
                                        ),
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                      ),
                                    ),
                                  ),

                                  if (_errorMessage != null) ...[
                                    const SizedBox(height: 20),
                                    Container(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 16,
                                        vertical: 12,
                                      ),
                                      decoration: BoxDecoration(
                                        color: const Color(0xFFFEF2F2),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: const Color(0xFFFCA5A5),
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          const Icon(
                                            Icons.error_outline_rounded,
                                            size: 16,
                                            color: Color(0xFFDC2626),
                                          ),
                                          const SizedBox(width: 10),
                                          Expanded(
                                            child: Text(
                                              _errorMessage!,
                                              style: const TextStyle(
                                                color: Color(0xFFB91C1C),
                                                fontSize: 12.5,
                                                fontWeight: FontWeight.w600,
                                              ),
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],

                                  const SizedBox(height: 40),

                                  // Submit Button
                                  ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: brandCocoa,
                                      foregroundColor: Colors.white,
                                      elevation: 0,
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                    ),
                                    onPressed: _isLoading ? null : _handleLogin,
                                    child: _isLoading
                                        ? const SizedBox(
                                            width: 18,
                                            height: 18,
                                            child: CircularProgressIndicator(
                                              color: Colors.white,
                                              strokeWidth: 2,
                                            ),
                                          )
                                        : const Text(
                                            'Sign In',
                                            style: TextStyle(
                                              fontSize: 14.5,
                                              fontWeight: FontWeight.bold,
                                              letterSpacing: 0.5,
                                            ),
                                          ),
                                  ),

                                  const SizedBox(height: 24),

                                  // Return to Storefront
                                  Center(
                                    child: TextButton.icon(
                                      onPressed: () => Navigator.of(
                                        context,
                                      ).pushReplacementNamed('/'),
                                      icon: const Icon(
                                        Icons.arrow_back_rounded,
                                        size: 16,
                                        color: textMuted,
                                      ),
                                      label: const Text(
                                        'Return to Storefront',
                                        style: TextStyle(
                                          color: textMuted,
                                          fontSize: 13,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ),
          ),
        ],
      ),
    );
  }
}

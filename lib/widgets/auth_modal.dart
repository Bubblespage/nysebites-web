import 'dart:math';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthModal extends StatefulWidget {
  final Function(String userName) onLoginSuccess;

  const AuthModal({super.key, required this.onLoginSuccess});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal>
    with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  bool _isLoading = false;
  bool _keepLoggedIn = true;
  String? _authErrorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  late final AnimationController _floatController;

  bool get _hasMinLength => _passwordController.text.length >= 8;
  bool get _hasUppercase => _passwordController.text.contains(RegExp(r'[A-Z]'));
  bool get _hasLowercase => _passwordController.text.contains(RegExp(r'[a-z]'));
  bool get _hasNumber => _passwordController.text.contains(RegExp(r'[0-9]'));
  bool get _hasSpecialChar =>
      _passwordController.text.contains(RegExp(r'[!@#$%^&*(),.?":{}|<>]'));

  bool get _isPasswordValid =>
      _hasMinLength &&
      _hasUppercase &&
      _hasLowercase &&
      _hasNumber &&
      _hasSpecialChar;

  @override
  void initState() {
    super.initState();
    _passwordController.addListener(() {
      if (_isSignUp) setState(() {});
    });
    _floatController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 6),
    )..repeat();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _floatController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    ).hasMatch(email.trim());
  }

  Future<void> _handleSubmit() async {
    setState(() => _authErrorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    setState(() => _isLoading = true);

    try {
      if (_isSignUp) {
        if (!_isPasswordValid) {
          setState(() {
            _isLoading = false;
            _authErrorMessage =
                'Please fulfill all security criteria for your password.';
          });
          return;
        }

        final UserCredential cred = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(email: email, password: password);

        await cred.user?.updateDisplayName(name);

        await FirebaseFirestore.instance
            .collection('users')
            .doc(cred.user!.uid)
            .set({
          'name': name,
          'displayName': name,
          'email': email,
          'role': 'customer',
          'createdAt': FieldValue.serverTimestamp(),
        });

        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Welcome to Nyse Bites, $name! 🎉'),
            backgroundColor: const Color(0xFF8C4A27),
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );

        widget.onLoginSuccess(name);
        Navigator.pop(context);
      } else {
        final UserCredential cred = await FirebaseAuth.instance
            .signInWithEmailAndPassword(email: email, password: password);

        String resolvedName = cred.user?.displayName ?? '';

        if (resolvedName.isEmpty) {
          final doc = await FirebaseFirestore.instance
              .collection('users')
              .doc(cred.user!.uid)
              .get();

          if (doc.exists && doc.data() != null) {
            final data = doc.data()!;
            resolvedName = data['name'] ?? data['displayName'] ?? '';
          }
        }

        if (resolvedName.isEmpty) {
          resolvedName = email.split('@').first;
        }

        if (!mounted) return;
        widget.onLoginSuccess(resolvedName);
        Navigator.pop(context);
      }
    } on FirebaseAuthException catch (e) {
      setState(() {
        if (e.code == 'user-not-found' ||
            e.code == 'wrong-password' ||
            e.code == 'invalid-credential') {
          _authErrorMessage = 'Invalid email or password.';
        } else if (e.code == 'email-already-in-use') {
          _authErrorMessage =
              'An account with this email already exists. Please sign in.';
        } else if (e.code == 'weak-password') {
          _authErrorMessage = 'The password provided is too weak.';
        } else if (e.code == 'operation-not-allowed') {
          _authErrorMessage =
              'Email/Password sign-in is disabled in Firebase Console.';
        } else {
          _authErrorMessage = e.message ?? 'Authentication failed.';
        }
      });
    } catch (e) {
      setState(() => _authErrorMessage = 'An error occurred: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  void _handleGuestAccess() {
    widget.onLoginSuccess('Sweet Guest');
    Navigator.pop(context);
  }

  Widget _floatingIcon({
    required String emoji,
    required double phase,
    required double amplitude,
    required double fontSize,
    required double baseAngle,
  }) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value * 2 * pi;
        final dy = sin(t + phase) * amplitude;
        final wiggle = sin(t * 0.6 + phase) * 0.08;
        return Transform.translate(
          offset: Offset(0, dy),
          child: Transform.rotate(
            angle: baseAngle + wiggle,
            child: child,
          ),
        );
      },
      child: Text(emoji, style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget _twinkleSparkle({required double fontSize, required double phase}) {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value * 2 * pi;
        final pulse = 0.75 + 0.25 * sin(t * 1.4 + phase);
        return Opacity(
          opacity: pulse.clamp(0.5, 1.0),
          child: Transform.scale(scale: 0.9 + 0.1 * pulse, child: child),
        );
      },
      child: Text('✨', style: TextStyle(fontSize: fontSize)),
    );
  }

  Widget _breathingLogo() {
    return AnimatedBuilder(
      animation: _floatController,
      builder: (context, child) {
        final t = _floatController.value * 2 * pi;
        final scale = 1.0 + 0.04 * sin(t * 0.8);
        final glow = 0.15 + 0.1 * sin(t * 0.8);
        return Transform.scale(
          scale: scale,
          child: Container(
            width: 60,
            height: 60,
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white.withOpacity(0.3)),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFFE5B976).withOpacity(glow),
                  blurRadius: 20,
                  spreadRadius: 3,
                ),
              ],
            ),
            child: child,
          ),
        );
      },
      child: ClipRRect(
        borderRadius: BorderRadius.circular(28),
        child: Image.asset(
          'assets/images/logo.jpg',
          fit: BoxFit.cover,
          errorBuilder: (_, __, ___) => const Center(
            child: Text('🧁', style: TextStyle(fontSize: 26)),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementBadge(String label, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? const Color(0xFFEBF5EE) : Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isMet ? const Color(0xFF2E7D32) : const Color(0xFFEFE4D6),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.radio_button_unchecked,
            size: 11,
            color: isMet ? const Color(0xFF2E7D32) : const Color(0xFF7A6559),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isMet ? FontWeight.w700 : FontWeight.w500,
              color: isMet ? const Color(0xFF1B5E20) : const Color(0xFF7A6559),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCleanField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    bool showCheck = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    TextInputAction? textInputAction,
    void Function(String)? onFieldSubmitted,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 12.5,
              fontWeight: FontWeight.w800,
              color: Color(0xFF251811),
            ),
          ),
        ),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          textInputAction: textInputAction,
          onFieldSubmitted: onFieldSubmitted ?? 
              (textInputAction == TextInputAction.next 
                  ? (_) => FocusScope.of(context).nextFocus() 
                  : null),
          autovalidateMode: AutovalidateMode.onUserInteraction,
          validator: validator,
          onChanged: (_) => setState(() {}),
          style: const TextStyle(
            fontSize: 13.5,
            color: Color(0xFF251811),
            fontWeight: FontWeight.w600,
          ),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(
              fontSize: 13,
              color: Color(0xFFAAA09A),
              fontWeight: FontWeight.w400,
            ),
            prefixIcon: Icon(icon, color: const Color(0xFF8C4A27), size: 18),
            suffixIcon: suffixIcon ??
                (showCheck
                    ? const Padding(
                        padding: EdgeInsets.all(12),
                        child: Icon(
                          Icons.check_circle_rounded,
                          color: Color(0xFF2E7D32),
                          size: 18,
                        ),
                      )
                    : null),
            filled: true,
            fillColor: Colors.white,
            errorStyle: const TextStyle(
              fontSize: 11,
              height: 1.1,
              fontWeight: FontWeight.w600,
              color: Color(0xFFC62828),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 10,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEFE4D6), width: 1.2),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFEFE4D6), width: 1.2),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(
                color: Color(0xFF8C4A27),
                width: 1.8,
              ),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.2),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(16),
              borderSide: const BorderSide(color: Color(0xFFC62828), width: 1.8),
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 820),
        child: Container(
          decoration: BoxDecoration(
            color: const Color(0xFFFBF5ED),
            borderRadius: BorderRadius.circular(28),
            border: Border.all(color: const Color(0xFFEFE4D6), width: 1.5),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(37, 24, 17, 0.18),
                blurRadius: 40,
                offset: Offset(0, 16),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(28),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final isMobile = constraints.maxWidth < 650;

                // Left Brand Welcome Panel with smooth corner blobs matching reference
                final brandPanel = ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(28),
                    bottomLeft: Radius.circular(28),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                        colors: [
                          Color(0xFF3C2216),
                          Color(0xFF5A3420),
                          Color(0xFF8C4A27),
                        ],
                      ),
                    ),
                    child: Stack(
                      children: [
                        // Top-Right Large Organic Blob Overlay
                        Positioned(
                          top: -60,
                          right: -60,
                          child: Container(
                            width: 250,
                            height: 250,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.06),
                            ),
                          ),
                        ),
                        // Bottom-Left Large Organic Blob Overlay
                        Positioned(
                          bottom: -90,
                          left: -90,
                          child: Container(
                            width: 280,
                            height: 280,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(0xFFE5B976).withOpacity(0.08),
                            ),
                          ),
                        ),
                        // Extra soft accent circle around the logo
                        Positioned(
                          top: 130,
                          left: -30,
                          child: Container(
                            width: 140,
                            height: 140,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: Colors.white.withOpacity(0.04),
                            ),
                          ),
                        ),
                        if (!isMobile) ...[
                          Positioned(
                            top: 50,
                            right: 70,
                            child: _floatingIcon(
                              emoji: '🧁',
                              phase: 0,
                              amplitude: 8,
                              fontSize: 22,
                              baseAngle: -0.2,
                            ),
                          ),
                          Positioned(
                            top: 310,
                            right: 90,
                            child: _floatingIcon(
                              emoji: '🎂',
                              phase: pi / 2,
                              amplitude: 8,
                              fontSize: 18,
                              baseAngle: 0.1,
                            ),
                          ),
                          Positioned(
                            bottom: 70,
                            left: 60,
                            child: _floatingIcon(
                              emoji: '🍪',
                              phase: pi,
                              amplitude: 7,
                              fontSize: 20,
                              baseAngle: 0.15,
                            ),
                          ),
                          Positioned(
                            bottom: 110,
                            right: 75,
                            child: _floatingIcon(
                              emoji: '🍩',
                              phase: pi * 1.2,
                              amplitude: 9,
                              fontSize: 22,
                              baseAngle: 0.2,
                            ),
                          ),
                          Positioned(
                            top: 450,
                            left: 10,
                            child: _floatingIcon(
                              emoji: '🍫',
                              phase: pi * 0.3,
                              amplitude: 6,
                              fontSize: 18,
                              baseAngle: -0.1,
                            ),
                          ),
                        ],
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 36, vertical: 32),
                          child: Center(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.center,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                _breathingLogo(),
                                const SizedBox(height: 18),
                                const Text(
                                  'WELCOME TO',
                                  style: TextStyle(
                                    fontSize: 11,
                                    fontWeight: FontWeight.w900,
                                    color: Color(0xFFE5B976),
                                    letterSpacing: 2,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    const Text(
                                      'NyseBites',
                                      style: TextStyle(
                                        fontSize: 28,
                                        fontWeight: FontWeight.w900,
                                        color: Colors.white,
                                        letterSpacing: -0.5,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    _twinkleSparkle(fontSize: 22, phase: 0),
                                    _twinkleSparkle(fontSize: 16, phase: pi / 3),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                SizedBox(
                                  height: 60,
                                  child: Text(
                                    _isSignUp
                                        ? 'Join our community of sweet tooth lovers and satisfy your cravings seamlessly.'
                                        : 'Handcrafted cookies & fudgy brownies baked fresh daily. Sign in to check on your active orders.',
                                    style: TextStyle(
                                      fontSize: 12.5,
                                      color: Colors.white.withOpacity(0.85),
                                      height: 1.4,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );

                // Right Form Panel
                final formPanel = Container(
                  color: const Color(0xFFFBF5ED),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.fromLTRB(32, 24, 32, 24),
                    child: Form(
                      key: _formKey,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Container(
                                width: 165,
                                padding: const EdgeInsets.all(3),
                                decoration: BoxDecoration(
                                  color: const Color(0xFFF4E9DC),
                                  borderRadius: BorderRadius.circular(22),
                                ),
                                child: Stack(
                                  children: [
                                    AnimatedAlign(
                                      duration: const Duration(milliseconds: 280),
                                      curve: Curves.easeOutCubic,
                                      alignment: _isSignUp
                                          ? Alignment.centerRight
                                          : Alignment.centerLeft,
                                      child: FractionallySizedBox(
                                        widthFactor: 0.5,
                                        child: Container(
                                          height: 28,
                                          decoration: BoxDecoration(
                                            color: const Color(0xFF8C4A27),
                                            borderRadius: BorderRadius.circular(18),
                                          ),
                                        ),
                                      ),
                                    ),
                                    Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => setState(() {
                                              _isSignUp = false;
                                              _authErrorMessage = null;
                                              _formKey.currentState?.reset();
                                            }),
                                            child: SizedBox(
                                              height: 28,
                                              child: Center(
                                                child: AnimatedDefaultTextStyle(
                                                  duration: const Duration(milliseconds: 280),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: !_isSignUp
                                                        ? Colors.white
                                                        : const Color(0xFF7A6559),
                                                  ),
                                                  child: const Text('Sign In'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                        Expanded(
                                          child: GestureDetector(
                                            behavior: HitTestBehavior.opaque,
                                            onTap: () => setState(() {
                                              _isSignUp = true;
                                              _authErrorMessage = null;
                                              _formKey.currentState?.reset();
                                            }),
                                            child: SizedBox(
                                              height: 28,
                                              child: Center(
                                                child: AnimatedDefaultTextStyle(
                                                  duration: const Duration(milliseconds: 280),
                                                  style: TextStyle(
                                                    fontSize: 12,
                                                    fontWeight: FontWeight.w800,
                                                    color: _isSignUp
                                                        ? Colors.white
                                                        : const Color(0xFF7A6559),
                                                  ),
                                                  child: const Text('Sign Up'),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  TextButton(
                                    onPressed: _handleGuestAccess,
                                    style: TextButton.styleFrom(
                                      foregroundColor: const Color(0xFF8C4A27),
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8,
                                        vertical: 4,
                                      ),
                                      minimumSize: Size.zero,
                                      tapTargetSize: MaterialTapTargetSize.shrinkWrap,
                                    ),
                                    child: const Text(
                                      'Skip as guest',
                                      style: TextStyle(
                                        fontSize: 11.5,
                                        fontWeight: FontWeight.w700,
                                        decoration: TextDecoration.underline,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 4),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.close_rounded,
                                      color: Color(0xFF7A6559),
                                      size: 20,
                                    ),
                                    onPressed: () => Navigator.pop(context),
                                    padding: EdgeInsets.zero,
                                    constraints: const BoxConstraints(),
                                  ),
                                ],
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              key: ValueKey(_isSignUp),
                              _isSignUp ? 'Create account' : 'Sign in',
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w900,
                                color: Color(0xFF251811),
                                letterSpacing: -0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 2),
                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 300),
                            child: Text(
                              key: ValueKey(_isSignUp),
                              _isSignUp
                                  ? 'Please fill in your details to get started'
                                  : 'Please enter your credentials to continue',
                              style: const TextStyle(
                                fontSize: 12.5,
                                color: Color(0xFF7A6559),
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),

                          if (_authErrorMessage != null) ...[
                            Container(
                              width: double.infinity,
                              padding: const EdgeInsets.symmetric(
                                horizontal: 12,
                                vertical: 10,
                              ),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFDE8E8),
                                borderRadius: BorderRadius.circular(14),
                                border: Border.all(color: const Color(0xFFF8B4B4)),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.error_outline_rounded,
                                    color: Color(0xFFC62828),
                                    size: 16,
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: Text(
                                      _authErrorMessage!,
                                      style: const TextStyle(
                                        fontSize: 11.5,
                                        color: Color(0xFFC62828),
                                        fontWeight: FontWeight.w600,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 10),
                          ],

                          AnimatedSwitcher(
                            duration: const Duration(milliseconds: 400),
                            transitionBuilder: (child, animation) => FadeTransition(
                              opacity: animation,
                              child: SizeTransition(
                                sizeFactor: animation,
                                child: child,
                              ),
                            ),
                            child: Column(
                              key: ValueKey(_isSignUp),
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (_isSignUp) ...[
                                  _buildCleanField(
                                    controller: _nameController,
                                    label: 'Full Name',
                                    hint: 'e.g. Mai Leonhart',
                                    icon: Icons.person_outline_rounded,
                                    textInputAction: TextInputAction.next,
                                    showCheck: _nameController.text.trim().length >= 2,
                                    validator: (val) {
                                      if (val == null || val.trim().isEmpty) {
                                        return 'Please enter your full name';
                                      }
                                      if (val.trim().length < 2) {
                                        return 'Name must be at least 2 characters';
                                      }
                                      return null;
                                    },
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ],
                            ),
                          ),

                          _buildCleanField(
                            controller: _emailController,
                            label: 'Email Address',
                            hint: 'maihart@gmail.com',
                            icon: Icons.email_outlined,
                            keyboardType: TextInputType.emailAddress,
                            textInputAction: TextInputAction.next,
                            showCheck: _isValidEmail(_emailController.text),
                            validator: (val) {
                              if (val == null || val.trim().isEmpty) {
                                return 'Please enter your email address';
                              }
                              if (!_isValidEmail(val)) {
                                return 'Please enter a valid email address';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 10),

                          _buildCleanField(
                            controller: _passwordController,
                            label: 'Password',
                            hint: '••••••••',
                            icon: Icons.lock_outline_rounded,
                            obscureText: _obscurePassword,
                            textInputAction: TextInputAction.done,
                            onFieldSubmitted: (_) => _handleSubmit(),
                            showCheck: !_isSignUp || _isPasswordValid,
                            suffixIcon: IconButton(
                              icon: Icon(
                                _obscurePassword
                                    ? Icons.visibility_off_outlined
                                    : Icons.visibility_outlined,
                                size: 18,
                                color: const Color(0xFF7A6559),
                              ),
                              onPressed: () => setState(
                                  () => _obscurePassword = !_obscurePassword),
                            ),
                            validator: (val) {
                              if (val == null || val.isEmpty) {
                                return 'Please enter your password';
                              }
                              if (_isSignUp && !_isPasswordValid) {
                                return 'Password does not meet security criteria';
                              }
                              return null;
                            },
                          ),

                          if (!_isSignUp) ...[
                            const SizedBox(height: 10),
                            Row(
                              children: [
                                SizedBox(
                                  width: 18,
                                  height: 18,
                                  child: Checkbox(
                                    value: _keepLoggedIn,
                                    activeColor: const Color(0xFF8C4A27),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    onChanged: (val) => setState(
                                      () => _keepLoggedIn = val ?? true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                const Text(
                                  'Keep me logged in',
                                  style: TextStyle(
                                    fontSize: 12.5,
                                    color: Color(0xFF7A6559),
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                              ],
                            ),
                          ],

                          if (_isSignUp) ...[
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.all(10),
                              decoration: BoxDecoration(
                                color: const Color(0xFFFBEBE4),
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(color: const Color(0xFFEFE4D6)),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'Password must contain:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: Color(0xFF251811),
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Wrap(
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      _buildRequirementBadge(
                                        'At least 8 chars',
                                        _hasMinLength,
                                      ),
                                      _buildRequirementBadge(
                                        'Uppercase (A-Z)',
                                        _hasUppercase,
                                      ),
                                      _buildRequirementBadge(
                                        'Lowercase (a-z)',
                                        _hasLowercase,
                                      ),
                                      _buildRequirementBadge(
                                        'Number (0-9)',
                                        _hasNumber,
                                      ),
                                      _buildRequirementBadge(
                                        'Symbol (!@#\$%)',
                                        _hasSpecialChar,
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          ],

                          const SizedBox(height: 16),

                          SizedBox(
                            width: double.infinity,
                            height: 46,
                            child: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: const Color(0xFF8C4A27),
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(24),
                                ),
                                elevation: 2,
                                shadowColor: const Color(0xFF8C4A27).withOpacity(0.3),
                              ),
                              onPressed: _isLoading ? null : _handleSubmit,
                              child: _isLoading
                                  ? const SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : Text(
                                      _isSignUp ? 'Complete Sign Up 🧁' : 'Sign In 🍪',
                                      style: const TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 14,
                                        letterSpacing: 0.4,
                                      ),
                                    ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );

                if (isMobile) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        brandPanel,
                        formPanel,
                      ],
                    ),
                  );
                }

                return IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(flex: 4, child: brandPanel),
                      Expanded(flex: 6, child: formPanel),
                    ],
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}
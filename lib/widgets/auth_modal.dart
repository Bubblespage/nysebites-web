import 'package:flutter/material.dart';

class AuthModal extends StatefulWidget {
  final Function(String userName) onLoginSuccess;

  const AuthModal({super.key, required this.onLoginSuccess});

  @override
  State<AuthModal> createState() => _AuthModalState();
}

class _AuthModalState extends State<AuthModal> {
  static final Map<String, Map<String, String>> _userDatabase = {
    'shaina@nysebites.com': {
      'name': 'Shaina Rynne',
      'password': 'Password@123',
    },
    'demo@nysebites.com': {
      'name': 'Demo Baker',
      'password': 'Password@123',
    },
  };

  final _formKey = GlobalKey<FormState>();

  bool _isSignUp = false;
  bool _obscurePassword = true;
  String? _authErrorMessage;

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

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
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  bool _isValidEmail(String email) {
    return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
        .hasMatch(email.trim());
  }

  void _handleSubmit() {
    setState(() => _authErrorMessage = null);

    if (!_formKey.currentState!.validate()) {
      return;
    }

    final email = _emailController.text.trim().toLowerCase();
    final password = _passwordController.text;
    final name = _nameController.text.trim();

    if (_isSignUp) {
      if (!_isPasswordValid) {
        setState(() {
          _authErrorMessage = 'Please fulfill all password requirements below.';
        });
        return;
      }

      if (_userDatabase.containsKey(email)) {
        setState(() {
          _authErrorMessage =
              'An account with this email already exists. Please sign in instead.';
        });
        return;
      }

      _userDatabase[email] = {
        'name': name,
        'password': password,
      };

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Account created successfully for $name! 🎉'),
          backgroundColor: const Color(0xFF8E4A23),
          behavior: SnackBarBehavior.floating,
        ),
      );

      widget.onLoginSuccess(name);
      Navigator.pop(context);
    } else {
      if (!_userDatabase.containsKey(email)) {
        setState(() {
          _authErrorMessage =
              'No account found with this email. Please sign up first!';
        });
        return;
      }

      final userData = _userDatabase[email]!;
      if (userData['password'] != password) {
        setState(() {
          _authErrorMessage = 'Incorrect password. Please try again.';
        });
        return;
      }

      final registeredName = userData['name'] ?? 'Baker';
      widget.onLoginSuccess(registeredName);
      Navigator.pop(context);
    }
  }

  void _handleGuestAccess() {
    widget.onLoginSuccess('Guest Baker');
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 24),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Container(
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: const Color(0xFFFDFBF7),
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: const Color(0xFFEFE4D6)),
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(60, 34, 22, 0.18),
                blurRadius: 28,
                offset: Offset(0, 12),
              ),
            ],
          ),
          child: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header with Logo Image
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Container(
                            width: 38,
                            height: 38,
                            padding: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: const Color(0xFFF3E7DC),
                              borderRadius: BorderRadius.circular(10),
                              border: Border.all(color: const Color(0xFFE5D5C5)),
                            ),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(7),
                              child: Image.asset(
                                'assets/images/logo.jpg',
                                fit: BoxFit.cover,
                                errorBuilder: (_, __, ___) => const Icon(
                                  Icons.cookie_outlined,
                                  color: Color(0xFF8E4A23),
                                  size: 18,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Text(
                            _isSignUp ? 'Create Account' : 'Sign In',
                            style: const TextStyle(
                              fontFamily: 'serif',
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              color: Color(0xFF2E1B10),
                            ),
                          ),
                        ],
                      ),
                      IconButton(
                        icon: const Icon(Icons.close,
                            color: Color(0xFF756256), size: 20),
                        onPressed: () => Navigator.pop(context),
                      ),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    _isSignUp
                        ? 'Register your bakery account to order and save custom cake designs.'
                        : 'Enter your credentials to access your tray and active orders.',
                    style: const TextStyle(
                        fontSize: 12.5, height: 1.4, color: Color(0xFF756256)),
                  ),
                  const SizedBox(height: 16),

                  if (_authErrorMessage != null) ...[
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 10),
                      decoration: BoxDecoration(
                        color: const Color(0xFFFDE8E8),
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: const Color(0xFFF8B4B4)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.error_outline_rounded,
                              color: Color(0xFF9B1C1C), size: 18),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              _authErrorMessage!,
                              style: const TextStyle(
                                fontSize: 12,
                                color: Color(0xFF9B1C1C),
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 14),
                  ],

                  if (_isSignUp) ...[
                    _buildValidatedField(
                      controller: _nameController,
                      label: 'Full Name',
                      hint: 'e.g. Shaina Rynne',
                      icon: Icons.person_outline_rounded,
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
                    const SizedBox(height: 14),
                  ],

                  _buildValidatedField(
                    controller: _emailController,
                    label: 'Email Address',
                    hint: 'name@example.com',
                    icon: Icons.email_outlined,
                    keyboardType: TextInputType.emailAddress,
                    validator: (val) {
                      if (val == null || val.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!_isValidEmail(val)) {
                        return 'Please enter a valid email (e.g. user@domain.com)';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  _buildValidatedField(
                    controller: _passwordController,
                    label: 'Password',
                    hint: _isSignUp ? 'e.g. Pass@1234' : 'Enter your password',
                    icon: Icons.lock_outline_rounded,
                    obscureText: _obscurePassword,
                    suffixIcon: IconButton(
                      icon: Icon(
                        _obscurePassword
                            ? Icons.visibility_off_outlined
                            : Icons.visibility_outlined,
                        size: 18,
                        color: const Color(0xFF756256),
                      ),
                      onPressed: () =>
                          setState(() => _obscurePassword = !_obscurePassword),
                    ),
                    validator: (val) {
                      if (val == null || val.isEmpty) {
                        return 'Please enter your password';
                      }
                      if (_isSignUp && !_isPasswordValid) {
                        return 'Password does not meet the security criteria';
                      }
                      return null;
                    },
                  ),

                  if (_isSignUp) ...[
                    const SizedBox(height: 12),
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.white,
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
                              fontWeight: FontWeight.w700,
                              color: Color(0xFF5A4438),
                            ),
                          ),
                          const SizedBox(height: 8),
                          Wrap(
                            spacing: 8,
                            runSpacing: 6,
                            children: [
                              _buildRequirementBadge(
                                  'At least 8 characters', _hasMinLength),
                              _buildRequirementBadge(
                                  'Uppercase letter (A-Z)', _hasUppercase),
                              _buildRequirementBadge(
                                  'Lowercase letter (a-z)', _hasLowercase),
                              _buildRequirementBadge(
                                  'Number (0-9)', _hasNumber),
                              _buildRequirementBadge(
                                  'Special character (!@#\$%^&*)',
                                  _hasSpecialChar),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],

                  if (!_isSignUp)
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton(
                        onPressed: () {},
                        style: TextButton.styleFrom(
                            padding: const EdgeInsets.only(top: 4)),
                        child: const Text(
                          'Forgot Password?',
                          style: TextStyle(
                              fontSize: 11.5,
                              color: Color(0xFF8E4A23),
                              fontWeight: FontWeight.w600),
                        ),
                      ),
                    ),

                  const SizedBox(height: 18),

                  SizedBox(
                    width: double.infinity,
                    height: 46,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF8E4A23),
                        foregroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                        elevation: 1,
                      ),
                      onPressed: _handleSubmit,
                      child: Text(
                        _isSignUp ? 'Complete Sign Up' : 'Sign In',
                        style: const TextStyle(
                            fontWeight: FontWeight.bold, fontSize: 14),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  const Row(
                    children: [
                      Expanded(child: Divider(color: Color(0xFFEFE4D6))),
                      Padding(
                        padding: EdgeInsets.symmetric(horizontal: 10),
                        child: Text(
                          'OR',
                          style: TextStyle(
                              fontSize: 10.5,
                              color: Color(0xFF9E8E84),
                              fontWeight: FontWeight.bold),
                        ),
                      ),
                      Expanded(child: Divider(color: Color(0xFFEFE4D6))),
                    ],
                  ),
                  const SizedBox(height: 14),

                  SizedBox(
                    width: double.infinity,
                    height: 42,
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF2E1B10),
                        side: const BorderSide(
                            color: Color(0xFFDCC8B8), width: 1.2),
                        backgroundColor: Colors.white,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: _handleGuestAccess,
                      icon: const Icon(Icons.person_pin_circle_outlined,
                          size: 18, color: Color(0xFF8E4A23)),
                      label: const Text(
                        'Continue as Guest',
                        style:
                            TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          _isSignUp
                              ? 'Already have an account?'
                              : 'Don\'t have an account yet?',
                          style: const TextStyle(
                              fontSize: 12.5, color: Color(0xFF756256)),
                        ),
                        TextButton(
                          onPressed: () {
                            setState(() {
                              _isSignUp = !_isSignUp;
                              _authErrorMessage = null;
                              _formKey.currentState?.reset();
                            });
                          },
                          child: Text(
                            _isSignUp ? 'Sign In' : 'Sign Up',
                            style: const TextStyle(
                              fontSize: 12.5,
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF8E4A23),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRequirementBadge(String label, bool isMet) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 200),
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: isMet ? const Color(0xFFDEF7EC) : const Color(0xFFF3F4F6),
        borderRadius: BorderRadius.circular(6),
        border: Border.all(
          color: isMet ? const Color(0xFF31C48D) : const Color(0xFFE5E7EB),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            isMet ? Icons.check_circle_rounded : Icons.circle_outlined,
            size: 12,
            color: isMet ? const Color(0xFF0E9F6E) : const Color(0xFF9CA3AF),
          ),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              fontWeight: isMet ? FontWeight.w700 : FontWeight.w500,
              color: isMet ? const Color(0xFF03543F) : const Color(0xFF6B7280),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildValidatedField({
    required TextEditingController controller,
    required String label,
    required String hint,
    required IconData icon,
    bool obscureText = false,
    Widget? suffixIcon,
    TextInputType keyboardType = TextInputType.text,
    required String? Function(String?) validator,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: Color(0xFF2E1B10)),
        ),
        const SizedBox(height: 6),
        TextFormField(
          controller: controller,
          obscureText: obscureText,
          keyboardType: keyboardType,
          validator: validator,
          style: const TextStyle(fontSize: 13, color: Color(0xFF2E1B10)),
          decoration: InputDecoration(
            hintText: hint,
            hintStyle: const TextStyle(fontSize: 12, color: Color(0xFF9E8E84)),
            prefixIcon: Icon(icon, color: const Color(0xFF8E4A23), size: 18),
            suffixIcon: suffixIcon,
            filled: true,
            fillColor: Colors.white,
            errorStyle: const TextStyle(fontSize: 11, height: 1.1),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Color(0xFFEFE4D6)),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Color(0xFF8E4A23), width: 1.5),
            ),
            errorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: Colors.redAccent),
            ),
            focusedErrorBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: Colors.redAccent, width: 1.5),
            ),
          ),
        ),
      ],
    );
  }
}
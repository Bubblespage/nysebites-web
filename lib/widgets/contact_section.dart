import 'package:flutter/material.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _noteController = TextEditingController();

  String? _nameError;
  String? _emailError;
  String? _noteError;

  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email.trim());
  }

  bool _isValidFullName(String name) {
    final trimmed = name.trim();
    final parts = trimmed.split(RegExp(r'\s+'));
    return parts.length >= 2 && trimmed.length >= 4;
  }

  void _sendSweetNote() {
    final name = _nameController.text.trim();
    final email = _emailController.text.trim();
    final note = _noteController.text.trim();

    setState(() {
      _nameError = null;
      _emailError = null;
      _noteError = null;

      if (name.isEmpty) {
        _nameError = 'Please enter your full name.';
      } else if (!_isValidFullName(name)) {
        _nameError = 'Please provide both your first and last name.';
      }

      if (email.isEmpty) {
        _emailError = 'Please enter your email address.';
      } else if (!_isValidEmail(email)) {
        _emailError = 'Please enter a valid email (e.g. name@gmail.com).';
      }

      if (note.isEmpty) {
        _noteError = 'Please write a brief note or question.';
      } else if (note.length < 5) {
        _noteError = 'Note must be at least 5 characters long.';
      }
    });

    if (_nameError != null || _emailError != null || _noteError != null) {
      return;
    }

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Row(
          children: [
            Icon(Icons.mark_email_read_outlined, color: Color(0xFF8E4A23)),
            SizedBox(width: 8),
            Text('💌 Note Sent!'),
          ],
        ),
        content: Text(
          'Thanks for reaching out, $name!\n\nOur bakery team has received your sweet note. We\'ll send our reply directly to $email shortly.',
          style: const TextStyle(height: 1.5),
        ),
        actions: [
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF8E4A23),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            ),
            onPressed: () {
              _nameController.clear();
              _emailController.clear();
              _noteController.clear();
              setState(() {
                _nameError = null;
                _emailError = null;
                _noteError = null;
              });
              Navigator.pop(context);
            },
            child: const Text('Done'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: const EdgeInsets.symmetric(vertical: 56, horizontal: 20),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 620),
          child: Container(
            padding: const EdgeInsets.all(32),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: const Color(0xFFEFE4D6), width: 1.5),
              boxShadow: const [
                BoxShadow(
                  color: Color.fromRGBO(60, 34, 22, 0.06),
                  blurRadius: 20,
                  offset: Offset(0, 8),
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                  decoration: BoxDecoration(
                    color: const Color(0xFF8E4A23).withOpacity(0.1),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(Icons.edit_note_rounded, color: Color(0xFF8E4A23), size: 16),
                      SizedBox(width: 6),
                      Text(
                        'DROP US A MESSAGE',
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w800,
                          letterSpacing: 1.1,
                          color: Color(0xFF8E4A23),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Leave a Quick Sweet Note',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 26,
                    fontWeight: FontWeight.bold,
                    color: Color(0xFF2E1B10),
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Have a custom cake inquiry, event order, or feedback for the bakers?',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFF756256), fontSize: 13),
                ),
                const SizedBox(height: 24),

                TextField(
                  controller: _nameController,
                  onChanged: (_) {
                    if (_nameError != null) setState(() => _nameError = null);
                  },
                  decoration: _inputDecoration(
                    hint: 'Full Name (e.g. Maria Santos)',
                    icon: Icons.person_outline,
                    errorText: _nameError,
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  onChanged: (_) {
                    if (_emailError != null) setState(() => _emailError = null);
                  },
                  decoration: _inputDecoration(
                    hint: 'Correct Email (e.g. maria@gmail.com)',
                    icon: Icons.email_outlined,
                    errorText: _emailError,
                  ),
                ),
                const SizedBox(height: 14),

                TextField(
                  controller: _noteController,
                  maxLines: 3,
                  onChanged: (_) {
                    if (_noteError != null) setState(() => _noteError = null);
                  },
                  decoration: _inputDecoration(
                    hint: 'Write your sweet note or order question here...',
                    icon: Icons.favorite_border,
                    errorText: _noteError,
                  ),
                ),
                const SizedBox(height: 22),

                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF8E4A23),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                      elevation: 2,
                    ),
                    onPressed: _sendSweetNote,
                    icon: const Icon(Icons.send_rounded, size: 16),
                    label: const Text(
                      'Send Sweet Note',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
    String? errorText,
  }) {
    return InputDecoration(
      hintText: hint,
      errorText: errorText,
      prefixIcon: Icon(icon, color: const Color(0xFF8E4A23), size: 18),
      filled: true,
      fillColor: const Color(0xFFFAF6F0),
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
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
        borderSide: const BorderSide(color: Color(0xFF8E4A23), width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
    );
  }
}
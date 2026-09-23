import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../theme/app_colors.dart';

class ContactSection extends StatefulWidget {
  const ContactSection({super.key});

  @override
  State<ContactSection> createState() => _ContactSectionState();
}

class _ContactSectionState extends State<ContactSection> {
  final _formKey = GlobalKey<FormState>();

  String _name = '';
  String _email = '';
  String _subject = '';
  String _message = '';

  bool _isSending = false;
  String? _validationErrorMessage;

  void _showSuccessDialog() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        backgroundColor: Colors.transparent,
        insetPadding: const EdgeInsets.symmetric(horizontal: 16),
        child: Container(
          width: 420,
          padding: const EdgeInsets.all(28),
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.textDarkBerry.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDarkBerry.withValues(alpha: 0.15),
                blurRadius: 24,
                offset: const Offset(0, 10),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 64,
                height: 64,
                decoration: BoxDecoration(
                  color: AppColors.bgPastelPink,
                  shape: BoxShape.circle,
                  border: Border.all(color: AppColors.bgPastelPink),
                ),
                child: const Center(
                  child: Text('💌', style: TextStyle(fontSize: 30)),
                ),
              ),
              const SizedBox(height: 18),
              const Text(
                'Sweet Note Delivered!',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: 'serif',
                  fontSize: 21,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGarnet,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Thank you for reaching out! Our kitchen and bakery team have received your note and will get back to you shortly.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 13,
                  color: AppColors.textDarkBerry,
                  height: 1.45,
                ),
              ),
              const SizedBox(height: 22),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.brandRed,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 1,
                  ),
                  onPressed: () => Navigator.pop(context),
                  child: const Text(
                    'Back to Bakery',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 13.5,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _handleSendSweetNote() async {
    setState(() => _validationErrorMessage = null);

    if (!_formKey.currentState!.validate()) {
      setState(() {
        _validationErrorMessage =
            'Please complete all required fields with a valid message.';
      });
      return;
    }

    if (_name.trim().isEmpty ||
        _email.trim().isEmpty ||
        _subject.trim().isEmpty ||
        _message.trim().isEmpty) {
      setState(() {
        _validationErrorMessage = 'Your sweet note message cannot be empty.';
      });
      return;
    }

    _formKey.currentState!.save();
    setState(() => _isSending = true);

    try {
      await FirebaseFirestore.instance.collection('sweet_notes').add({
        'name': _name.trim(),
        'email': _email.trim(),
        'subject': _subject.trim(),
        'message': _message.trim(),
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });

      if (!mounted) return;

      _formKey.currentState!.reset();
      setState(() {
        _name = '';
        _email = '';
        _subject = '';
        _message = '';
        _validationErrorMessage = null;
      });

      _showSuccessDialog();
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Failed to send note: $e'),
          backgroundColor: AppColors.brandRed,
        ),
      );
    } finally {
      if (mounted) setState(() => _isSending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 768;

    return Container(
      width: double.infinity,
      color: Colors.transparent,
      padding: EdgeInsets.symmetric(
        horizontal: isMobile ? 16 : 24,
        vertical: isMobile ? 24 : 32,
      ),
      alignment: Alignment.center,
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 720),
        child: Container(
          padding: EdgeInsets.all(isMobile ? 20 : 36),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.textDarkBerry.withValues(alpha: 0.1)),
            boxShadow: [
              BoxShadow(
                color: AppColors.textDarkBerry.withValues(alpha: 0.08),
                blurRadius: 24,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Leave a Sweet Note 💌',
                  style: TextStyle(
                    fontFamily: 'serif',
                    fontSize: 24,
                    fontWeight: FontWeight.w900,
                    color: AppColors.darkGarnet,
                  ),
                ),
                const SizedBox(height: 6),
                const Text(
                  'Questions about bulk catering, custom themes, or ingredient inquiries? Send our kitchen team a note!',
                  style: TextStyle(
                    fontSize: 12.5,
                    color: AppColors.textDarkBerry,
                    height: 1.4,
                  ),
                ),
                const SizedBox(height: 20),

                if (_validationErrorMessage != null) ...[
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.bgPastelPink,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: AppColors.bgPastelPink),
                    ),
                    child: Row(
                      children: [
                        const Icon(
                          Icons.error_outline_rounded,
                          color: AppColors.brandRed,
                          size: 18,
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            _validationErrorMessage!,
                            style: const TextStyle(
                              fontSize: 12,
                              color: AppColors.brandRed,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),
                ],

                // 1. Name
                _buildInputWrapper(
                  label: 'Your Name',
                  child: TextFormField(
                    initialValue: _name,
                    onChanged: (val) {
                      _name = val;
                      if (_validationErrorMessage != null) {
                        setState(() => _validationErrorMessage = null);
                      }
                    },
                    onSaved: (val) => _name = val ?? '',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter your name'
                        : null,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGarnet,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. Mai Leonhart',
                      icon: Icons.person_outline,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 2. Email
                _buildInputWrapper(
                  label: 'Email Address',
                  child: TextFormField(
                    initialValue: _email,
                    keyboardType: TextInputType.emailAddress,
                    onChanged: (val) {
                      _email = val;
                      if (_validationErrorMessage != null) {
                        setState(() => _validationErrorMessage = null);
                      }
                    },
                    onSaved: (val) => _email = val ?? '',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please enter your email address';
                      }
                      if (!RegExp(
                        r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
                      ).hasMatch(v.trim())) {
                        return 'Please enter a valid email address';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGarnet,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. name@example.com',
                      icon: Icons.email_outlined,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 3. Subject
                _buildInputWrapper(
                  label: 'Subject / Event',
                  child: TextFormField(
                    initialValue: _subject,
                    onChanged: (val) {
                      _subject = val;
                      if (_validationErrorMessage != null) {
                        setState(() => _validationErrorMessage = null);
                      }
                    },
                    onSaved: (val) => _subject = val ?? '',
                    validator: (v) => v == null || v.trim().isEmpty
                        ? 'Please enter a subject or topic'
                        : null,
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGarnet,
                    ),
                    decoration: _inputDecoration(
                      hint: 'e.g. Birthday Celebration Bulk Order',
                      icon: Icons.bookmark_outline,
                    ),
                  ),
                ),
                const SizedBox(height: 14),

                // 4. Message
                _buildInputWrapper(
                  label: 'Message',
                  child: TextFormField(
                    initialValue: _message,
                    maxLines: 4,
                    onChanged: (val) {
                      _message = val;
                      if (_validationErrorMessage != null) {
                        setState(() => _validationErrorMessage = null);
                      }
                    },
                    onSaved: (val) => _message = val ?? '',
                    validator: (v) {
                      if (v == null || v.trim().isEmpty) {
                        return 'Please write your message before sending.';
                      }
                      if (v.trim().length < 5) {
                        return 'Your note is too short. Please provide more details.';
                      }
                      return null;
                    },
                    style: const TextStyle(
                      fontSize: 13,
                      color: AppColors.darkGarnet,
                    ),
                    decoration: _inputDecoration(
                      hint:
                          'Tell us about your questions or custom cake design ideas...',
                      icon: Icons.chat_bubble_outline,
                    ),
                  ),
                ),
                const SizedBox(height: 22),

                // Submit Button
                SizedBox(
                  width: double.infinity,
                  height: 48,
                  child: ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.brandRed,
                      foregroundColor: Colors.white,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      elevation: 1,
                    ),
                    onPressed: _isSending ? null : _handleSendSweetNote,
                    icon: _isSending
                        ? const SizedBox(
                            width: 18,
                            height: 18,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Icon(Icons.send_rounded, size: 18),
                    label: Text(
                      _isSending ? 'Sending Note...' : 'Send Sweet Note',
                      style: const TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 14,
                      ),
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

  Widget _buildInputWrapper({required String label, required Widget child}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 12,
            color: AppColors.darkGarnet,
          ),
        ),
        const SizedBox(height: 6),
        child,
      ],
    );
  }

  InputDecoration _inputDecoration({
    required String hint,
    required IconData icon,
  }) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(fontSize: 12, color: AppColors.textDarkBerry),
      prefixIcon: Icon(icon, color: AppColors.textDarkBerry, size: 18),
      filled: true,
      fillColor: AppColors.bgPastelPink,
      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textDarkBerry.withValues(alpha: 0.1)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: AppColors.textDarkBerry.withValues(alpha: 0.1)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: AppColors.textDarkBerry, width: 1.5),
      ),
      errorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.2),
      ),
      focusedErrorBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Colors.redAccent, width: 1.5),
      ),
      errorStyle: const TextStyle(
        fontSize: 11,
        height: 1.1,
        color: Colors.redAccent,
      ),
    );
  }
}

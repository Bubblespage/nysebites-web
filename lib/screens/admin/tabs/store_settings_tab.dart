import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class StoreSettingsTab extends StatefulWidget {
  const StoreSettingsTab({super.key});

  @override
  State<StoreSettingsTab> createState() => _StoreSettingsTabState();
}

class _StoreSettingsTabState extends State<StoreSettingsTab> {
  static const Color brandCocoa = Color(0xFF8C4A27);
  static const Color darkEspresso = Color(0xFF251811);
  static const Color textDark = Color(0xFF3A2312);
  static const Color textMuted = Color(0xFF6E5D53);
  static const Color borderLight = Color(0xFFEFE3D5);

  final DocumentReference<Map<String, dynamic>> _settingsDoc =
      FirebaseFirestore.instance.collection('settings').doc('storefront');

  bool _isSaving = false;
  bool _initialized = false;

  bool _isStoreOpen = true;
  bool _acceptCustomCakes = true;

  final TextEditingController _announcement1Controller = TextEditingController();
  final TextEditingController _announcement2Controller = TextEditingController();
  final TextEditingController _announcement3Controller = TextEditingController();
  final TextEditingController _gcashQrController = TextEditingController();

  final FocusNode _announcement1Focus = FocusNode();
  final FocusNode _announcement2Focus = FocusNode();
  final FocusNode _announcement3Focus = FocusNode();
  final FocusNode _gcashQrFocus = FocusNode();

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final payload = {
        'isStoreOpen': _isStoreOpen,
        'acceptCustomCakes': _acceptCustomCakes,
        'enableCod': false,
        'enableEwallet': true,
        'announcement1': _announcement1Controller.text.trim(),
        'announcement2': _announcement2Controller.text.trim(),
        'announcement3': _announcement3Controller.text.trim(),
        'announcementText': _announcement1Controller.text.trim(),
        'gcashQrUrl': _gcashQrController.text.trim(),
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _settingsDoc.set(payload, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('✨ Storefront settings and 3 announcement slots published live!'),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: const Color(0xFFE57373),
          content: Text('Failed to save settings: $e'),
        ),
      );
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  void dispose() {
    _announcement1Controller.dispose();
    _announcement2Controller.dispose();
    _announcement3Controller.dispose();
    _gcashQrController.dispose();

    _announcement1Focus.dispose();
    _announcement2Focus.dispose();
    _announcement3Focus.dispose();
    _gcashQrFocus.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<DocumentSnapshot<Map<String, dynamic>>>(
      stream: _settingsDoc.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasData && snapshot.data!.exists) {
          final data = snapshot.data!.data() ?? {};

          if (!_initialized) {
            _isStoreOpen = data['isStoreOpen'] ?? true;
            _acceptCustomCakes = data['acceptCustomCakes'] ?? true;

            _announcement1Controller.text = data['announcement1']?.toString() ??
                data['announcementText']?.toString() ??
                '🔥 Fresh Afternoon Drop ready at 3:00 PM • Order warm from oven!';
            _announcement2Controller.text = data['announcement2']?.toString() ??
                'Handcrafted small-batch cookies & fudgy brownies baked fresh daily at 9:00 AM';
            _announcement3Controller.text = data['announcement3']?.toString() ??
                '🎂 Custom cakes require a 2-week reservation notice in advance!';

            _gcashQrController.text = data['gcashQrUrl']?.toString() ?? 'assets/images/gcash_qr.png';
            _initialized = true;
          } else {
            if (!_announcement1Focus.hasFocus) {
              _announcement1Controller.text = data['announcement1']?.toString() ?? _announcement1Controller.text;
            }
            if (!_announcement2Focus.hasFocus) {
              _announcement2Controller.text = data['announcement2']?.toString() ?? _announcement2Controller.text;
            }
            if (!_announcement3Focus.hasFocus) {
              _announcement3Controller.text = data['announcement3']?.toString() ?? _announcement3Controller.text;
            }
            if (!_gcashQrFocus.hasFocus) {
              _gcashQrController.text = data['gcashQrUrl']?.toString() ?? _gcashQrController.text;
            }
          }
        } else if (!_initialized) {
          _announcement1Controller.text = '🔥 Fresh Afternoon Drop ready at 3:00 PM • Order warm from oven!';
          _announcement2Controller.text = 'Handcrafted small-batch cookies & fudgy brownies baked fresh daily at 9:00 AM';
          _announcement3Controller.text = '🎂 Custom cakes require a 2-week reservation notice in advance!';
          _gcashQrController.text = 'assets/images/gcash_qr.png';
          _initialized = true;
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final bool isMobile = constraints.maxWidth < 650;

            return SingleChildScrollView(
              padding: EdgeInsets.zero,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Header
                  isMobile
                      ? Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Storefront & Operations Settings',
                              style: TextStyle(
                                fontWeight: FontWeight.w800,
                                fontSize: 16,
                                color: textDark,
                              ),
                            ),
                            const SizedBox(height: 3),
                            const Text(
                              'Global shop controls, GCash merchant QR, and customer alerts.',
                              style: TextStyle(fontSize: 12, color: textMuted),
                            ),
                            const SizedBox(height: 12),
                            SizedBox(
                              width: double.infinity,
                              child: ElevatedButton.icon(
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: brandCocoa,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(vertical: 12),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10),
                                  ),
                                ),
                                onPressed: _isSaving ? null : _saveSettings,
                                icon: _isSaving
                                    ? const SizedBox(
                                        width: 14,
                                        height: 14,
                                        child: CircularProgressIndicator(
                                          color: Colors.white,
                                          strokeWidth: 2,
                                        ),
                                      )
                                    : const Icon(Icons.check, size: 16, color: Colors.white),
                                label: Text(
                                  _isSaving ? 'Publishing...' : 'Save Changes',
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                                ),
                              ),
                            ),
                          ],
                        )
                      : Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            const Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Storefront & Operations Settings',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 16,
                                    color: textDark,
                                  ),
                                ),
                                SizedBox(height: 3),
                                Text(
                                  'Global shop controls, GCash merchant QR, and customer alerts.',
                                  style: TextStyle(fontSize: 12, color: textMuted),
                                ),
                              ],
                            ),
                            ElevatedButton.icon(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: brandCocoa,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                              onPressed: _isSaving ? null : _saveSettings,
                              icon: _isSaving
                                  ? const SizedBox(
                                      width: 14,
                                      height: 14,
                                      child: CircularProgressIndicator(
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      ),
                                    )
                                  : const Icon(Icons.check, size: 16, color: Colors.white),
                              label: Text(
                                _isSaving ? 'Publishing...' : 'Save Changes',
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                              ),
                            ),
                          ],
                        ),
                  const SizedBox(height: 20),

                  // Section 1: Store Operations
                  _buildCard(
                    title: 'Store Operations & Kitchen Availability',
                    children: [
                      _buildSwitchTile(
                        'Online Orders Acceptance',
                        'Allow customers to checkout and place fresh drop orders',
                        _isStoreOpen,
                        (v) => setState(() => _isStoreOpen = v),
                      ),
                      const Divider(color: borderLight, height: 24),
                      _buildSwitchTile(
                        'Custom Cake Commission Desk',
                        'Open builder for 3D multi-tier custom celebration cakes',
                        _acceptCustomCakes,
                        (v) => setState(() => _acceptCustomCakes = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 2: 3 Announcement Tickers
                  _buildCard(
                    title: 'Customer Top Announcement Bar (3 Rotating Ticker Slots)',
                    children: [
                      TextField(
                        controller: _announcement1Controller,
                        focusNode: _announcement1Focus,
                        decoration: const InputDecoration(
                          labelText: 'Slot 1: Live Notice / Promo Banner',
                          prefixIcon: Icon(Icons.campaign_outlined, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _announcement2Controller,
                        focusNode: _announcement2Focus,
                        decoration: const InputDecoration(
                          labelText: 'Slot 2: Daily Oven Drop Schedule',
                          prefixIcon: Icon(Icons.bakery_dining_outlined, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                      const SizedBox(height: 12),
                      TextField(
                        controller: _announcement3Controller,
                        focusNode: _announcement3Focus,
                        decoration: const InputDecoration(
                          labelText: 'Slot 3: Special Notice / Reservation Reminder',
                          prefixIcon: Icon(Icons.cake_outlined, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: GCash QR Settings Only
                  _buildCard(
                    title: 'Merchant QR Image Settings (GCash Only)',
                    children: [
                      TextField(
                        controller: _gcashQrController,
                        focusNode: _gcashQrFocus,
                        decoration: const InputDecoration(
                          labelText: 'GCash QR Asset / URL',
                          hintText: 'assets/images/gcash_qr.png',
                          prefixIcon: Icon(Icons.qr_code_scanner, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 30),
                ],
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: borderLight),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w800,
              fontSize: 13.5,
              color: textDark,
            ),
          ),
          const SizedBox(height: 16),
          ...children,
        ],
      ),
    );
  }

  Widget _buildSwitchTile(
    String title,
    String subtitle,
    bool value,
    Function(bool) onChanged,
  ) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 13,
                  color: textDark,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: const TextStyle(fontSize: 11, color: textMuted),
              ),
            ],
          ),
        ),
        Switch(
          value: value,
          activeColor: brandCocoa,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
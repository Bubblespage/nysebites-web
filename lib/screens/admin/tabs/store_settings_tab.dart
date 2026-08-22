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
  bool _enableCod = true;
  bool _enableEwallet = true;

  final TextEditingController _announcement1Controller = TextEditingController();
  final TextEditingController _announcement2Controller = TextEditingController();
  final TextEditingController _announcement3Controller = TextEditingController();

  final TextEditingController _gcashQrController = TextEditingController();
  final TextEditingController _qrphQrController = TextEditingController();

  final TextEditingController _standardDeliveryFeeController = TextEditingController();
  final TextEditingController _scheduledDeliveryFeeController = TextEditingController();
  final TextEditingController _freeDeliveryMinController = TextEditingController();

  final FocusNode _announcement1Focus = FocusNode();
  final FocusNode _announcement2Focus = FocusNode();
  final FocusNode _announcement3Focus = FocusNode();
  final FocusNode _gcashQrFocus = FocusNode();
  final FocusNode _qrphQrFocus = FocusNode();
  final FocusNode _standardDeliveryFeeFocus = FocusNode();
  final FocusNode _scheduledDeliveryFeeFocus = FocusNode();
  final FocusNode _freeDeliveryMinFocus = FocusNode();

  Future<void> _saveSettings() async {
    setState(() => _isSaving = true);

    try {
      final payload = {
        'isStoreOpen': _isStoreOpen,
        'acceptCustomCakes': _acceptCustomCakes,
        'enableCod': _enableCod,
        'enableEwallet': _enableEwallet,
        'announcement1': _announcement1Controller.text.trim(),
        'announcement2': _announcement2Controller.text.trim(),
        'announcement3': _announcement3Controller.text.trim(),
        'announcementText': _announcement1Controller.text.trim(),
        'gcashQrUrl': _gcashQrController.text.trim(),
        'qrphQrUrl': _qrphQrController.text.trim(),
        'standardDeliveryFee': double.tryParse(_standardDeliveryFeeController.text.trim()) ?? 80.0,
        'scheduledDeliveryFee': double.tryParse(_scheduledDeliveryFeeController.text.trim()) ?? 70.0,
        'deliveryFee': double.tryParse(_standardDeliveryFeeController.text.trim()) ?? 80.0,
        'freeDeliveryMin': double.tryParse(_freeDeliveryMinController.text.trim()) ?? 1000.0,
        'updatedAt': FieldValue.serverTimestamp(),
      };

      await _settingsDoc.set(payload, SetOptions(merge: true));

      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          backgroundColor: Color(0xFF2E7D32),
          content: Text('✨ Storefront settings and QR channels published live!'),
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
    _qrphQrController.dispose();
    _standardDeliveryFeeController.dispose();
    _scheduledDeliveryFeeController.dispose();
    _freeDeliveryMinController.dispose();

    _announcement1Focus.dispose();
    _announcement2Focus.dispose();
    _announcement3Focus.dispose();
    _gcashQrFocus.dispose();
    _qrphQrFocus.dispose();
    _standardDeliveryFeeFocus.dispose();
    _scheduledDeliveryFeeFocus.dispose();
    _freeDeliveryMinFocus.dispose();
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
            _enableCod = data['enableCod'] ?? true;
            _enableEwallet = data['enableEwallet'] ?? true;

            _announcement1Controller.text = data['announcement1']?.toString() ??
                data['announcementText']?.toString() ??
                '🔥 Fresh Afternoon Drop ready at 3:00 PM • Order warm from oven!';
            _announcement2Controller.text = data['announcement2']?.toString() ??
                'Handcrafted small-batch cookies & fudgy brownies baked fresh daily at 9:00 AM';
            _announcement3Controller.text = data['announcement3']?.toString() ??
                'Enjoy free insulated doorstep delivery on all orders over ₱1,000';

            _gcashQrController.text = data['gcashQrUrl']?.toString() ?? 'assets/images/gcash_qr.png';
            _qrphQrController.text = data['qrphQrUrl']?.toString() ?? 'assets/images/qrph_qr.png';
            
            _standardDeliveryFeeController.text = (data['standardDeliveryFee'] ?? data['deliveryFee'] ?? 80.00).toString();
            _scheduledDeliveryFeeController.text = (data['scheduledDeliveryFee'] ?? 70.00).toString();
            _freeDeliveryMinController.text = (data['freeDeliveryMin'] ?? 1000.00).toString();
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
            if (!_qrphQrFocus.hasFocus) {
              _qrphQrController.text = data['qrphQrUrl']?.toString() ?? _qrphQrController.text;
            }
            if (!_standardDeliveryFeeFocus.hasFocus) {
              _standardDeliveryFeeController.text =
                  (data['standardDeliveryFee'] ?? _standardDeliveryFeeController.text).toString();
            }
            if (!_scheduledDeliveryFeeFocus.hasFocus) {
              _scheduledDeliveryFeeController.text =
                  (data['scheduledDeliveryFee'] ?? _scheduledDeliveryFeeController.text).toString();
            }
            if (!_freeDeliveryMinFocus.hasFocus) {
              _freeDeliveryMinController.text =
                  (data['freeDeliveryMin'] ?? _freeDeliveryMinController.text).toString();
            }
          }
        } else if (!_initialized) {
          _announcement1Controller.text = '🔥 Fresh Afternoon Drop ready at 3:00 PM • Order warm from oven!';
          _announcement2Controller.text = 'Handcrafted small-batch cookies & fudgy brownies baked fresh daily at 9:00 AM';
          _announcement3Controller.text = 'Enjoy free insulated doorstep delivery on all orders over ₱1,000';
          _gcashQrController.text = 'assets/images/gcash_qr.png';
          _qrphQrController.text = 'assets/images/qrph_qr.png';
          _standardDeliveryFeeController.text = '80.00';
          _scheduledDeliveryFeeController.text = '70.00';
          _freeDeliveryMinController.text = '1000.00';
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
                              'Global shop controls, payment QR paths, and customer alerts.',
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
                                  'Global shop controls, payment QR paths, and customer alerts.',
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
                          labelText: 'Slot 3: Complimentary Delivery Highlight',
                          prefixIcon: Icon(Icons.local_shipping_outlined, size: 18),
                          border: OutlineInputBorder(),
                          isDense: true,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 3: QR Image Settings
                  _buildCard(
                    title: 'Merchant QR Image Settings (GCash & QRPh)',
                    children: [
                      isMobile
                          ? Column(
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
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _qrphQrController,
                                  focusNode: _qrphQrFocus,
                                  decoration: const InputDecoration(
                                    labelText: 'QRPh Asset / URL',
                                    hintText: 'assets/images/qrph_qr.png',
                                    prefixIcon: Icon(Icons.account_balance, size: 18),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextField(
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
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: _qrphQrController,
                                    focusNode: _qrphQrFocus,
                                    decoration: const InputDecoration(
                                      labelText: 'QRPh Asset / URL',
                                      hintText: 'assets/images/qrph_qr.png',
                                      prefixIcon: Icon(Icons.account_balance, size: 18),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                      const SizedBox(height: 16),
                      isMobile
                          ? Column(
                              children: [
                                _buildSwitchTile(
                                  'Enable Cash on Delivery (COD)',
                                  'Rider collects cash upon doorstep delivery',
                                  _enableCod,
                                  (v) => setState(() => _enableCod = v),
                                ),
                                const Divider(color: borderLight, height: 16),
                                _buildSwitchTile(
                                  'Enable GCash & QRPh',
                                  'Accept verified GCash and QRPh scans',
                                  _enableEwallet,
                                  (v) => setState(() => _enableEwallet = v),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: _buildSwitchTile(
                                    'Enable Cash on Delivery (COD)',
                                    'Rider collects cash upon doorstep delivery',
                                    _enableCod,
                                    (v) => setState(() => _enableCod = v),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: _buildSwitchTile(
                                    'Enable GCash & QRPh',
                                    'Accept verified GCash and QRPh scans',
                                    _enableEwallet,
                                    (v) => setState(() => _enableEwallet = v),
                                  ),
                                ),
                              ],
                            ),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Section 4: Dual Delivery Speed Rates
                  _buildCard(
                    title: 'Fulfillment & Delivery Fees',
                    children: [
                      isMobile
                          ? Column(
                              children: [
                                TextField(
                                  controller: _standardDeliveryFeeController,
                                  focusNode: _standardDeliveryFeeFocus,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Standard / Express Fee (₱)',
                                    helperText: 'On-demand express (25-35 mins)',
                                    prefixIcon: Icon(Icons.bolt, size: 18),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _scheduledDeliveryFeeController,
                                  focusNode: _scheduledDeliveryFeeFocus,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Scheduled Batch Fee (₱)',
                                    helperText: 'Consolidated batch drop route',
                                    prefixIcon: Icon(Icons.schedule, size: 18),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: _freeDeliveryMinController,
                                  focusNode: _freeDeliveryMinFocus,
                                  keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                  decoration: const InputDecoration(
                                    labelText: 'Free Delivery Threshold (₱)',
                                    helperText: 'Threshold for ₱0 delivery',
                                    prefixIcon: Icon(Icons.savings_outlined, size: 18),
                                    border: OutlineInputBorder(),
                                    isDense: true,
                                  ),
                                ),
                              ],
                            )
                          : Row(
                              children: [
                                Expanded(
                                  child: TextField(
                                    controller: _standardDeliveryFeeController,
                                    focusNode: _standardDeliveryFeeFocus,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Standard / Express Fee (₱)',
                                      helperText: 'On-demand express (25-35 mins)',
                                      prefixIcon: Icon(Icons.bolt, size: 18),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: _scheduledDeliveryFeeController,
                                    focusNode: _scheduledDeliveryFeeFocus,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Scheduled Batch Fee (₱)',
                                      helperText: 'Consolidated batch drop route',
                                      prefixIcon: Icon(Icons.schedule, size: 18),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 14),
                                Expanded(
                                  child: TextField(
                                    controller: _freeDeliveryMinController,
                                    focusNode: _freeDeliveryMinFocus,
                                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                                    decoration: const InputDecoration(
                                      labelText: 'Free Delivery Threshold (₱)',
                                      helperText: 'Threshold for ₱0 delivery',
                                      prefixIcon: Icon(Icons.savings_outlined, size: 18),
                                      border: OutlineInputBorder(),
                                      isDense: true,
                                    ),
                                  ),
                                ),
                              ],
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
import 'package:flutter/material.dart';

class SettingsModal extends StatefulWidget {
  final bool nutFreeFilter;
  final String sweetnessLevel;
  final bool ecoPackaging;
  final Function(bool nutFree, String sweetness, bool eco) onSave;

  const SettingsModal({
    super.key,
    required this.nutFreeFilter,
    required this.sweetnessLevel,
    required this.ecoPackaging,
    required this.onSave,
  });

  @override
  State<SettingsModal> createState() => _SettingsModalState();
}

class _SettingsModalState extends State<SettingsModal> {
  late bool _nutFree;
  late String _sweetness;
  late bool _eco;

  @override
  void initState() {
    super.initState();
    _nutFree = widget.nutFreeFilter;
    _sweetness = widget.sweetnessLevel;
    _eco = widget.ecoPackaging;
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.white,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 440),
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Header
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: const [
                      Icon(Icons.tune_rounded, color: Color(0xFF8E4A23)),
                      SizedBox(width: 10),
                      Text(
                        'Bake Preferences',
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                          color: Color(0xFF2E1B10),
                        ),
                      ),
                    ],
                  ),
                  IconButton(
                    icon: const Icon(Icons.close, size: 20),
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const Divider(color: Color(0xFFEFE4D6), height: 24),

              // Nut Allergy Toggle
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF8E4A23),
                title: const Text(
                  'Highlight Nut-Free Only',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Filters out cookies and cakes with walnuts & pecans',
                  style: TextStyle(fontSize: 12),
                ),
                value: _nutFree,
                onChanged: (val) => setState(() => _nutFree = val),
              ),
              const SizedBox(height: 12),

              // Sweetness Level Preference
              const Text(
                'Default Sweetness Level',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
              ),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8,
                children: ['100% Regular Sweet', '70% Less Sweet (Balanced)']
                    .map(
                      (level) => ChoiceChip(
                        label: Text(level),
                        selected: _sweetness == level,
                        selectedColor: const Color(0xFF3C2216),
                        backgroundColor: const Color(0xFFFAF6F0),
                        labelStyle: TextStyle(
                          color: _sweetness == level
                              ? Colors.white
                              : const Color(0xFF3C2216),
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                        ),
                        onSelected: (_) => setState(() => _sweetness = level),
                      ),
                    )
                    .toList(),
              ),
              const SizedBox(height: 16),

              // Eco packaging
              SwitchListTile(
                contentPadding: EdgeInsets.zero,
                activeColor: const Color(0xFF8E4A23),
                title: const Text(
                  'Eco-Friendly Bag & Tray',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                ),
                subtitle: const Text(
                  'Skip disposable plastic cutleries and candles',
                  style: TextStyle(fontSize: 12),
                ),
                value: _eco,
                onChanged: (val) => setState(() => _eco = val),
              ),
              const SizedBox(height: 24),

              // Save Button
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF8E4A23),
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 14),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                  onPressed: () {
                    widget.onSave(_nutFree, _sweetness, _eco);
                    Navigator.pop(context);
                  },
                  child: const Text(
                    'Save Preferences',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

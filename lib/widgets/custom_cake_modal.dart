import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:flutter/foundation.dart';
import '../models/product.dart';
import 'cake_radius_visualizer.dart';
import '../theme/app_colors.dart';

class CustomCakeModal extends StatefulWidget {
  final Product baseProduct;
  final Product? initialProduct;
  final Function(Product) onAddCustomCake;

  const CustomCakeModal({
    super.key,
    required this.baseProduct,
    this.initialProduct,
    required this.onAddCustomCake,
  });

  @override
  State<CustomCakeModal> createState() => _CustomCakeModalState();
}

class _CustomCakeModalState extends State<CustomCakeModal> {
  bool get _isStandardCake =>
      widget.baseProduct.price == 800.0 || widget.baseProduct.name.contains('Pure Decadence');
  bool get _isOneTierCake => 
      widget.baseProduct.price == 1450.0 || widget.baseProduct.name.contains('Vanilla Sky');

  late String _selectedSize;
  late Map<String, double> _sizeOptions;

  String _selectedBase = 'Chocolate';
  String _selectedFrosting = 'Chocolate';

  final TextEditingController _pipingMessageController =
      TextEditingController();
  final TextEditingController _customNotesController = TextEditingController();
  final ImagePicker _imagePicker = ImagePicker();
  Uint8List? _preferredImageBytes;
  String? _preferredImageName;

  @override
  void initState() {
    super.initState();
    if (_isStandardCake) {
      _sizeOptions = {
        '6" x 2" Inches': 800.0,
        '6" x 4" Inches': 1000.0,
        '8" x 2" Inches': 1000.0,
        '8" x 4" Inches': 1200.0,
      };
    } else if (_isOneTierCake) {
      _sizeOptions = {
        '6" x 2" Inches (1 Layer)': 1450.0,
        '6" x 4" Inches (1 Layer)': 1650.0,
        '8" x 2" Inches (1 Layer)': 1650.0,
        '8" x 4" Inches (1 Layer)': 1850.0,
      };
    } else {
      // Lavender Noir (2 Tier)
      _sizeOptions = {
        '6" x 2" Inches (2 Layers)': 2500.0,
        '6" x 4" Inches (2 Layers)': 3000.0,
      };
    }
    _selectedSize = _sizeOptions.keys.first;

    if (widget.initialProduct != null) {
      _parseInitialProduct(widget.initialProduct!);
    }
  }

  void _parseInitialProduct(Product initialProduct) {
    final desc = initialProduct.description;
    final parts = desc.split(' • ');
    for (final part in parts) {
      if (part.startsWith('Dimensions:')) {
        final sizeStr = part.replaceFirst('Dimensions:', '').trim();
        if (_sizeOptions.containsKey(sizeStr)) {
          _selectedSize = sizeStr;
        }
      } else if (part.startsWith('Base:')) {
        final baseStr = part.replaceFirst('Base:', '').trim();
        if (_baseOptions.contains(baseStr)) {
          _selectedBase = baseStr;
        }
      } else if (part.startsWith('Icing:')) {
        final icingStr = part.replaceFirst('Icing:', '').replaceAll('(Included)', '').trim();
        if (_frostingOptions.contains(icingStr)) {
          _selectedFrosting = icingStr;
        }
      } else if (part.startsWith('Piping:')) {
        final pipingStr = part.replaceFirst('Piping:', '').trim().replaceAll('"', '');
        _pipingMessageController.text = pipingStr;
      } else if (part.startsWith('Notes:')) {
        final notesStr = part.replaceFirst('Notes:', '').trim();
        _customNotesController.text = notesStr;
      }
    }
    _preferredImageBytes = initialProduct.customImageBytes;
    if (_preferredImageBytes != null) {
      _preferredImageName = 'Attached Image';
    }
  }

  double get _calculatedTotal => _sizeOptions[_selectedSize] ?? 800.0;

  final List<String> _baseOptions = ['Chocolate', 'Vanilla', 'Ube'];
  final List<String> _frostingOptions = ['Chocolate', 'Vanilla'];

  void _handleAddCustomCake() {
    final customDescription = StringBuffer();
    customDescription.write(
      'Dimensions: $_selectedSize • Base: $_selectedBase • Icing: $_selectedFrosting (Included)',
    );

    if (_pipingMessageController.text.trim().isNotEmpty) {
      customDescription.write(
        ' • Piping: "${_pipingMessageController.text.trim()}"',
      );
    }
    if (_customNotesController.text.trim().isNotEmpty) {
      customDescription.write(
        ' • Notes: ${_customNotesController.text.trim()}',
      );
    }

    final customizedCake = Product(
      id: 'custom_${DateTime.now().millisecondsSinceEpoch}',
      name: widget.baseProduct.name,
      category: 'cakes',
      price: _calculatedTotal,
      description: customDescription.toString(),
      imgSrc: widget.baseProduct.imgSrc,
      icon: '🎂',
      customImageBytes: _preferredImageBytes,
    );

    widget.onAddCustomCake(customizedCake);
    
    // If it was opened from cart to edit, we don't need to show success banner usually,
    // but showing it is fine or parent handles it.
    Navigator.pop(context);
  }

  Future<void> _pickPreferredImage() async {
    final image = await _imagePicker.pickImage(
      source: ImageSource.gallery,
      imageQuality: 85,
    );
    if (image == null) return;

    final bytes = await image.readAsBytes();
    if (!mounted) return;
    setState(() {
      _preferredImageBytes = bytes;
      _preferredImageName = image.name;
    });
  }

  @override
  void dispose() {
    _pipingMessageController.dispose();
    _customNotesController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final isDesktopOrTablet = mediaQuery.size.width >= 768;

    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(
        horizontal: isDesktopOrTablet ? 24 : 12,
        vertical: isDesktopOrTablet ? 24 : 16,
      ),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          maxWidth: isDesktopOrTablet ? 1100 : 540,
          maxHeight: mediaQuery.size.height * 0.92,
        ),
        child: Container(
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(24),
            border: Border.all(color: AppColors.bgPastelPink),
            boxShadow: [
              BoxShadow(
                color: AppColors.darkGarnet.withValues(alpha: 0.18),
                blurRadius: 30,
                offset: const Offset(0, 12),
              ),
            ],
          ),
          clipBehavior: Clip.antiAlias,
          child: isDesktopOrTablet
              ? _buildSideBySideLayout()
              : _buildStackedMobileLayout(),
        ),
      ),
    );
  }

  /// Desktop / Tablet: Full width side-by-side split layout
  Widget _buildSideBySideLayout() {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // Left Column: Hero Cake Showcase
        Expanded(flex: 5, child: _buildHeroShowcase(isSplit: true)),

        // Vertical divider
        Container(width: 1, color: AppColors.bgPastelPink),

        // Right Column: Customizer Configuration Panel
        Expanded(
          flex: 6,
          child: Column(
            children: [
              // Top header with title & close button
              _buildPanelHeader(),

              // Scrollable options form
              Expanded(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  child: _buildConfigurationForm(),
                ),
              ),

              // Bottom sticky action bar
              _buildBottomActionBar(),
            ],
          ),
        ),
      ],
    );
  }

  /// Mobile: Vertical stacked layout fallback
  Widget _buildStackedMobileLayout() {
    return Column(
      children: [
        // Top banner showcase
        SizedBox(height: 180, child: _buildHeroShowcase(isSplit: false)),

        // Scrollable configuration
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(18),
            child: _buildConfigurationForm(),
          ),
        ),

        // Bottom sticky action bar
        _buildBottomActionBar(),
      ],
    );
  }

  /// Hero Showcase (Image, badges & details)
  Widget _buildHeroShowcase({required bool isSplit}) {
    return Stack(
      fit: StackFit.expand,
      children: [
        // Cake Main Image
        widget.baseProduct.imgSrc.startsWith('http')
            ? Image.network(
                widget.baseProduct.imgSrc,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) =>
                    _buildFallbackShowcase(),
              )
            : (widget.baseProduct.imgSrc.isNotEmpty
                  ? Image.asset(
                      widget.baseProduct.imgSrc,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) =>
                          _buildFallbackShowcase(),
                    )
                  : _buildFallbackShowcase()),

        // Dark gradient overlays for high legibility
        Positioned.fill(
          child: DecoratedBox(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.black.withValues(alpha: 0.40),
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withValues(alpha: 0.85),
                ],
                stops: const [0.0, 0.25, 0.55, 1.0],
              ),
            ),
          ),
        ),

        // Close button on mobile banner
        if (!isSplit)
          Positioned(
            top: 12,
            right: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                shape: BoxShape.circle,
              ),
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 20),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

        // Expand image button on mobile banner
        if (!isSplit)
          Positioned(
            top: 12,
            left: 12,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.black.withValues(alpha: 0.55),
                borderRadius: BorderRadius.circular(20),
              ),
              child: Material(
                color: Colors.transparent,
                child: InkWell(
                  borderRadius: BorderRadius.circular(20),
                  onTap: () => _showFullScreenImage(context),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 12,
                      vertical: 6,
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: const [
                        Icon(Icons.zoom_out_map, color: Colors.white, size: 16),
                        SizedBox(width: 6),
                        Text(
                          'View Full',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ),
          ),

        // Bottom text info over image
        Positioned(
          bottom: 20,
          left: 20,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                widget.baseProduct.name,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  shadows: [
                    Shadow(
                      color: Colors.black87,
                      blurRadius: 8,
                      offset: Offset(0, 2),
                    ),
                  ],
                ),
              ),
              if (widget.baseProduct.description.isNotEmpty) ...[
                const SizedBox(height: 6),
                Text(
                  widget.baseProduct.description,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.92),
                    fontSize: 12.5,
                    height: 1.3,
                  ),
                ),
              ],
              if (_preferredImageBytes != null) ...[
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 6,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.92),
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withValues(alpha: 0.2),
                        blurRadius: 6,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: Image.memory(
                          _preferredImageBytes!,
                          width: 28,
                          height: 28,
                          fit: BoxFit.cover,
                        ),
                      ),
                      const SizedBox(width: 8),
                      const Text(
                        'Reference photo attached ✓',
                        style: TextStyle(
                          color: AppColors.darkGarnet,
                          fontWeight: FontWeight.bold,
                          fontSize: 11.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }

  void _showFullScreenImage(BuildContext context) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        pageBuilder: (BuildContext context, _, __) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: Stack(
              children: [
                Center(
                  child: InteractiveViewer(
                    panEnabled: true,
                    minScale: 1.0,
                    maxScale: 4.0,
                    child: widget.baseProduct.imgSrc.startsWith('http')
                        ? Image.network(widget.baseProduct.imgSrc)
                        : (widget.baseProduct.imgSrc.isNotEmpty
                              ? Image.asset(widget.baseProduct.imgSrc)
                              : _buildFallbackShowcase()),
                  ),
                ),
                Positioned(
                  top: MediaQuery.of(context).padding.top + 10,
                  right: 20,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.55),
                      shape: BoxShape.circle,
                    ),
                    child: IconButton(
                      icon: const Icon(
                        Icons.close,
                        color: Colors.white,
                        size: 24,
                      ),
                      onPressed: () => Navigator.pop(context),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildFallbackShowcase() {
    return Container(
      color: AppColors.bgPastelPink,
      child: const Center(
        child: Icon(Icons.cake, size: 64, color: AppColors.textDarkBerry),
      ),
    );
  }

  /// Right panel header
  Widget _buildPanelHeader() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 18),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(bottom: BorderSide(color: AppColors.bgPastelPink)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Customize Your Cake',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w900,
                  color: AppColors.darkGarnet,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                'Personalize size, base, icing & decorations',
                style: TextStyle(
                  fontSize: 12,
                  color: AppColors.textDarkBerry.withValues(alpha: 0.9),
                ),
              ),
            ],
          ),
          Container(
            decoration: BoxDecoration(
              color: AppColors.bgPastelPink,
              shape: BoxShape.circle,
            ),
            child: IconButton(
              icon: const Icon(Icons.close, color: AppColors.darkGarnet, size: 20),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  /// All Cake customization controls & forms
  Widget _buildConfigurationForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // 1. Cake Size & Dimensions
        _sectionTitle('1. Cake Size & Dimensions'),
        const SizedBox(height: 10),
        CakeRadiusVisualizer(
          selectedSize: _selectedSize,
          availableSizes: _sizeOptions.keys.toList(),
          onSelectSize: (newSize) {
            setState(() => _selectedSize = newSize);
          },
        ),
        const SizedBox(height: 14),

        // Size radio cards
        ..._sizeOptions.entries.map((entry) {
          final isSelected = _selectedSize == entry.key;
          final is8Inch = entry.key.contains('8"');
          return Container(
            margin: const EdgeInsets.only(bottom: 8),
            decoration: BoxDecoration(
              color: isSelected ? AppColors.bgPastelPink : Colors.white,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(
                color: isSelected
                    ? AppColors.textDarkBerry
                    : AppColors.bgPastelPink,
                width: isSelected ? 1.5 : 1.0,
              ),
            ),
            child: InkWell(
              onTap: () {
                setState(() => _selectedSize = entry.key);
              },
              borderRadius: BorderRadius.circular(12),
              child: Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 12,
                ),
                child: Row(
                  children: [
                    // Radio Dot
                    Container(
                      width: 20,
                      height: 20,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: isSelected
                              ? AppColors.textDarkBerry
                              : AppColors.brandRed,
                          width: 2,
                        ),
                      ),
                      child: isSelected
                          ? Center(
                              child: Container(
                                width: 10,
                                height: 10,
                                decoration: const BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: AppColors.textDarkBerry,
                                ),
                              ),
                            )
                          : null,
                    ),
                    const SizedBox(width: 12),

                    // Title and subtitle
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            entry.key,
                            style: const TextStyle(
                              fontSize: 13.5,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkGarnet,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            is8Inch
                                ? 'Serves ~10–14 • 8" diameter (20 cm)'
                                : 'Serves ~4–6 • 6" diameter (15 cm)',
                            style: TextStyle(
                              fontSize: 11,
                              color: isSelected
                                  ? const Color(
                                      0xFF2E151A,
                                    ).withValues(alpha: 0.85)
                                  : AppColors.brandRed,
                            ),
                          ),
                        ],
                      ),
                    ),

                    // Price
                    Text(
                      '₱${entry.value.toStringAsFixed(0)}',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: isSelected
                            ? AppColors.textDarkBerry
                            : AppColors.textDarkBerry,
                        fontSize: 14,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          );
        }),

        const SizedBox(height: 18),

        // 2. Cake Base
        _sectionTitle('2. Cake Base Flavor'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _baseOptions.map((base) {
            final isSelected = _selectedBase == base;
            return ChoiceChip(
              label: Text(base),
              selected: isSelected,
              selectedColor: AppColors.brandRed,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGarnet,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedBase = base);
                }
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 18),

        // 3. Flavor Icing
        _sectionTitle('3. Flavor Icing'),
        const SizedBox(height: 10),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: _frostingOptions.map((frosting) {
            final isSelected = _selectedFrosting == frosting;
            return ChoiceChip(
              label: Text(frosting),
              selected: isSelected,
              selectedColor: AppColors.brandRed,
              backgroundColor: Colors.white,
              labelStyle: TextStyle(
                color: isSelected ? Colors.white : AppColors.darkGarnet,
                fontWeight: isSelected ? FontWeight.bold : FontWeight.w500,
                fontSize: 12.5,
              ),
              onSelected: (selected) {
                if (selected) {
                  setState(() => _selectedFrosting = frosting);
                }
              },
            );
          }).toList(),
        ),

        const SizedBox(height: 18),

        // 4. Cake Piping Message
        _sectionTitle('4. Cake Piping Message / Inscription'),
        const SizedBox(height: 8),
        TextField(
          controller: _pipingMessageController,
          maxLength: 35,
          decoration: InputDecoration(
            hintText: 'e.g. Happy Birthday Mai! 🎂',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 14,
              vertical: 12,
            ),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bgPastelPink),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bgPastelPink),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textDarkBerry,
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 14),

        // 5. Special Baking Instructions
        _sectionTitle('5. Special Baking Instructions'),
        const SizedBox(height: 8),
        TextField(
          controller: _customNotesController,
          maxLines: 3,
          decoration: InputDecoration(
            hintText:
                'e.g. Less sweet frosting, color theme preferences, specific toppings...',
            filled: true,
            fillColor: Colors.white,
            contentPadding: const EdgeInsets.all(14),
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bgPastelPink),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.bgPastelPink),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(
                color: AppColors.textDarkBerry,
                width: 1.5,
              ),
            ),
          ),
        ),

        const SizedBox(height: 18),

        // 6. Preferred Cake Reference Image
        _sectionTitle('6. Preferred Reference Image (Optional)'),
        const SizedBox(height: 8),
        _buildImagePickerControl(),

        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: AppColors.bgPastelPink,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.bgPastelPink),
          ),
          child: Row(
            children: [
              const Icon(
                Icons.calendar_month_outlined,
                size: 18,
                color: AppColors.textDarkBerry,
              ),
              const SizedBox(width: 10),
              const Expanded(
                child: Text(
                  'Custom cakes require at least 2-week reservation notice before delivery.',
                  style: TextStyle(
                    fontSize: 11.5,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textDarkBerry,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  /// Bottom sticky action bar
  Widget _buildBottomActionBar() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 16),
      decoration: const BoxDecoration(
        color: Colors.white,
        border: Border(top: BorderSide(color: AppColors.bgPastelPink)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              const Text(
                'Total Cake Price',
                style: TextStyle(fontSize: 11.5, color: AppColors.textDarkBerry),
              ),
              Text(
                '₱${_calculatedTotal.toStringAsFixed(2)}',
                style: const TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w900,
                  color: AppColors.textDarkBerry,
                ),
              ),
            ],
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.brandRed,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              elevation: 2,
            ),
            onPressed: _handleAddCustomCake,
            icon: const Icon(Icons.add_shopping_cart, size: 16),
            label: const Text(
              'Add Cake to Tray',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13.5),
            ),
          ),
        ],
      ),
    );
  }

  Widget _sectionTitle(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontWeight: FontWeight.w800,
        fontSize: 13.5,
        color: AppColors.darkGarnet,
      ),
    );
  }

  Widget _buildImagePickerControl() {
    return InkWell(
      onTap: _pickPreferredImage,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: AppColors.bgPastelPink,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: _preferredImageBytes != null
                ? AppColors.textDarkBerry
                : AppColors.bgPastelPink,
          ),
        ),
        child: Row(
          children: [
            if (_preferredImageBytes != null) ...[
              ClipRRect(
                borderRadius: BorderRadius.circular(8),
                child: SizedBox(
                  width: 42,
                  height: 42,
                  child: Image.memory(_preferredImageBytes!, fit: BoxFit.cover),
                ),
              ),
              const SizedBox(width: 12),
            ] else ...[
              const Icon(
                Icons.add_photo_alternate_outlined,
                color: AppColors.textDarkBerry,
              ),
              const SizedBox(width: 10),
            ],
            Expanded(
              child: Text(
                _preferredImageName ??
                    'Upload sample cake photo from gallery...',
                style: const TextStyle(fontSize: 13, color: AppColors.textDarkBerry),
                overflow: TextOverflow.ellipsis,
              ),
            ),
            if (_preferredImageBytes != null)
              IconButton(
                icon: const Icon(
                  Icons.delete_outline,
                  color: AppColors.textDarkBerry,
                  size: 20,
                ),
                onPressed: () {
                  setState(() {
                    _preferredImageBytes = null;
                    _preferredImageName = null;
                  });
                },
              ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';
import '../data/mock_products.dart';
import 'package:url_launcher/url_launcher.dart';
import 'order_tracker_modal.dart';
import 'dart:convert';
import 'dart:typed_data'; // Add this for Uint8List
import 'package:image_picker/image_picker.dart';
import 'package:firebase_messaging/firebase_messaging.dart';

class CustomerProfileModal extends StatefulWidget {
  final Set<String> favorites;
  final Function(Product) onAddToCart;
  final VoidCallback onLogout;
  final Function(Product) onToggleFavorite;
  final Function(Product, bool) onCustomize;
  final bool acceptCustomCakes;
  final VoidCallback onOpenCart;
  final String currentName;
  final String currentPhone;
  final String currentAddress;
  final Function(String, String, String) onProfileUpdated;
  
  // Add these two properties:
  final Uint8List? initialImageBytes;
  final Function(Uint8List?)? onImageUpdated;

  const CustomerProfileModal({
    super.key,
    required this.favorites,
    required this.onAddToCart,
    required this.onLogout,
    required this.onToggleFavorite,
    required this.onCustomize,
    required this.acceptCustomCakes,
    required this.onOpenCart,
    required this.currentName,
    required this.currentPhone,
    required this.currentAddress,
    required this.onProfileUpdated,
    this.initialImageBytes,
    this.onImageUpdated,
  });

  @override
  State<CustomerProfileModal> createState() => _CustomerProfileModalState();
}

enum ProfileViewState {
  main,
  settings,
  editProfile,
  editAddress,
  addressPicker,
  faq,
  review,
  about,
}

class _CustomerProfileModalState extends State<CustomerProfileModal>
    with SingleTickerProviderStateMixin {
  static const Color _espresso = Color(0xFF251811);
  static const Color _cocoa = Color(0xFF8C4A27);
  static const Color _muted = Color(0xFF7A6559);
  static const Color _border = Color(0xFFEFE4D6);
  static const Color _blush = Color(0xFFFBEBE4);
  static const Color _cream = Color(0xFFFDFBF7);
  static const Color _errorRed = Color(0xFFD9381E);

  late TabController _tabController;
  List<Product> _products = List.from(mockProducts);

  final String _userId = FirebaseAuth.instance.currentUser?.uid ?? '';

  ProfileViewState _currentView = ProfileViewState.main;
  bool _isSaving = false;
  bool _showZipError = false;

  bool _pushNotifications = true;
  String _selectedTheme = 'Light Mode';

  bool _showNotificationOverlay = false;
  bool _pendingNotificationState = true;
  bool _showContactOverlay = false;

  late TextEditingController _nameController;
  late TextEditingController _phoneController;
  late TextEditingController _emailController;

  late TextEditingController _streetController;
  late TextEditingController _zipCodeController;
  late TextEditingController _landmarkController;

  String _selectedRegion = '';
  String _selectedCity = '';
  String _selectedBarangay = '';
  String? _activeDropdownField;

  final GlobalKey<ScaffoldMessengerState> _scaffoldMessengerKey = GlobalKey<ScaffoldMessengerState>();

  // Web-safe image byte states (avoids Image.file crashes on web)
  Uint8List? _profileImageBytes;
  Uint8List? _coverImageBytes;

  // Web and mobile safe image picker method
  Future<void> _pickImage(bool isCover) async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(
      source: ImageSource.gallery,
      maxWidth: 512,
      maxHeight: 512,
      imageQuality: 80,
    );
    
    if (image != null) {
      final bytes = await image.readAsBytes();
      setState(() {
        if (isCover) {
          _coverImageBytes = bytes;
        } else {
          _profileImageBytes = bytes;
          // Instantly send the new bytes back to your main screen parent widget!
          widget.onImageUpdated?.call(bytes);
        }
      });

      if (!isCover && _userId.isNotEmpty) {
        try {
          final base64String = base64Encode(bytes);
          await FirebaseFirestore.instance.collection('users').doc(_userId).set({
            'photoBase64': base64String,
          }, SetOptions(merge: true));
        } catch (e) {
          debugPrint('Error saving profile photo to Firestore: $e');
        }
      }
    }
  }

  final Map<String, Map<String, List<String>>> _deliveryData = {
    'Cavite': {
      'Imus': [
        'Alapan I-A', 'Alapan I-B', 'Alapan I-C', 'Alapan II-A', 'Alapan II-B',
        'Anabu I-A', 'Anabu I-B', 'Anabu I-C', 'Anabu I-D', 'Anabu I-E', 'Anabu I-F', 'Anabu I-G',
        'Anabu II-A', 'Anabu II-B', 'Anabu II-C', 'Anabu II-D', 'Anabu II-E', 'Anabu II-F',
        'Bagong Silang (Bahayang Pag-Asa)', 'Bayan Luma I', 'Bayan Luma II', 'Bayan Luma III',
        'Bayan Luma IV', 'Bayan Luma V', 'Bayan Luma VI', 'Bayan Luma VII', 'Bayan Luma VIII', 'Bayan Luma IX',
        'Bucandala I', 'Bucandala II', 'Bucandala III', 'Bucandala IV', 'Bucandala V',
        'Buhay na Tubig', 'Carsadang Bago I', 'Carsadang Bago II', 'Magdalo', 'Maharlika',
        'Malagasang I-A', 'Malagasang I-B', 'Malagasang I-C', 'Malagasang I-D', 'Malagasang I-E', 'Malagasang I-F', 'Malagasang I-G',
        'Malagasang II-A', 'Malagasang II-B', 'Malagasang II-C', 'Malagasang II-D', 'Malagasang II-E', 'Malagasang II-F', 'Malagasang II-G',
        'Mariano Espeleta I', 'Mariano Espeleta II', 'Mariano Espeleta III',
        'Medicion I-A', 'Medicion I-B', 'Medicion I-C', 'Medicion I-D',
        'Medicion II-A', 'Medicion II-B', 'Medicion II-C', 'Medicion II-D', 'Medicion II-E', 'Medicion II-F',
        'Pag-Asa I', 'Pag-Asa II', 'Pag-Asa III', 'Palico I', 'Palico II', 'Palico III', 'Palico IV',
        'Pasong Buaya I', 'Pasong Buaya II', 'Pinagbuklod',
        'Poblacion I-A', 'Poblacion I-B', 'Poblacion I-C', 'Poblacion II-A', 'Poblacion II-B',
        'Poblacion III-A', 'Poblacion III-B', 'Poblacion IV-A', 'Poblacion IV-B', 'Poblacion IV-C', 'Poblacion IV-D',
        'Tanzang Luma I', 'Tanzang Luma II', 'Tanzang Luma III', 'Tanzang Luma IV (Southern City)', 'Tanzang Luma V', 'Tanzang Luma VI',
        'Toclong I-A', 'Toclong I-B', 'Toclong I-C', 'Toclong II-A', 'Toclong II-B',
        'Other (Specify in Street)',
      ],
      'Bacoor': [
        'Alima', 'Aniban I', 'Aniban II', 'Bayanan', 'Camposanto', 'Daang Bukid', 'Digman', 'Dulong Bayan',
        'Habay I', 'Habay II', 'Kaingin', 'Ligas I', 'Ligas II', 'Mabolo', 'Maliksi', 'Mambog I', 'Mambog II',
        'Molino I', 'Molino II', 'Molino III', 'Molino IV', 'Molino V', 'Molino VI', 'Molino VII',
        'Niog I', 'Niog II', 'Panapaan I', 'Panapaan II', 'Queens Row Central', 'Queens Row East', 'Queens Row West',
        'Real I', 'Real II', 'Salinas I', 'Salinas II', 'San Nicolas', 'Sineguelasan', 'Tabing Dagat',
        'Talaba I', 'Talaba II', 'Zapote I', 'Zapote II', 'Other (Specify in Street)',
      ],
      'Dasmariñas': [
        'Burol', 'Datu Esmael', 'Emmanuel Bergado', 'Fatima', 'Langkaan I', 'Langkaan II', 'Luzviminda',
        'Paliparan I', 'Paliparan II', 'Paliparan III', 'Sabang', 'Salawag', 'Salitran I', 'Salitran II',
        'Salitran III', 'Salitran IV', 'Sampaloc I', 'Sampaloc II', 'San Agustin', 'San Antonio',
        'San Dionisio', 'San Jose', 'San Simon', 'Other (Specify in Street)',
      ],
      'General Trias': [
        'Bacao I', 'Bacao II', 'Biclatan', 'Buenavista I', 'Buenavista II', 'Corregidor', 'Manggahan',
        'Navarro', 'Panungyanan', 'Pasong Camachile I', 'Pasong Camachile II', 'Pasong Kawayan I',
        'Pasong Kawayan II', 'Pinagtipunan', 'San Francisco', 'San Juan I', 'San Juan II', 'Tejero', 'Other (Specify in Street)',
      ],
      'Kawit': [
        'Batong Dalig', 'Binakayan', 'Congbalay', 'Gahak', 'Manggahan', 'Marulas', 'Panamitan', 'Poblacion',
        'Putol', 'San Sebastian', 'Santa Isabel', 'Toclong', 'Tramo', 'Wakasi', 'Other (Specify in Street)',
      ],
      'Silang': [
        'Adlas', 'Balite', 'Biga', 'Biluso', 'Bucal', 'Bulihan', 'Cabangaan', 'Carmen', 'Hoyo', 'Inchican',
        'Lalaan I', 'Lalaan II', 'Litlit', 'Lucsuhin', 'Lumil', 'Maguyam', 'Munting Ilog', 'Paligawan',
        'Pasong Langka', 'Pooc', 'Puting Kahoy', 'Sabutan', 'San Miguel', 'San Vicente', 'Tartaria',
        'Tibig', 'Tubuan I', 'Tubuan II', 'Other (Specify in Street)',
      ],
      'Tagaytay': [
        'Asisan', 'Bagong Tubig', 'Calabuso', 'Dapdap', 'Guinhawa', 'Iruhin', 'Mag-Asawang Ilat', 'Maharlika',
        'Mendez Crossing East', 'Mendez Crossing West', 'Neogan', 'Patutong Malaki', 'Sambong', 'San Jose',
        'Silang Junction', 'Sungay', 'Tolentino', 'Zambal', 'Other (Specify in Street)',
      ],
      'Trece Martires': [
        'Aguado', 'Cabezas', 'Conchu', 'De Ocampo', 'Gregorio', 'Inocencio', 'Lallana', 'Osorio',
        'Perez', 'San Agustin', 'Other (Specify in Street)',
      ],
      'Alfonso': ['Other (Specify in Street)'],
      'Amadeo': ['Other (Specify in Street)'],
      'Carmona': ['Other (Specify in Street)'],
      'Cavite City': ['Other (Specify in Street)'],
      'General Emilio Aguinaldo': ['Other (Specify in Street)'],
      'General Mariano Alvarez': ['Other (Specify in Street)'],
      'Indang': ['Other (Specify in Street)'],
      'Magallanes': ['Other (Specify in Street)'],
      'Maragondon': ['Other (Specify in Street)'],
      'Mendez': ['Other (Specify in Street)'],
      'Naic': ['Other (Specify in Street)'],
      'Noveleta': ['Other (Specify in Street)'],
      'Rosario': ['Other (Specify in Street)'],
      'Tanza': ['Other (Specify in Street)'],
      'Ternate': ['Other (Specify in Street)'],
    },
    'Metro Manila': {
      'Las Piñas': [
        'Almanza Dos', 'Almanza Uno', 'B.F. International Village', 'Daniel Fajardo', 'Elias Aldana', 'Ilaya',
        'Manuyo Dos', 'Manuyo Uno', 'Pamplona Dos', 'Pamplona Tres', 'Pamplona Uno', 'Pilar',
        'Pulang Lupa Dos', 'Pulang Lupa Uno', 'Talon Dos', 'Talon Kuatro', 'Talon Singko', 'Talon Tres', 'Talon Uno', 'Zapote', 'Other (Specify in Street)',
      ],
      'Makati': [
        'Bangkal', 'Bel-Air', 'Carmona', 'Cembo', 'Comembo', 'Dasmariñas', 'East Rembo', 'Forbes Park',
        'Guadalupe Nuevo', 'Guadalupe Viejo', 'Kasilawan', 'La Paz', 'Magallanes', 'Olympia', 'Palanan', 'Pembo',
        'Pinagkaisahan', 'Pio del Pilar', 'Pitogo', 'Poblacion', 'Post Proper Northside', 'Post Proper Southside',
        'Rizal', 'San Antonio', 'San Isidro', 'San Lorenzo', 'Santa Cruz', 'Singkamas', 'South Cembo', 'Tejeros',
        'Urdaneta', 'Valenzuela', 'West Rembo', 'Other (Specify in Street)',
      ],
      'Manila': [
        'Ermita', 'Malate', 'Paco', 'Pandacan', 'San Andres', 'Other (Specify in Street)',
      ],
      'Muntinlupa': [
        'Alabang', 'Ayala Alabang', 'Bayanan', 'Buli', 'Cupang', 'Poblacion', 'Putatan', 'Sucat', 'Tunasan', 'Other (Specify in Street)',
      ],
      'Parañaque': [
        'B.F. Homes', 'Baclaran', 'Don Bosco', 'Don Galo', 'La Huerta', 'Marcelo Green', 'Merville',
        'Moonwalk', 'San Antonio', 'San Dionisio', 'San Isidro', 'San Martin de Porres', 'Santo Niño',
        'Sun Valley', 'Tambo', 'Vitalez', 'Other (Specify in Street)',
      ],
      'Pasay': [
        ...List.generate(201, (i) => 'Barangay ${i + 1}'),
        'Other (Specify in Street)',
      ],
      'Taguig (BGC)': [
        'Bagumbayan', 'Bambang', 'Calzada', 'Central Bicutan', 'Central Signal Village', 'Fort Bonifacio',
        'Hagonoy', 'Ibayo-Tipas', 'Katuparan', 'Ligid-Tipas', 'Lower Bicutan', 'Maharlika Village', 'Napindan',
        'New Lower Bicutan', 'North Daang Hari', 'North Signal Village', 'Palingon', 'Pinagsama', 'San Miguel',
        'Santa Ana', 'South Daang Hari', 'South Signal Village', 'Tanyag', 'Tuktukan', 'Upper Bicutan', 'Ususan',
        'Wawa', 'Western Bicutan', 'Other (Specify in Street)',
      ],
    },
  };

  String _reviewOrderId = '';
  String _reviewProductName = '';
  int _reviewRating = 0;
  final TextEditingController _reviewCommentController = TextEditingController();
  bool _isSubmittingReview = false;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _nameController = TextEditingController(text: widget.currentName);
    _phoneController = TextEditingController(text: widget.currentPhone);
    _emailController = TextEditingController(text: FirebaseAuth.instance.currentUser?.email ?? '');

    // Initialize with passed image bytes if available
    _profileImageBytes = widget.initialImageBytes;

    if (_profileImageBytes == null && _userId.isNotEmpty) {
      FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .get()
          .then((doc) {
        if (doc.exists && doc.data() != null) {
          final photoBase64 = doc.data()!['photoBase64'] as String?;
          if (photoBase64 != null && photoBase64.isNotEmpty && mounted) {
            try {
              final bytes = base64Decode(photoBase64);
              setState(() {
                _profileImageBytes = bytes;
              });
              widget.onImageUpdated?.call(bytes);
            } catch (e) {
              debugPrint('Error decoding photoBase64: $e');
            }
          }
        }
      }).catchError((_) {});
    }

    _streetController = TextEditingController();
    _zipCodeController = TextEditingController();
    _landmarkController = TextEditingController();

    if (widget.currentAddress.isNotEmpty) {
      _streetController.text = widget.currentAddress;
      bool found = false;

      for (String region in _deliveryData.keys) {
        for (String city in _deliveryData[region]!.keys) {
          List<String> brgys = List.from(_deliveryData[region]![city]!);
          brgys.sort((a, b) => b.length.compareTo(a.length));

          for (String brgy in brgys) {
            if (widget.currentAddress.contains(brgy) &&
                widget.currentAddress.contains(city)) {
              _selectedRegion = region;
              _selectedCity = city;
              _selectedBarangay = brgy;

              String cleanedStreet = widget.currentAddress
                  .replaceAll(', $region', '')
                  .replaceAll(', $city', '')
                  .replaceAll(', $brgy', '')
                  .trim();

              if (cleanedStreet.endsWith(',')) {
                cleanedStreet = cleanedStreet
                    .substring(0, cleanedStreet.length - 1)
                    .trim();
              }

              _streetController.text = cleanedStreet;
              found = true;
              break;
            }
          }
          if (found) break;
        }
        if (found) break;
      }
    }

    _loadProducts();
    _loadSettings();
  }

  void _loadSettings() async {
    if (_userId.isEmpty) return;
    try {
      final doc = await FirebaseFirestore.instance.collection('users').doc(_userId).get();
      if (doc.exists && mounted) {
        setState(() {
          _pushNotifications = doc.data()?['pushEnabled'] ?? false;
        });
      }
    } catch (e) {
      debugPrint('Error loading settings: $e');
    }
  }

  Future<void> _togglePushNotifications(bool value) async {
    if (_userId.isEmpty) return;

    setState(() => _pushNotifications = value);

    try {
      if (value) {
        FirebaseMessaging messaging = FirebaseMessaging.instance;
        NotificationSettings settings = await messaging.requestPermission(
          alert: true,
          badge: true,
          sound: true,
        );

        if (settings.authorizationStatus == AuthorizationStatus.authorized ||
            settings.authorizationStatus == AuthorizationStatus.provisional) {
          
          // Get the FCM token
          String? token = await messaging.getToken(
            vapidKey: 'BNzZLFx_EE4fwl7FVkg-K2aDZtUfYfM5Nd6VUqQgjTkr8uwiLvjk4eIYBTCUjrrU0VFR4IVFE3u9pkWo2lI_d60',
          );
          
          if (token != null) {
            await FirebaseFirestore.instance.collection('users').doc(_userId).set({
              'pushEnabled': true,
              'fcmToken': token,
            }, SetOptions(merge: true));
          } else {
            if (mounted) setState(() => _pushNotifications = false);
          }
        } else {
          // User denied permission
          if (mounted) setState(() => _pushNotifications = false);
        }
      } else {
        await FirebaseFirestore.instance.collection('users').doc(_userId).set({
          'pushEnabled': false,
          'fcmToken': FieldValue.delete(),
        }, SetOptions(merge: true));
      }
    } catch (e) {
      debugPrint('Error toggling push notifications: $e');
      if (mounted) setState(() => _pushNotifications = !value);
    }
  }

  @override
  void didUpdateWidget(covariant CustomerProfileModal oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.initialImageBytes != oldWidget.initialImageBytes) {
      setState(() {
        _profileImageBytes = widget.initialImageBytes;
      });
    }
    if (widget.currentName != oldWidget.currentName) {
      _nameController.text = widget.currentName;
    }
    if (widget.currentPhone != oldWidget.currentPhone) {
      _phoneController.text = widget.currentPhone;
    }
  }

  Future<void> _loadProducts() async {
    try {
      final snapshot = await FirebaseFirestore.instance
          .collection('products')
          .get();
      if (snapshot.docs.isNotEmpty && mounted) {
        setState(() {
          _products = snapshot.docs
              .map((doc) => Product.fromMap(doc.id, doc.data()))
              .toList();
        });
      }
    } catch (e) {
      debugPrint('Error loading products for modal: $e');
    }
  }

  @override
  void dispose() {
    _tabController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _streetController.dispose();
    _zipCodeController.dispose();
    _landmarkController.dispose();
    _reviewCommentController.dispose();
    super.dispose();
  }

  String _getFormattedAddress() {
    String brgy = _selectedBarangay.startsWith('Other') ? '' : _selectedBarangay;
    String city = _selectedCity.startsWith('Other') ? '' : _selectedCity;
    String region = _selectedRegion.startsWith('Other') ? '' : _selectedRegion;

    final parts = [
      _streetController.text.trim(),
      _landmarkController.text.trim(),
      brgy,
      city,
      region,
      _zipCodeController.text.trim(),
    ].where((part) => part.isNotEmpty).toList();

    return parts.join(', ');
  }

  Future<void> _saveProfile({
    ProfileViewState returnTo = ProfileViewState.settings,
  }) async {
    if (_userId.isEmpty) return;

    final zipCode = _zipCodeController.text.trim();
    final street = _streetController.text.trim();

    if (returnTo == ProfileViewState.editProfile ||
        returnTo == ProfileViewState.settings) {
      if (_selectedBarangay.isNotEmpty ||
          street.isNotEmpty ||
          zipCode.isNotEmpty) {
        if (zipCode.isEmpty) {
          setState(() {
            _showZipError = true;
            if (_currentView != ProfileViewState.editAddress) {
              _currentView = ProfileViewState.editAddress;
            }
          });
          return;
        }
      }
    }

    setState(() {
      _showZipError = false;
      _isSaving = true;
    });

    final newName = _nameController.text.trim();
    final newPhone = _phoneController.text.trim();
    final newAddress = _getFormattedAddress();

    try {
      final user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        final newEmail = _emailController.text.trim();
        if (newEmail.isNotEmpty && newEmail != user.email) {
          try {
            await user.verifyBeforeUpdateEmail(newEmail);
            if (mounted) {
              _scaffoldMessengerKey.currentState?.showSnackBar(
                const SnackBar(
                  content: Text('Verification email sent to new address. Please verify to complete the update.'),
                  backgroundColor: Color(0xFF4CAF50),
                  behavior: SnackBarBehavior.floating,
                ),
              );
            }
          } on FirebaseAuthException catch (e) {
            if (e.code == 'requires-recent-login') {
              if (mounted) {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  const SnackBar(
                    content: Text('Please log out and log back in to change your email for security reasons.'),
                    backgroundColor: Color(0xFFD32F2F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            } else {
              if (mounted) {
                _scaffoldMessengerKey.currentState?.showSnackBar(
                  SnackBar(
                    content: Text('Error updating email: ${e.message}'),
                    backgroundColor: const Color(0xFFD32F2F),
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            }
          }
        }
      }

      final Map<String, dynamic> updateData = {
        'name': newName,
        'phone': newPhone,
        'address': newAddress,
      };
      if (_profileImageBytes != null) {
        updateData['photoBase64'] = base64Encode(_profileImageBytes!);
      }

      await FirebaseFirestore.instance
          .collection('users')
          .doc(_userId)
          .set(updateData, SetOptions(merge: true));

      widget.onProfileUpdated(newName, newPhone, newAddress);

      if (mounted) {
        setState(() {
          _isSaving = false;
          _currentView = returnTo;
        });
      }
    } catch (e) {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isMobile = screenWidth < 600;
    final drawerWidth = isMobile ? screenWidth : 420.0;
    final leftRadius = isMobile ? 0.0 : 24.0;

    return SizedBox(
      width: drawerWidth,
      child: Material(
        color: Colors.transparent,
        elevation: 24,
        shadowColor: Colors.black26,
        borderRadius: BorderRadius.horizontal(left: Radius.circular(leftRadius)),
        child: ClipRRect(
          borderRadius: BorderRadius.horizontal(
            left: Radius.circular(leftRadius),
          ),
          child: ScaffoldMessenger(
            key: _scaffoldMessengerKey,
            child: Scaffold(
              backgroundColor: Colors.transparent,
              body: Stack(
                children: [
                  Container(
                    height: MediaQuery.of(context).size.height,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Color(0xFFFFFBF7),
                          Color(0xFFFAF4ED),
                          Color(0xFFF5EDDF),
                        ],
                      ),
                      borderRadius: BorderRadius.horizontal(
                        left: Radius.circular(leftRadius),
                      ),
                    ),
                    child: SafeArea(
                      child: Column(
                        children: [
                          _buildHeader(),
                          const SizedBox(height: 10),
                          Expanded(
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 350),
                              switchInCurve: Curves.easeOutCubic,
                              switchOutCurve: Curves.easeInCubic,
                              transitionBuilder:
                                  (Widget child, Animation<double> animation) {
                                final offsetAnimation = Tween<Offset>(
                                  begin:
                                      child.key == const ValueKey('mainView')
                                          ? const Offset(-1.0, 0.0)
                                          : const Offset(1.0, 0.0),
                                  end: Offset.zero,
                                ).animate(animation);
                                return SlideTransition(
                                  position: offsetAnimation,
                                  child: child,
                                );
                              },
                              child: switch (_currentView) {
                                ProfileViewState.settings =>
                                  _buildSettingsView(),
                                ProfileViewState.editProfile =>
                                  _buildEditProfileView(),
                                ProfileViewState.editAddress =>
                                  _buildEditAddressView(),
                                ProfileViewState.addressPicker =>
                                  _buildAddressPickerView(),
                                ProfileViewState.faq => _buildFaqSubView(),
                                ProfileViewState.review =>
                                  _buildReviewSubView(),
                                ProfileViewState.about => _buildAboutSubView(),
                                ProfileViewState.main => _buildMainView(),
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                  if (_showContactOverlay)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            constraints: const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _border, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: _espresso.withOpacity(0.12),
                                  blurRadius: 20,
                                  offset: const Offset(0, 8),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 56,
                                  height: 56,
                                  decoration: BoxDecoration(
                                    color: _blush,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _border),
                                  ),
                                  child: const Center(
                                    child: Text(
                                      '💬',
                                      style: TextStyle(fontSize: 26),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                const Text(
                                  'Chat with NyseBites',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontWeight: FontWeight.w800,
                                    color: _espresso,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Reach out via our hotline or message us directly on Facebook for custom cake inquiries!',
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontSize: 13,
                                    color: _muted,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 18),
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    vertical: 12,
                                    horizontal: 16,
                                  ),
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(16),
                                    border: Border.all(color: _border),
                                  ),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: const [
                                      Icon(
                                        Icons.phone_in_talk_rounded,
                                        color: _cocoa,
                                        size: 18,
                                      ),
                                      SizedBox(width: 10),
                                      Text(
                                        '0995-082-9180',
                                        style: TextStyle(
                                          fontWeight: FontWeight.w800,
                                          fontSize: 14,
                                          color: _espresso,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(height: 10),
                                SizedBox(
                                  width: double.infinity,
                                  child: OutlinedButton.icon(
                                    onPressed: () async {
                                      final Uri fbUri = Uri.parse(
                                        'https://www.facebook.com/NYSEbites',
                                      );
                                      if (await canLaunchUrl(fbUri)) {
                                        await launchUrl(
                                          fbUri,
                                          mode: LaunchMode.externalApplication,
                                        );
                                      }
                                    },
                                    icon: const Icon(
                                      Icons.facebook_rounded,
                                      color: Color(0xFF1877F2),
                                      size: 20,
                                    ),
                                    label: const Text(
                                      'Message on Facebook',
                                      style: TextStyle(
                                        color: _espresso,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
                                      ),
                                    ),
                                    style: OutlinedButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      side: const BorderSide(
                                        color: Color(0xFF1877F2),
                                        width: 1.2,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      backgroundColor: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 16),
                                SizedBox(
                                  width: double.infinity,
                                  child: FilledButton(
                                    onPressed: () => setState(
                                      () => _showContactOverlay = false,
                                    ),
                                    style: FilledButton.styleFrom(
                                      padding: const EdgeInsets.symmetric(
                                        vertical: 12,
                                      ),
                                      backgroundColor: _cocoa,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(14),
                                      ),
                                      elevation: 0,
                                    ),
                                    child: const Text(
                                      'Close 🧁',
                                      style: TextStyle(
                                        color: Colors.white,
                                        fontWeight: FontWeight.w800,
                                        fontSize: 13.5,
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

                  if (_showNotificationOverlay)
                    Positioned.fill(
                      child: Container(
                        color: Colors.black.withOpacity(0.35),
                        child: Center(
                          child: Container(
                            margin: const EdgeInsets.symmetric(horizontal: 24),
                            constraints: const BoxConstraints(maxWidth: 340),
                            padding: const EdgeInsets.all(22),
                            decoration: BoxDecoration(
                              color: _cream,
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: _border, width: 1.5),
                              boxShadow: [
                                BoxShadow(
                                  color: _espresso.withOpacity(0.15),
                                  blurRadius: 16,
                                  offset: const Offset(0, 6),
                                ),
                              ],
                            ),
                            child: Column(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  width: 48,
                                  height: 48,
                                  decoration: BoxDecoration(
                                    color: _blush,
                                    shape: BoxShape.circle,
                                    border: Border.all(color: _border),
                                  ),
                                  child: Center(
                                    child: Text(
                                      _pendingNotificationState ? '🔔' : '🔕',
                                      style: const TextStyle(fontSize: 22),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                Text(
                                  _pendingNotificationState
                                      ? 'Enable Order & Batch Alerts?'
                                      : 'Turn off Notifications?',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 15.5,
                                    fontWeight: FontWeight.w800,
                                    color: _espresso,
                                  ),
                                ),
                                const SizedBox(height: 6),
                                Text(
                                  _pendingNotificationState
                                      ? 'Get notified immediately for order tracker updates, out-for-delivery status, and fresh oven batches! 🍪'
                                      : 'You will miss out on live order tracking and fresh batch updates.',
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    fontSize: 12,
                                    color: _muted,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: TextButton(
                                        onPressed: () {
                                          setState(
                                            () => _showNotificationOverlay =
                                                false,
                                          );
                                        },
                                        style: TextButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                            side: const BorderSide(
                                              color: _border,
                                            ),
                                          ),
                                          backgroundColor: Colors.white,
                                        ),
                                        child: const Text(
                                          'Cancel',
                                          style: TextStyle(
                                            color: _muted,
                                            fontWeight: FontWeight.w700,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(width: 10),
                                    Expanded(
                                      child: FilledButton(
                                        onPressed: () {
                                          setState(() {
                                            _pushNotifications =
                                                _pendingNotificationState;
                                            _showNotificationOverlay = false;
                                          });
                                        },
                                        style: FilledButton.styleFrom(
                                          padding: const EdgeInsets.symmetric(
                                            vertical: 12,
                                          ),
                                          backgroundColor:
                                              _pendingNotificationState
                                                  ? _cocoa
                                                  : _espresso,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                              12,
                                            ),
                                          ),
                                          elevation: 0,
                                        ),
                                        child: Text(
                                          _pendingNotificationState
                                              ? 'Turn On 🧁'
                                              : 'Turn Off',
                                          style: const TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w800,
                                            fontSize: 13,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
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
    );
  }

  Widget _buildHeader() {
    return GestureDetector(
      onTap: () => setState(() => _currentView = ProfileViewState.settings),
      child: Container(
        margin: const EdgeInsets.fromLTRB(16, 10, 16, 0),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          gradient: const LinearGradient(
            colors: [Color(0xFF3C2216), Color(0xFF5A3420)],
          ),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            // Real-time updating avatar container
            Container(
              width: 42,
              height: 42,
              decoration: BoxDecoration(
                color: const Color(0xFFE5B976),
                borderRadius: BorderRadius.circular(12),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: _profileImageBytes != null
                    ? Image.memory(_profileImageBytes!, fit: BoxFit.cover)
                    : Center(
                        child: Text(
                          widget.currentName.isNotEmpty
                              ? widget.currentName[0].toUpperCase()
                              : 'G',
                          style: const TextStyle(
                            color: Color(0xFF3C2216),
                            fontWeight: FontWeight.w900,
                            fontSize: 18,
                          ),
                        ),
                      ),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Welcome back! 🧁',
                    style: TextStyle(
                      color: Color(0xFFE5D5C5),
                      fontSize: 10.5,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  const SizedBox(height: 1),
                  Text(
                    widget.currentName,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 2),
                  const Text(
                    'Tap to open profile & settings ✨',
                    style: TextStyle(
                      color: Color(0xFFF3E7DC),
                      fontSize: 9.5,
                      fontWeight: FontWeight.w500,
                      fontStyle: FontStyle.italic,
                    ),
                  ),
                ],
              ),
            ),
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: IconButton(
                padding: EdgeInsets.zero,
                icon: const Icon(
                  Icons.close_rounded,
                  color: Color(0xFFE5D5C5),
                  size: 16,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMainView() {
    return Column(
      key: const ValueKey('mainView'),
      children: [
        Container(
          height: 42,
          margin: const EdgeInsets.symmetric(horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFFF0E4D6),
            borderRadius: BorderRadius.circular(21),
            border: Border.all(color: const Color(0xFFE5D5C5), width: 1),
          ),
          child: TabBar(
            controller: _tabController,
            indicator: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF9E5528), Color(0xFF8E4A23)],
              ),
              borderRadius: BorderRadius.circular(21),
              boxShadow: [
                BoxShadow(
                  color: const Color(0xFF8E4A23).withOpacity(0.35),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerColor: Colors.transparent,
            labelColor: Colors.white,
            unselectedLabelColor: const Color(0xFF8E4A23),
            labelStyle: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 13,
              letterSpacing: -0.2,
            ),
            unselectedLabelStyle: const TextStyle(
              fontWeight: FontWeight.w600,
              fontSize: 13,
            ),
            tabs: const [
              Tab(text: '♡  Favorites'),
              Tab(text: '📋  Orders'),
            ],
          ),
        ),
        const SizedBox(height: 6),
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildFavoritesTab(), _buildOrderHistoryTab()],
          ),
        ),
      ],
    );
  }

  // ── SETTINGS VIEW (Optimized for Mobile Spacing) ──
  Widget _buildSettingsView() {
    return Column(
      key: const ValueKey('settingsView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _currentView = ProfileViewState.main),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _espresso,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'App Settings',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _espresso,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 12),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              _buildSettingsSection(
                title: 'Personal Information',
                children: [
                  _buildSettingsTile(
                    icon: Icons.person_outline_rounded,
                    title: 'Edit Profile',
                    subtitle: 'Email, address, and contact details',
                    onTap: () => setState(
                      () => _currentView = ProfileViewState.editProfile,
                    ),
                  ),
                  _buildSettingsTile(
                    icon: Icons.lock_outline_rounded,
                    title: 'Change Password',
                    subtitle: 'Send a secure reset link to your email',
                    disabled: false,
                    onTap: () async {
                      final userEmail = FirebaseAuth.instance.currentUser?.email;
                      if (userEmail != null && userEmail.isNotEmpty) {
                        try {
                          await FirebaseAuth.instance.sendPasswordResetEmail(
                            email: userEmail,
                            actionCodeSettings: ActionCodeSettings(
                              url: 'https://nyse-bites.web.app/reset-password',
                              handleCodeInApp: true,
                            ),
                          );
                          if (mounted) {
                            _scaffoldMessengerKey.currentState?.showSnackBar(
                              const SnackBar(
                                content: Text('Password reset email sent! Please check your inbox.'),
                                backgroundColor: Color(0xFF4CAF50),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        } catch (e) {
                          if (mounted) {
                            _scaffoldMessengerKey.currentState?.showSnackBar(
                              SnackBar(
                                content: Text('Failed to send reset email: $e'),
                                backgroundColor: const Color(0xFFD32F2F),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                          }
                        }
                      } else {
                        if (mounted) {
                          _scaffoldMessengerKey.currentState?.showSnackBar(
                            const SnackBar(
                              content: Text('No email found for your account.'),
                              backgroundColor: Color(0xFFD32F2F),
                              behavior: SnackBarBehavior.floating,
                            ),
                          );
                        }
                      }
                    },
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildSettingsSection(
                title: 'App Settings',
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 8.5,
                    ),
                    child: Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(5),
                          decoration: BoxDecoration(
                            color: const Color(0xFFF0E4D6),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.notifications_active_rounded,
                            color: _cocoa,
                            size: 16,
                          ),
                        ),
                        const SizedBox(width: 12),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Push Notifications',
                                style: TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w700,
                                  color: _espresso,
                                ),
                              ),
                              SizedBox(height: 1),
                              Text(
                                'Get updates on your order',
                                style: TextStyle(
                                  fontSize: 11,
                                  color: _muted,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Transform.scale(
                          scale: 0.8,
                          child: Switch(
                            value: _pushNotifications,
                            activeColor: Colors.white,
                            activeTrackColor: _cocoa,
                            inactiveThumbColor: Colors.white,
                            inactiveTrackColor: _border,
                            onChanged: _userId.isEmpty ? null : _togglePushNotifications,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Container(height: 1, color: _border),
                  _buildSettingsTile(
                    icon: Icons.palette_rounded,
                    title: 'Theme & Appearance',
                    subtitle: 'Temporarily unavailable',
                    disabled: true,
                    onTap: null,
                  ),
                ],
              ),
              const SizedBox(height: 14),

              _buildSettingsSection(
                title: 'Help & Support',
                children: [
                  _buildSettingsTile(
                    icon: Icons.support_agent_rounded,
                    title: 'Contact NyseBites',
                    onTap: () => setState(() => _showContactOverlay = true),
                  ),
                  _buildSettingsTile(
                    icon: Icons.info_outline_rounded,
                    title: 'About NyseBites',
                    onTap: () =>
                        setState(() => _currentView = ProfileViewState.about),
                  ),
                  _buildSettingsTile(
                    icon: Icons.help_outline_rounded,
                    title: 'Help Center & FAQs',
                    onTap: () =>
                        setState(() => _currentView = ProfileViewState.faq),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              SizedBox(
                width: double.infinity,
                child: TextButton.icon(
                  onPressed: () {
                    Navigator.pop(context);
                    widget.onLogout();
                  },
                  icon: const Icon(
                    Icons.logout_rounded,
                    size: 16,
                    color: _muted,
                  ),
                  label: const Text(
                    'Sign Out',
                    style: TextStyle(
                      fontWeight: FontWeight.w700,
                      fontSize: 13,
                      color: _espresso,
                    ),
                  ),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 11),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                      side: const BorderSide(color: _border, width: 1.5),
                    ),
                    elevation: 0,
                  ),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildSettingsSection({
    required String title,
    required List<Widget> children,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 4),
          child: Text(
            title.toUpperCase(),
            style: const TextStyle(
              fontSize: 9.5,
              fontWeight: FontWeight.w800,
              color: _muted,
              letterSpacing: 0.5,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
          ),
          child: Column(children: children),
        ),
      ],
    );
  }

  Widget _buildSettingsTile({
    required IconData icon,
    required String title,
    String? subtitle,
    VoidCallback? onTap,
    bool disabled = false,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: disabled ? null : onTap,
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 14,
            vertical: 8.5,
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.all(5),
                decoration: BoxDecoration(
                  color: disabled ? Colors.grey.shade200 : _blush,
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(
                  icon,
                  size: 16,
                  color: disabled ? _muted.withOpacity(0.5) : _cocoa,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                        color: disabled ? _muted.withOpacity(0.6) : _espresso,
                      ),
                    ),
                    if (subtitle != null) ...[
                      const SizedBox(height: 1),
                      Text(
                        subtitle,
                        style: TextStyle(
                          fontSize: 11,
                          color: disabled ? _muted.withOpacity(0.5) : _muted,
                          fontStyle: disabled
                              ? FontStyle.italic
                              : FontStyle.normal,
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              if (!disabled)
                const Icon(Icons.chevron_right_rounded, color: _muted, size: 16)
              else
                Text(
                  'Maintenance',
                  style: TextStyle(
                    fontSize: 10.5,
                    color: _muted.withOpacity(0.6),
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildAboutSubView() {
    return Column(
      key: const ValueKey('aboutSubView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _currentView = ProfileViewState.settings),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _espresso,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'About NyseBites 🤎',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _espresso,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _espresso.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Container(
                      width: 64,
                      height: 64,
                      padding: const EdgeInsets.all(3),
                      decoration: BoxDecoration(
                        color: const Color(0xFFF3E7DC),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFE5D5C5),
                          width: 1.5,
                        ),
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(12),
                        child: Image.asset(
                          'assets/images/logo.jpg',
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => const Icon(
                            Icons.cookie,
                            color: Color(0xFF8E4A23),
                            size: 32,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    const Text(
                      'EST. 2024 • NYSE Bites',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.2,
                        color: _cocoa,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Nyse Bites is a local bakeshop founded in 2024, dedicated to crafting fresh, small-batch cookies, dense fudge brownies, and custom celebration cakes daily from scratch using 100% pure premium dairy butter and high-grade chocolates. 🤎✨',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: _muted,
                        fontSize: 13,
                        height: 1.5,
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 16),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: _border),
                  boxShadow: [
                    BoxShadow(
                      color: _espresso.withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    const Text(
                      'LET\'S CONNECT & COLLAB 💌',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: _muted,
                        letterSpacing: 0.8,
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      'Follow our sweet journey on social media or reach out to us for brand collaborations and features!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 12.5,
                        color: _muted,
                        height: 1.4,
                      ),
                    ),
                    const SizedBox(height: 16),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final Uri fbUri = Uri.parse(
                                'https://www.facebook.com/NYSEbites',
                              );
                              if (await canLaunchUrl(fbUri)) {
                                await launchUrl(
                                  fbUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.facebook_rounded,
                              color: Color(0xFF1877F2),
                              size: 16,
                            ),
                            label: const Text(
                              'Facebook',
                              style: TextStyle(
                                color: _espresso,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(
                                color: Color(0xFF1877F2),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: OutlinedButton.icon(
                            onPressed: () async {
                              final Uri igUri = Uri.parse(
                                'https://www.instagram.com/nysebites',
                              );
                              if (await canLaunchUrl(igUri)) {
                                await launchUrl(
                                  igUri,
                                  mode: LaunchMode.externalApplication,
                                );
                              }
                            },
                            icon: const Icon(
                              Icons.camera_alt_rounded,
                              color: Color(0xFFE1306C),
                              size: 16,
                            ),
                            label: const Text(
                              'Instagram',
                              style: TextStyle(
                                color: _espresso,
                                fontWeight: FontWeight.w800,
                                fontSize: 12,
                              ),
                            ),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 10),
                              side: const BorderSide(
                                color: Color(0xFFE1306C),
                                width: 1.2,
                              ),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              backgroundColor: Colors.white,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditProfileView() {
    return Column(
      key: const ValueKey('editProfileView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _currentView = ProfileViewState.settings),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _espresso,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Edit Profile',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _espresso,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              // ── UNIFIED CONTAINER CARD ──
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: const Color(0xFFEFE4D6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF251811).withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    // ── STOREFRONT COLOR HALF-BLOCK & OVERLAPPING AVATAR ──
                    SizedBox(
                      height: 85, // Half-height block matching your storefront vibe
                      width: double.infinity,
                      child: Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.topCenter,
                        children: [
                          // Brand-colored background half-block
                          ClipRRect(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(22),
                            ),
                            child: Container(
                              height: 55,
                              width: double.infinity,
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [Color(0xFF3C2216), Color(0xFF5A3420)], // Matches your storefront header theme
                                  begin: Alignment.topLeft,
                                  end: Alignment.bottomRight,
                                ),
                              ),
                            ),
                          ),
                          // Clickable Profile Avatar overlapping precisely in the center
                          Positioned(
                            top: 16,
                            child: GestureDetector(
                              onTap: () => _pickImage(false),
                              child: Stack(
                                alignment: Alignment.bottomRight,
                                children: [
                                  Container(
                                    width: 72,
                                    height: 72,
                                    padding: const EdgeInsets.all(3),
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 3,
                                      ),
                                      color: const Color(0xFFF3E7DC),
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.black.withOpacity(0.1),
                                          blurRadius: 6,
                                          offset: const Offset(0, 3),
                                        ),
                                      ],
                                    ),
                                    child: ClipOval(
                                      child: _profileImageBytes != null
                                          ? Image.memory(
                                              _profileImageBytes!,
                                              fit: BoxFit.cover,
                                            )
                                          : Center(
                                              child: Text(
                                                widget.currentName.isNotEmpty
                                                    ? widget.currentName[0].toUpperCase()
                                                    : 'R',
                                                style: const TextStyle(
                                                  color: _cocoa,
                                                  fontWeight: FontWeight.w900,
                                                  fontSize: 26,
                                                ),
                                              ),
                                            ),
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.all(5),
                                    decoration: BoxDecoration(
                                      color: _cocoa,
                                      shape: BoxShape.circle,
                                      border: Border.all(
                                        color: Colors.white,
                                        width: 2,
                                      ),
                                    ),
                                    child: const Icon(
                                      Icons.camera_alt_rounded,
                                      size: 11,
                                      color: Colors.white,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 4),
                    // Live-syncing header name matching the text field
                    SizedBox(
                      width: double.infinity,
                      child: ListenableBuilder(
                        listenable: _nameController,
                        builder: (context, _) {
                          return Text(
                            _nameController.text.trim().isEmpty 
                                ? 'Mai Leonhart' 
                                : _nameController.text,
                            textAlign: TextAlign.center,
                            style: const TextStyle(
                              fontSize: 15,
                              fontWeight: FontWeight.w900,
                              color: _espresso,
                            ),
                          );
                        },
                      ),
                    ),
                    const SizedBox(height: 2),
                    const SizedBox(
                      width: double.infinity,
                      child: Text(
                        'NYSE Bites Member 🤎',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w600,
                          color: _muted,
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF5EDDF),
                      indent: 16,
                      endIndent: 16,
                    ),

                    // 1. Display Name Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _blush,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.person_outline_rounded,
                              size: 18,
                              color: _cocoa,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'DISPLAY NAME',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: _muted,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                TextField(
                                  controller: _nameController,
                                  onChanged: (_) => setState(() {}),
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _espresso,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your name',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFAAA09A),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.5,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF5EDDF),
                      indent: 16,
                      endIndent: 16,
                    ),

                    // 2. Phone Number Row
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _blush,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.phone_outlined,
                              size: 18,
                              color: _cocoa,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'PHONE NUMBER',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: _muted,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                Row(
                                  children: [
                                    const Text(
                                      '+63',
                                      style: TextStyle(
                                        fontWeight: FontWeight.w800,
                                        fontSize: 12.5,
                                        color: _cocoa,
                                      ),
                                    ),
                                    const SizedBox(width: 6),
                                    Expanded(
                                      child: TextField(
                                        controller: _phoneController,
                                        keyboardType: TextInputType.phone,
                                        maxLength: 11,
                                        inputFormatters: [
                                          FilteringTextInputFormatter.digitsOnly,
                                        ],
                                        style: const TextStyle(
                                          fontSize: 13.5,
                                          fontWeight: FontWeight.w600,
                                          color: _espresso,
                                        ),
                                        decoration: const InputDecoration(
                                          counterText: '',
                                          hintText: '0900 000 0000',
                                          hintStyle: TextStyle(
                                            color: Color(0xFFAAA09A),
                                            fontWeight: FontWeight.w500,
                                            fontSize: 13.5,
                                          ),
                                          border: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          focusedBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.zero,
                                          isDense: true,
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF5EDDF),
                      indent: 16,
                      endIndent: 16,
                    ),

                    // 2. Email Address Row (Below Name & Phone)
                    Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: _blush,
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.email_outlined,
                              size: 18,
                              color: _cocoa,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'EMAIL ADDRESS',
                                  style: TextStyle(
                                    fontSize: 9.5,
                                    fontWeight: FontWeight.w800,
                                    color: _muted,
                                    letterSpacing: 0.6,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                TextField(
                                  controller: _emailController,
                                  onChanged: (_) => setState(() {}),
                                  keyboardType: TextInputType.emailAddress,
                                  style: const TextStyle(
                                    fontSize: 13.5,
                                    fontWeight: FontWeight.w600,
                                    color: _espresso,
                                  ),
                                  decoration: const InputDecoration(
                                    hintText: 'Enter your email',
                                    hintStyle: TextStyle(
                                      color: Color(0xFFAAA09A),
                                      fontWeight: FontWeight.w500,
                                      fontSize: 13.5,
                                    ),
                                    border: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    focusedBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.zero,
                                    isDense: true,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Divider(
                      height: 1,
                      thickness: 1,
                      color: Color(0xFFF5EDDF),
                      indent: 16,
                      endIndent: 16,
                    ),

                    // 3. Delivery Address Row (Tappable)
                    InkWell(
                      onTap: () => setState(
                        () => _currentView = ProfileViewState.editAddress,
                      ),
                      borderRadius: const BorderRadius.vertical(
                        bottom: Radius.circular(22),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                color: _blush,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(
                                Icons.location_on_outlined,
                                size: 18,
                                color: _cocoa,
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  const Text(
                                    'DELIVERY ADDRESS',
                                    style: TextStyle(
                                      fontSize: 9.5,
                                      fontWeight: FontWeight.w800,
                                      color: _muted,
                                      letterSpacing: 0.6,
                                    ),
                                  ),
                                  const SizedBox(height: 2),
                                  Text(
                                    _getFormattedAddress().isNotEmpty
                                        ? _getFormattedAddress()
                                        : 'Tap to add delivery address',
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight:
                                          _getFormattedAddress().isNotEmpty
                                              ? FontWeight.w600
                                              : FontWeight.w500,
                                      color:
                                          _getFormattedAddress().isNotEmpty
                                              ? _espresso
                                              : const Color(0xFFAAA09A),
                                      height: 1.35,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Icon(
                              Icons.chevron_right_rounded,
                              color: Color(0xFFAAA09A),
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.0), const Color(0xFFFAF4ED)],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving
                  ? null
                  : () => _saveProfile(returnTo: ProfileViewState.settings),
              style: FilledButton.styleFrom(
                backgroundColor: _cocoa,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Changes',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFaqSubView() {
    return Column(
      key: const ValueKey('faqSubView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _currentView = ProfileViewState.settings),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _espresso,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              const Expanded(
                child: Text(
                  'Help Center & FAQs ❓',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w900,
                    color: _espresso,
                  ),
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFE4D6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF251811).withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: const [
                    _FaqItem(
                      question: 'How do I track my order?',
                      answer:
                          'You can track your live baking and delivery progress in real-time by heading to your profile drawer and opening the "Orders" tab, then tapping on your active order tracker! 📋',
                      showDivider: true,
                    ),
                    _FaqItem(
                      question: 'When do fresh cookie batches drop?',
                      answer:
                          'Our signature soft-baked cookies and fudgy brownies are baked fresh daily, with afternoon drops happening right around 02:00 PM! Turn on push notifications to catch them warm. 🍪',
                      showDivider: true,
                    ),
                    _FaqItem(
                      question: 'Can I customize my own celebration cake?',
                      answer:
                          'Yes! Tap on "Build Custom Cake" from the main menu to choose your tiers, fillings, frostings, and personalized theme designs. ✨',
                      showDivider: true,
                    ),
                    _FaqItem(
                      question: 'What are the payment and delivery details?',
                      answer:
                          'We exclusively accept GCash payments via our automated scanner portal. For delivery, we book via third-party couriers (such as GrabCar or Lalamove) to safely bring your treats to you. Please note that the delivery fee is not included in your app total and will be paid directly in cash to the rider upon arrival at your destination. 💳🚗',
                      showDivider: true,
                    ),
                    _FaqItem(
                      question: 'Can I cancel my order after placing it?',
                      answer:
                          'Since our treats are baked fresh daily and custom cakes require careful preparation, all submitted orders are final. There is no cancellation feature on the app, so please double-check your items before checking out! For any urgent concerns, please message our Facebook page directly. 🤎',
                      showDivider: true,
                    ),
                    _FaqItem(
                      question: 'How should I store my treats?',
                      answer:
                          'Our cookies and brownies are best enjoyed fresh, but they will stay perfectly delicious for up to 5 days in an airtight container at room temperature.',
                      showDivider: false,
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildEditAddressView() {
    return Column(
      key: const ValueKey('editAddressView'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: _border),
                ),
                child: IconButton(
                  onPressed: () =>
                      setState(() => _currentView = ProfileViewState.editProfile),
                  icon: const Icon(
                    Icons.arrow_back_rounded,
                    color: _espresso,
                    size: 18,
                  ),
                  padding: const EdgeInsets.all(6),
                  constraints: const BoxConstraints(),
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Delivery Address',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w900,
                  color: _espresso,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 13),
        Expanded(
          child: ListView(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: [
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: const Color(0xFFEFE4D6)),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFF251811).withOpacity(0.04),
                      blurRadius: 12,
                      offset: const Offset(0, 4),
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    _buildUnifiedDropdownRow(
                      hint: 'Select Region',
                      value: _selectedRegion,
                      showDivider: true,
                      onTap: () => setState(
                        () => _activeDropdownField =
                            _activeDropdownField == 'region' ? null : 'region',
                      ),
                    ),
                    if (_activeDropdownField == 'region')
                      _buildInlinePicker(
                        title: 'Region',
                        items: _deliveryData.keys.toList(),
                        selectedValue: _selectedRegion,
                        onSelect: (val) {
                          setState(() {
                            _selectedRegion = val;
                            _selectedCity = '';
                            _selectedBarangay = '';
                            _activeDropdownField = null;
                          });
                        },
                      ),
                    _buildUnifiedDropdownRow(
                      hint: 'Select City',
                      value: _selectedCity,
                      disabled: _selectedRegion.isEmpty,
                      showDivider: true,
                      onTap: () => setState(
                        () => _activeDropdownField =
                            _activeDropdownField == 'city' ? null : 'city',
                      ),
                    ),
                    if (_activeDropdownField == 'city' &&
                        _selectedRegion.isNotEmpty)
                      _buildInlinePicker(
                        title: 'City',
                        items: _deliveryData[_selectedRegion]!.keys.toList(),
                        selectedValue: _selectedCity,
                        onSelect: (val) {
                          setState(() {
                            _selectedCity = val;
                            _selectedBarangay = '';
                            _activeDropdownField = null;
                          });
                        },
                      ),
                    _buildUnifiedDropdownRow(
                      hint: 'Select Area / Barangay',
                      value: _selectedBarangay,
                      disabled: _selectedCity.isEmpty,
                      showDivider: false,
                      onTap: () => setState(
                        () => _activeDropdownField =
                            _activeDropdownField == 'barangay'
                                ? null
                                : 'barangay',
                      ),
                    ),
                    if (_activeDropdownField == 'barangay' &&
                        _selectedCity.isNotEmpty)
                      _buildInlinePicker(
                        title: 'Area / Barangay',
                        items: _deliveryData[_selectedRegion]![_selectedCity]!,
                        selectedValue: _selectedBarangay,
                        onSelect: (val) {
                          setState(() {
                            _selectedBarangay = val;
                            _activeDropdownField = null;
                          });
                        },
                      ),
                  ],
                ),
              ),

              const SizedBox(height: 13),

              _buildStandaloneTextFieldCard(
                label: 'Zip Code',
                controller: _zipCodeController,
                hint: 'Required, e.g. 4103',
                keyboardType: TextInputType.number,
                hasError: _showZipError,
                onChanged: (_) {
                  if (_showZipError) setState(() => _showZipError = false);
                },
              ),
              if (_showZipError)
                Padding(
                  padding: const EdgeInsets.only(top: 6, left: 4, bottom: 2),
                  child: Row(
                    children: const [
                      Icon(
                        Icons.error_outline_rounded,
                        color: _errorRed,
                        size: 14,
                      ),
                      SizedBox(width: 6),
                      Text(
                        'Please enter your Zip Code (e.g. 4103).',
                        style: TextStyle(
                          color: _errorRed,
                          fontSize: 12,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),

              const SizedBox(height: 13),

              _buildStandaloneTextFieldCard(
                label: 'Street Address',
                controller: _streetController,
                hint: 'Street Name, Building, House No.',
              ),

              const SizedBox(height: 13),

              _buildStandaloneTextFieldCard(
                label: 'Landmark / Unit Details',
                controller: _landmarkController,
                hint: 'e.g. Near the village gate / Unit 2B',
              ),
              const SizedBox(height: 13),
            ],
          ),
        ),
        Container(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 24),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Colors.white.withOpacity(0.0), const Color(0xFFFAF4ED)],
            ),
          ),
          child: SizedBox(
            width: double.infinity,
            child: FilledButton(
              onPressed: _isSaving
                  ? null
                  : () => _saveProfile(returnTo: ProfileViewState.editProfile),
              style: FilledButton.styleFrom(
                backgroundColor: _cocoa,
                padding: const EdgeInsets.symmetric(vertical: 14),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14),
                ),
              ),
              child: _isSaving
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        color: Colors.white,
                        strokeWidth: 2,
                      ),
                    )
                  : const Text(
                      'Save Address',
                      style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 14,
                      ),
                    ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildStandaloneTextFieldCard({
    required String label,
    required TextEditingController controller,
    required String hint,
    TextInputType? keyboardType,
    bool hasError = false,
    void Function(String)? onChanged,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 4, bottom: 6),
          child: Text(
            label.toUpperCase(),
            style: const TextStyle(
              fontSize: 10,
              fontWeight: FontWeight.w800,
              color: _muted,
              letterSpacing: 0.6,
            ),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(20),
            border: Border.all(
              color: hasError ? _errorRed : const Color(0xFFEFE4D6),
              width: hasError ? 1.5 : 1.0,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF251811).withOpacity(0.04),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: TextField(
              controller: controller,
              keyboardType: keyboardType,
              onChanged: onChanged,
              style: const TextStyle(
                fontSize: 13.5,
                fontWeight: FontWeight.w600,
                color: _espresso,
              ),
              decoration: InputDecoration(
                hintText: hint,
                hintStyle: TextStyle(
                  color: hasError
                      ? _errorRed.withOpacity(0.8)
                      : const Color(0xFFAAA09A),
                  fontWeight: FontWeight.w500,
                  fontSize: 13.5,
                ),
                filled: false,
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding: const EdgeInsets.symmetric(vertical: 12),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUnifiedDropdownRow({
    required String hint,
    required String value,
    required VoidCallback onTap,
    bool disabled = false,
    bool showDivider = true,
  }) {
    return Column(
      children: [
        InkWell(
          onTap: disabled ? null : onTap,
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    value.isNotEmpty ? value : hint,
                    style: TextStyle(
                      fontSize: 13.5,
                      fontWeight: value.isNotEmpty
                          ? FontWeight.w600
                          : FontWeight.w500,
                      color: disabled
                          ? const Color(0xFFD3C8BC)
                          : (value.isNotEmpty
                              ? _espresso
                              : const Color(0xFFAAA09A)),
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                Icon(
                  _activeDropdownField ==
                          hint.toLowerCase().replaceAll('select ', '').trim()
                      ? Icons.keyboard_arrow_up_rounded
                      : Icons.keyboard_arrow_down_rounded,
                  color: disabled ? const Color(0xFFD3C8BC) : _cocoa,
                  size: 20,
                ),
              ],
            ),
          ),
        ),
        if (showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF5EDDF),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }

  Widget _buildAddressPickerView() {
    return _buildEditAddressView();
  }

  Widget _buildInlinePicker({
    required String title,
    required List<String> items,
    required String selectedValue,
    required void Function(String) onSelect,
  }) {
    return Container(
      margin: const EdgeInsets.only(top: 6, bottom: 4),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: _border, width: 1.5),
        boxShadow: [
          BoxShadow(
            color: _espresso.withOpacity(0.06),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Padding(
                padding: const EdgeInsets.only(left: 4, top: 2),
                child: Text(
                  'Select $title 📍',
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _activeDropdownField = null),
                child: const Icon(Icons.close_rounded, size: 18, color: _muted),
              ),
            ],
          ),
          const SizedBox(height: 8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxHeight: 180),
            child: ListView.builder(
              shrinkWrap: true,
              physics: const BouncingScrollPhysics(),
              itemCount: items.length,
              itemBuilder: (context, index) {
                final item = items[index];
                final isSelected = item == selectedValue;
                return InkWell(
                  onTap: () => onSelect(item),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      vertical: 10,
                      horizontal: 12,
                    ),
                    decoration: BoxDecoration(
                      color: isSelected ? _blush : Colors.transparent,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Expanded(
                          child: Text(
                            item,
                            style: TextStyle(
                              fontSize: 13,
                              fontWeight: isSelected
                                  ? FontWeight.w800
                                  : FontWeight.w600,
                              color: isSelected ? _cocoa : _espresso,
                            ),
                          ),
                        ),
                        if (isSelected)
                          const Icon(
                            Icons.check_circle_rounded,
                            color: _cocoa,
                            size: 16,
                          ),
                      ],
                    ),
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFavoritesTab() {
    if (widget.favorites.isEmpty) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TweenAnimationBuilder<double>(
                tween: Tween(begin: 0.0, end: 1.0),
                duration: const Duration(milliseconds: 900),
                curve: Curves.elasticOut,
                builder: (context, value, child) =>
                    Transform.scale(scale: value, child: child),
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [Color(0xFFF8EDE0), Color(0xFFF0E0CC)],
                    ),
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: const Color(0xFFE5D5C5),
                      width: 1.5,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: const Color(0xFFE5D5C5).withOpacity(0.4),
                        blurRadius: 16,
                        offset: const Offset(0, 6),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text('🤎', style: TextStyle(fontSize: 32)),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text(
                'No favorites yet!',
                style: TextStyle(
                  fontSize: 17,
                  fontWeight: FontWeight.w800,
                  color: _espresso,
                  letterSpacing: -0.3,
                ),
              ),
              const SizedBox(height: 8),
              const Text(
                'Tap the ♡ on any treat to save\nyour sweet picks here!',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 13.5, color: _muted, height: 1.5),
              ),
            ],
          ),
        ),
      );
    }

    final favoriteProducts = _products
        .where((p) => widget.favorites.contains(p.id.toString()))
        .toList();

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
      itemCount: favoriteProducts.length,
      itemBuilder: (context, index) {
        final product = favoriteProducts[index];
        final isCake = product.category == 'cakes';
        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: _border),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFF3C2216).withOpacity(0.04),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Row(
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 64,
                  height: 64,
                  child: product.imgSrc.isNotEmpty
                      ? Image.asset(
                          product.imgSrc,
                          fit: BoxFit.cover,
                          errorBuilder: (_, __, ___) => Container(
                            color: const Color(0xFFF3E7DC),
                            child: const Center(
                              child: Text('🍪', style: TextStyle(fontSize: 24)),
                            ),
                          ),
                        )
                      : Container(
                          color: const Color(0xFFF3E7DC),
                          child: const Center(
                            child: Text('🍪', style: TextStyle(fontSize: 24)),
                          ),
                        ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      product.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _espresso,
                        fontSize: 13.5,
                        letterSpacing: -0.2,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    const SizedBox(height: 3),
                    Text(
                      '₱${product.price.toStringAsFixed(2)}',
                      style: const TextStyle(
                        fontWeight: FontWeight.w800,
                        color: _cocoa,
                        fontSize: 13.5,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _iconBtn(
                    icon: Icons.favorite_rounded,
                    color: const Color(0xFFE88B8B),
                    bgColor: const Color(0xFFFFF0F0),
                    onTap: () {
                      widget.onToggleFavorite(product);
                      setState(() {});
                    },
                  ),
                  const SizedBox(width: 6),
                  _iconBtn(
                    icon: isCake ? Icons.auto_awesome : Icons.add_rounded,
                    color: Colors.white,
                    bgColor: _cocoa,
                    onTap: () {
                      if (isCake) {
                        Navigator.pop(context);
                        widget.onCustomize(product, widget.acceptCustomCakes);
                      } else {
                        widget.onAddToCart(product);
                        Navigator.pop(context);
                        widget.onOpenCart();
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _iconBtn({
    required IconData icon,
    required Color color,
    required Color bgColor,
    required VoidCallback onTap,
  }) {
    return Material(
      color: bgColor,
      borderRadius: BorderRadius.circular(10),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(10),
        child: SizedBox(
          width: 34,
          height: 34,
          child: Icon(icon, size: 16, color: color),
        ),
      ),
    );
  }

  void _openReviewView(String orderId, String productName) {
    setState(() {
      _reviewOrderId = orderId;
      _reviewProductName = productName;
      _reviewRating = 0;
      _reviewCommentController.clear();
      _currentView = ProfileViewState.review;
    });
  }

  Widget _buildReviewSubView() {
    return SafeArea(
      child: Column(
        key: const ValueKey('reviewSubView'),
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Row(
              children: [
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: _border),
                  ),
                  child: IconButton(
                    onPressed: () =>
                        setState(() => _currentView = ProfileViewState.main),
                    icon: const Icon(
                      Icons.arrow_back_rounded,
                      color: _espresso,
                      size: 20,
                    ),
                    padding: const EdgeInsets.all(8),
                    constraints: const BoxConstraints(),
                  ),
                ),
                const SizedBox(width: 14),
                const Expanded(
                  child: Text(
                    'Rate Your Order ⭐',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      color: _espresso,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView(
              padding: EdgeInsets.fromLTRB(
                16,
                0,
                16,
                32 + MediaQuery.of(context).viewInsets.bottom,
              ),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border, width: 1.5),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'How was your treat?',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w800,
                          color: _espresso,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        _reviewProductName,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 13,
                          color: _muted,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(5, (index) {
                          return GestureDetector(
                            onTap: () =>
                                setState(() => _reviewRating = index + 1),
                            child: Padding(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 6,
                              ),
                              child: Icon(
                                index < _reviewRating
                                    ? Icons.star_rounded
                                    : Icons.star_border_rounded,
                                size: 38,
                                color: index < _reviewRating
                                    ? const Color(0xFFF5A623)
                                    : _muted.withOpacity(0.3),
                              ),
                            ),
                          );
                        }),
                      ),
                      const SizedBox(height: 24),
                      TextField(
                        controller: _reviewCommentController,
                        maxLines: 4,
                        style: const TextStyle(
                          fontSize: 13.5,
                          color: _espresso,
                          fontWeight: FontWeight.w600,
                        ),
                        decoration: InputDecoration(
                          hintText: 'Share what you loved about it! 🧁',
                          hintStyle: TextStyle(
                            color: _muted.withOpacity(0.5),
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                          ),
                          filled: true,
                          fillColor: const Color(0xFFFDFBF7),
                          contentPadding: const EdgeInsets.all(16),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: _border),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(color: _border),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(16),
                            borderSide: const BorderSide(
                              color: _cocoa,
                              width: 1.5,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton(
                    onPressed: (_reviewRating == 0 || _isSubmittingReview)
                        ? null
                        : () async {
                            setState(() => _isSubmittingReview = true);
                            try {
                              await FirebaseFirestore.instance
                                  .collection('reviews')
                                  .add({
                                'orderId': _reviewOrderId,
                                'userId': _userId,
                                'userName': widget.currentName,
                                'productName': _reviewProductName,
                                'rating': _reviewRating,
                                'comment': _reviewCommentController.text
                                    .trim(),
                                'createdAt': FieldValue.serverTimestamp(),
                                'status': 'new',
                              });

                              // Skip updating the order document as it may cause permission denied errors.
                              // The UI already queries the 'reviews' collection directly via StreamBuilder.
                              /* 
                              await FirebaseFirestore.instance
                                  .collection('orders')
                                  .doc(_reviewOrderId)
                                  .update({
                                'hasReviewed': true,
                                'userRating': _reviewRating,
                                'userComment': _reviewCommentController.text
                                    .trim(),
                              }); 
                              */

                              if (mounted) {
                                setState(() => _isSubmittingReview = false);
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(
                                    content: const Text(
                                      'Thank you for your sweet review! 🤎',
                                    ),
                                    backgroundColor: _cocoa,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                                setState(
                                  () => _currentView = ProfileViewState.main,
                                );
                              }
                            } catch (e) {
                              if (mounted) {
                                setState(() => _isSubmittingReview = false);
                                _scaffoldMessengerKey.currentState?.showSnackBar(
                                  SnackBar(
                                    content: Text('Could not submit review: $e'),
                                    backgroundColor: _errorRed,
                                    behavior: SnackBarBehavior.floating,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                );
                              }
                              debugPrint('Error submitting review: $e');
                            }
                          },
                    style: FilledButton.styleFrom(
                      backgroundColor: _cocoa,
                      disabledBackgroundColor: _border,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(16),
                      ),
                    ),
                    child: _isSubmittingReview
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(
                              color: Colors.white,
                              strokeWidth: 2,
                            ),
                          )
                        : const Text(
                            'Submit Review',
                            style: TextStyle(
                              fontWeight: FontWeight.w800,
                              fontSize: 15,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOrderHistoryTab() {
    if (_userId.isEmpty) {
      return const Center(
        child: Text(
          'Must be signed in to view history.',
          style: TextStyle(color: _muted),
        ),
      );
    }

    return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
      stream: FirebaseFirestore.instance
          .collection('orders')
          .where('userId', isEqualTo: _userId)
          .snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 64,
                    height: 64,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8EDE0),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('☁️', style: TextStyle(fontSize: 28)),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Oops! Could not load orders.\n${snapshot.error}',
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontWeight: FontWeight.w700,
                      color: _espresso,
                      fontSize: 13,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(
            child: CircularProgressIndicator(color: _cocoa, strokeWidth: 2.5),
          );
        }

        final docs = snapshot.data?.docs.toList() ?? [];

        try {
          docs.sort((a, b) {
            final aTime = a.data()['createdAt'];
            final bTime = b.data()['createdAt'];
            if (aTime is Timestamp && bTime is Timestamp) {
              return bTime.compareTo(aTime);
            }
            return 0;
          });
        } catch (e) {
          debugPrint('Sorting error: $e');
        }

        if (docs.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(32),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: Color(0xFFF8EDE0),
                      shape: BoxShape.circle,
                    ),
                    child: const Center(
                      child: Text('📦', style: TextStyle(fontSize: 32)),
                    ),
                  ),
                  const SizedBox(height: 20),
                  const Text(
                    'No orders yet!',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w800,
                      color: _espresso,
                    ),
                  ),
                ],
              ),
            ),
          );
        }

        return ListView.builder(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
          itemCount: docs.length,
          itemBuilder: (context, index) {
            final doc = docs[index];
            final data = doc.data();

            final orderNumber =
                data['id']?.toString() ??
                data['orderNumber']?.toString() ??
                doc.id;
            final statusLabel = data['statusLabel']?.toString() ?? 'Processing';
            final bool hasReviewed = data['hasReviewed'] == true;

            final rawTotal = data['total'];
            final totalStr = rawTotal != null
                ? (rawTotal is num
                    ? '₱${rawTotal.toStringAsFixed(2)}'
                    : rawTotal.toString())
                : '₱0.00';

            List<Map<String, dynamic>> parsedItems = [];
            final rawItemData = data['item'] ?? data['items'] ?? data['cart'];

            if (rawItemData is String) {
              final items = rawItemData.split(',');
              for (var strItem in items) {
                if (strItem.trim().isEmpty) continue;
                final match = RegExp(
                  r'(\d+)[xX]\s+(.*)',
                ).firstMatch(strItem.trim());
                if (match != null) {
                  parsedItems.add({
                    'name': match.group(2)?.trim() ?? strItem.trim(),
                    'quantity': int.tryParse(match.group(1) ?? '1') ?? 1,
                    'price': null,
                  });
                } else {
                  parsedItems.add({
                    'name': strItem.trim(),
                    'quantity': 1,
                    'price': null,
                  });
                }
              }
            } else if (rawItemData is List) {
              for (var i in rawItemData) {
                if (i is Map) {
                  parsedItems.add({
                    'name': i['name']?.toString() ?? 'Item',
                    'quantity': i['quantity'] is num
                        ? (i['quantity'] as num).toInt()
                        : 1,
                    'price': i['price'],
                  });
                }
              }
            }

            String mainTitle = 'NyseBites Order';
            if (parsedItems.isNotEmpty) {
              mainTitle = parsedItems.first['name'];
              if (parsedItems.length > 1) {
                mainTitle += ' & ${parsedItems.length - 1} more';
              }
            }

            String? displayImage;
            if (parsedItems.isNotEmpty) {
              final pName = parsedItems.first['name']
                  .toString()
                  .split('(')
                  .first
                  .trim()
                  .toLowerCase();
              try {
                final match = _products.firstWhere(
                  (p) => p.name.trim().toLowerCase() == pName,
                );
                displayImage = match.imgSrc;
              } catch (_) {}
            }

            String dateStr = 'Recent';
            if (data['createdAt'] is Timestamp) {
              final timestamp = data['createdAt'] as Timestamp;
              dateStr =
                  '${timestamp.toDate().month}/${timestamp.toDate().day}/${timestamp.toDate().year}';
            }

            final isCompleted =
                statusLabel.toLowerCase().contains('complet') ||
                statusLabel.toLowerCase().contains('deliver');
            final statusBg = isCompleted
                ? const Color(0xFFE8F5E9)
                : const Color(0xFFFFF8E1);
            final statusFg = isCompleted
                ? const Color(0xFF2E7D32)
                : const Color(0xFFE65100);

            return StreamBuilder<QuerySnapshot<Map<String, dynamic>>>(
              stream: FirebaseFirestore.instance
                  .collection('reviews')
                  .where('orderId', isEqualTo: doc.id)
                  .snapshots(),
              builder: (context, reviewSnapshot) {
                int resolvedRating = data['userRating'] is num
                    ? (data['userRating'] as num).toInt()
                    : 0;
                String resolvedComment = data['userComment']?.toString() ?? '';
                bool isReviewedByQuery = hasReviewed;

                if (reviewSnapshot.hasData &&
                    reviewSnapshot.data!.docs.isNotEmpty) {
                  final reviewData = reviewSnapshot.data!.docs.first.data();
                  resolvedRating = reviewData['rating'] is num
                      ? (reviewData['rating'] as num).toInt()
                      : resolvedRating;
                  resolvedComment =
                      reviewData['comment']?.toString() ?? resolvedComment;
                  isReviewedByQuery = true;
                }

                return Container(
                  margin: const EdgeInsets.only(bottom: 16),
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: _border, width: 1.5),
                    boxShadow: [
                      BoxShadow(
                        color: _espresso.withOpacity(0.04),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Container(
                                  width: 44,
                                  height: 44,
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFF8EDE0),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child:
                                      displayImage != null &&
                                          displayImage.isNotEmpty
                                      ? ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                          child: Image.asset(
                                            displayImage,
                                            fit: BoxFit.cover,
                                            errorBuilder: (_, __, ___) =>
                                                const Center(
                                                  child: Text(
                                                    '🛍️',
                                                    style: TextStyle(
                                                      fontSize: 18,
                                                    ),
                                                  ),
                                                ),
                                          ),
                                        )
                                      : const Center(
                                          child: Text(
                                            '🛍️',
                                            style: TextStyle(fontSize: 18),
                                          ),
                                        ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        mainTitle,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w900,
                                          color: _espresso,
                                          fontSize: 14.5,
                                          letterSpacing: -0.3,
                                        ),
                                        maxLines: 1,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                      Text(
                                        'Order #$orderNumber • $dateStr',
                                        style: const TextStyle(
                                          color: _muted,
                                          fontSize: 11,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(width: 10),
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 10,
                              vertical: 6,
                            ),
                            decoration: BoxDecoration(
                              color: statusBg,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              statusLabel,
                              style: TextStyle(
                                fontSize: 10.5,
                                fontWeight: FontWeight.w800,
                                color: statusFg,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Container(height: 1, color: _border),
                      const SizedBox(height: 16),

                      if (parsedItems.isNotEmpty)
                        ...parsedItems.map((item) {
                          final itemName = item['name'];
                          final itemQty = item['quantity'];
                          final itemPrice = item['price'];

                          return Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  '${itemQty}x',
                                  style: const TextStyle(
                                    fontWeight: FontWeight.w900,
                                    color: _cocoa,
                                    fontSize: 13.5,
                                  ),
                                ),
                                const SizedBox(width: 12),
                                Expanded(
                                  child: Text(
                                    itemName,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: _espresso,
                                      fontSize: 13.5,
                                      height: 1.3,
                                    ),
                                  ),
                                ),
                                if (itemPrice != null)
                                  Text(
                                    '₱${(itemPrice is num ? itemPrice.toDouble() : double.tryParse(itemPrice.toString()) ?? 0.0).toStringAsFixed(2)}',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w800,
                                      color: _espresso,
                                      fontSize: 13.5,
                                    ),
                                  ),
                              ],
                            ),
                          );
                        }),

                      if (parsedItems.isEmpty)
                        const Text(
                          'Item details unavailable',
                          style: TextStyle(
                            color: _muted,
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),

                      if (isReviewedByQuery || resolvedRating > 0) ...[
                        const SizedBox(height: 12),
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: const Color(0xFFFAF4ED),
                            borderRadius: BorderRadius.circular(14),
                            border: Border.all(color: _border),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  const Text(
                                    'Your Review:',
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.w800,
                                      color: _muted,
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Row(
                                    children: List.generate(5, (starIdx) {
                                      return Icon(
                                        starIdx < resolvedRating
                                            ? Icons.star_rounded
                                            : Icons.star_border_rounded,
                                        size: 14,
                                        color: starIdx < resolvedRating
                                            ? const Color(0xFFF5A623)
                                            : _muted.withOpacity(0.3),
                                      );
                                    }),
                                  ),
                                ],
                              ),
                              if (resolvedComment.isNotEmpty) ...[
                                const SizedBox(height: 4),
                                Text(
                                  '"$resolvedComment"',
                                  style: const TextStyle(
                                    fontSize: 12.5,
                                    color: _espresso,
                                    fontStyle: FontStyle.italic,
                                    height: 1.3,
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ],

                      const SizedBox(height: 8),
                      Container(height: 1, color: _border),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'ORDER TOTAL',
                                style: TextStyle(
                                  fontSize: 10,
                                  color: _muted,
                                  fontWeight: FontWeight.w800,
                                  letterSpacing: 0.5,
                                ),
                              ),
                              Text(
                                totalStr,
                                style: const TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w900,
                                  color: _espresso,
                                  letterSpacing: -0.5,
                                ),
                              ),
                            ],
                          ),
                          Row(
                            children: [
                              if (isCompleted &&
                                  !isReviewedByQuery &&
                                  resolvedRating == 0) ...[
                                OutlinedButton(
                                  onPressed: () =>
                                      _openReviewView(doc.id, mainTitle),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _cocoa,
                                    side: const BorderSide(
                                      color: _cocoa,
                                      width: 1.2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  child: const Text(
                                    'Review',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              if (!isCompleted) ...[
                                OutlinedButton.icon(
                                  onPressed: () {
                                    int itemCount = 1;
                                    if (data['items'] is List) {
                                      itemCount =
                                          (data['items'] as List).length;
                                    } else if (data['cart'] is List) {
                                      itemCount = (data['cart'] as List).length;
                                    } else if (data['itemCount'] != null) {
                                      itemCount = (data['itemCount'] as num)
                                          .toInt();
                                    }

                                    final rawTotal = (data['total'] ?? '0')
                                        .toString()
                                        .replaceAll(RegExp(r'[^0-9.]'), '');
                                    final totalAmount =
                                        double.tryParse(rawTotal) ?? 0.0;

                                    DateTime placedAt = DateTime.now();
                                    if (data['createdAt'] is Timestamp) {
                                      placedAt =
                                          (data['createdAt'] as Timestamp)
                                              .toDate();
                                    }

                                    showDialog(
                                      context: context,
                                      builder: (context) => OrderTrackerModal(
                                        orderNumber: orderNumber,
                                        itemCount: itemCount,
                                        totalAmount: totalAmount,
                                        placedAt: placedAt,
                                      ),
                                    );
                                  },
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: _cocoa,
                                    side: const BorderSide(
                                      color: _cocoa,
                                      width: 1.2,
                                    ),
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 14,
                                      vertical: 0,
                                    ),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                  ),
                                  icon: const Icon(
                                    Icons.local_shipping_outlined,
                                    size: 16,
                                  ),
                                  label: const Text(
                                    'Track Order',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w800,
                                      fontSize: 13,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                              ],
                              FilledButton.icon(
                                onPressed: () {
                                  bool itemsAdded = false;
                                  for (var item in parsedItems) {
                                    final pName = item['name']
                                        .toString()
                                        .split('(')
                                        .first
                                        .trim()
                                        .toLowerCase();
                                    final pQty = item['quantity'] as int;

                                    try {
                                      final match = _products.firstWhere(
                                        (p) =>
                                            p.name.trim().toLowerCase() ==
                                            pName,
                                      );
                                      for (int i = 0; i < pQty; i++) {
                                        widget.onAddToCart(match);
                                        itemsAdded = true;
                                      }
                                    } catch (e) {
                                      debugPrint(
                                        'Item no longer in menu: $pName',
                                      );
                                    }
                                  }

                                  if (itemsAdded) {
                                    Navigator.pop(context);
                                    widget.onOpenCart();
                                  } else {
                                    _scaffoldMessengerKey.currentState?.showSnackBar(
                                      SnackBar(
                                        content: const Text(
                                          'These items are no longer available on the menu.',
                                        ),
                                        backgroundColor: _errorRed,
                                        behavior: SnackBarBehavior.floating,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            12,
                                          ),
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: FilledButton.styleFrom(
                                  backgroundColor: _blush,
                                  foregroundColor: _cocoa,
                                  elevation: 0,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 14,
                                    vertical: 0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12),
                                    side: const BorderSide(color: _border),
                                  ),
                                ),
                                icon: const Icon(
                                  Icons.replay_rounded,
                                  size: 16,
                                ),
                                label: const Text(
                                  'Reorder',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w800,
                                    fontSize: 13,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class _FaqItem extends StatefulWidget {
  final String question;
  final String answer;
  final bool showDivider;

  const _FaqItem({
    required this.question,
    required this.answer,
    this.showDivider = true,
  });

  @override
  State<_FaqItem> createState() => _FaqItemState();
}

class _FaqItemState extends State<_FaqItem> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Theme(
          data: ThemeData(
            dividerColor: Colors.transparent,
            splashColor: Colors.transparent,
            highlightColor: Colors.transparent,
          ),
          child: ExpansionTile(
            tilePadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 4),
            childrenPadding: const EdgeInsets.only(left: 20, right: 20, bottom: 20),
            title: AnimatedDefaultTextStyle(
              duration: const Duration(milliseconds: 200),
              style: TextStyle(
                fontFamily: Theme.of(context).textTheme.bodyLarge?.fontFamily,
                fontSize: 13.5,
                fontWeight: FontWeight.w800,
                color: _expanded ? const Color(0xFF8C4A27) : const Color(0xFF251811),
                letterSpacing: -0.2,
              ),
              child: Text(widget.question),
            ),
            trailing: AnimatedRotation(
              turns: _expanded ? 0.5 : 0.0,
              duration: const Duration(milliseconds: 300),
              child: Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: _expanded ? const Color(0xFFFBEBE4) : const Color(0xFFFAF4ED),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  Icons.keyboard_arrow_down_rounded,
                  color: _expanded ? const Color(0xFF8C4A27) : const Color(0xFF7A6559),
                  size: 20,
                ),
              ),
            ),
            onExpansionChanged: (val) => setState(() => _expanded = val),
            children: [
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  widget.answer,
                  style: const TextStyle(
                    fontSize: 12.5,
                    color: Color(0xFF7A6559),
                    height: 1.5,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ],
          ),
        ),
        if (widget.showDivider)
          const Divider(
            height: 1,
            thickness: 1,
            color: Color(0xFFF5EDDF),
            indent: 20,
            endIndent: 20,
          ),
      ],
    );
  }
}
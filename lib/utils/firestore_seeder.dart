import 'package:cloud_firestore/cloud_firestore.dart';
import '../data/mock_products.dart';

class FirestoreSeeder {
  static final FirebaseFirestore _db = FirebaseFirestore.instance;

  // 1. Seed All 10 Bakery Products
  static Future<void> seedProducts() async {
    final batch = _db.batch();
    final collection = _db.collection('products');

    for (final product in mockProducts) {
      final docRef = collection.doc('sku_${product.id}');
      batch.set(docRef, {
        'id': 'sku_${product.id}',
        'name': product.name,
        'category': product.category,
        'price': product.price,
        'priceBox6': product.priceBox6,
        'servingSize': product.servingSize,
        'description': product.description,
        'imgSrc': product.imgSrc,
        'icon': _getCategoryIcon(product.category),
        'stock': 24,
        'active': true,
        'createdAt': FieldValue.serverTimestamp(),
      });
    }

    await batch.commit();
  }

  // 2. Seed Initial Sweet Notes
  static Future<void> seedSweetNotes() async {
    final notes = [
      {
        'name': 'Christian Villafuerte',
        'email': 'sam.cruz@gmail.com',
        'subject': 'Bulk Box for Wedding Favors',
        'message':
            'Hi Nyse Bites! Inquiring if we can order 80 boxes of mini cookies with customized pastel ribbons for an October wedding in Tagaytay?',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
      {
        'name': 'Atty. Beatrice Valderama',
        'email': 'b.valderama@lawfirm.ph',
        'subject': 'Corporate Gift Boxes Inquiry',
        'message':
            'Good day! We would like to order 45 boxes of Hershey\'s Almond Cloud Squares and Belgian Choco Chips for our firm\'s anniversary.',
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      },
    ];

    for (final note in notes) {
      await _db.collection('sweet_notes').add(note);
    }
  }

  static String _getCategoryIcon(String category) {
    switch (category.toLowerCase()) {
      case 'cookies':
        return '🍪';
      case 'brownies':
        return '🟫';
      case 'cakes':
        return '🎂';
      default:
        return '🧁';
    }
  }
}
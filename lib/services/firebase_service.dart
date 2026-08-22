import 'package:cloud_firestore/cloud_firestore.dart';

class FirebaseService {
  static final _db = FirebaseFirestore.instance;

  // --- PRODUCTS / INVENTORY ---
  // Real-time stream for storefront and batch drops
  static Stream<List<Map<String, dynamic>>> getProductsStream() {
    return _db.collection('products').snapshots().map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  // Admin: Update Stock or Status
  static Future<void> updateProductStock(String docId, int newStock) async {
    await _db.collection('products').doc(docId).update({
      'stock': newStock,
      'active': newStock > 0,
    });
  }

  static Future<void> toggleProductStatus(String docId, bool currentStatus) async {
    await _db.collection('products').doc(docId).update({'active': !currentStatus});
  }

  // --- ORDERS ---
  // Storefront: Submit New Order
  static Future<String> placeOrder(Map<String, dynamic> orderData) async {
    final docRef = await _db.collection('orders').add({
      ...orderData,
      'createdAt': FieldValue.serverTimestamp(),
    });
    return docRef.id;
  }

  // Admin: Stream Live Orders
  static Stream<List<Map<String, dynamic>>> getLiveOrdersStream() {
    return _db
        .collection('orders')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }

  // Admin: Update Status (e.g., to 'baking', 'delivering', 'delivered')
  static Future<void> updateOrderStatus(String orderId, String newStatus, String newLabel) async {
    await _db.collection('orders').doc(orderId).update({
      'status': newStatus,
      'statusLabel': newLabel,
    });
  }

  // --- SWEET NOTES ---
  // Storefront: Send message
  static Future<void> sendSweetNote({
    required String name,
    required String email,
    required String subject,
    required String message,
  }) async {
    await _db.collection('sweet_notes').add({
      'name': name,
      'email': email,
      'subject': subject,
      'message': message,
      'isRead': false,
      'createdAt': FieldValue.serverTimestamp(),
    });
  }

  // Admin: Stream Sweet Notes
  static Stream<List<Map<String, dynamic>>> getSweetNotesStream() {
    return _db
        .collection('sweet_notes')
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => {'id': doc.id, ...doc.data()}).toList();
    });
  }
}
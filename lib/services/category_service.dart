import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category_model.dart';

class CategoryService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Category>> getCategories() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot = await _firestore
          .collection('categories')
          .orderBy('order')
          .get();

      return snapshot.docs
          .map((doc) => Category.fromFirestore(doc.data(), doc.id))
          .toList();
    } catch (e) {
      throw Exception('Kategoriler yüklenirken hata oluştu: $e');
    }
  }

  Stream<List<Category>> getCategoriesStream() {
    return _firestore
        .collection('categories')
        .orderBy('order')
        .snapshots()
        .map(
          (snapshot) => snapshot.docs
              .map((doc) => Category.fromFirestore(doc.data(), doc.id))
              .toList(),
        );
  }
}

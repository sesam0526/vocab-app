import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Stream<QuerySnapshot> getVocabularies() {
    return _firestore.collection('Users').doc(_auth.currentUser!.uid).collection('Vocabularies').snapshots();
  }

  Future<void> addVocabulary(String name, String? description) async {
    await _firestore.collection('Users').doc(_auth.currentUser!.uid).collection('Vocabularies').add({
      'name': name,
      'description': description ?? ''
    });
  }

  // 수정, 삭제 등의 추가 메서드를 필요에 따라 구현할 수 있습니다.
}

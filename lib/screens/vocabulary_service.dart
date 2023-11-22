import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class VocabularyService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  String getCurrentUserEmail() {
    return _auth.currentUser!.email!;
  }
  Stream<QuerySnapshot> getVocabularies() {
    String email = getCurrentUserEmail();
    return _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .snapshots();
  }

  Future<List<DocumentSnapshot>> getVocabularyBooks() async {
    String email = getCurrentUserEmail();
    final snapshot = await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .get();
    return snapshot.docs;
  }

  Future<void> addVocabulary(String name, String? description) async {
    String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .add({'name': name, 'description': description ?? ''});
  }

  Future<void> updateVocabulary(
      String docId, String name, String? description) async {
    String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(docId)
        .update({'name': name, 'description': description ?? ''});
  }

  Future<void> deleteVocabulary(String docId) async {
    String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(docId)
        .delete();
  }

  Query<Map<String, dynamic>> getWords(String vocabularyId) {
    String email = getCurrentUserEmail();
    return _firestore.collection('users')
      .doc(email)
      .collection('Vocabularies')
      .doc(vocabularyId)
      .collection('Words')
      .orderBy('timestamp', descending: false); // 타임스탬프 기준으로 정렬
  }

  Future<void> addWord(String vocabularyId, String word, String meaning) async {
    String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .add({'word': word,
         'meaning': meaning,
         'timestamp': FieldValue.serverTimestamp(),
         });
  }

  Future<void> updateWord(
      String vocabularyId, String wordId, String word, String meaning) async {
        String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .doc(wordId)
        .update({'word': word, 'meaning': meaning});
  }

  Future<void> deleteWord(String vocabularyId, String wordId) async {
    String email = getCurrentUserEmail();
    await _firestore
        .collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .doc(wordId)
        .delete();
  }
  Future<bool> checkWordExistence(String vocabularyId, String word, String? excludingWordId) async {
    String email = getCurrentUserEmail();
    QuerySnapshot query = await _firestore.collection('users')
        .doc(email)
        .collection('Vocabularies')
        .doc(vocabularyId)
        .collection('Words')
        .where('word', isEqualTo: word)
        .get();

    // 단어가 존재하는지 확인하되, 현재 수정 중인 단어는 제외
    return query.docs.any((doc) => excludingWordId == null || doc.id != excludingWordId);
  }

}

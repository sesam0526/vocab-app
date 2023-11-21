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
  
  Future<void> updateVocabulary(String docId, String name, String? description) async {
    await _firestore.collection('Users').doc(_auth.currentUser!.uid).collection('Vocabularies').doc(docId).update({
      'name': name,
      'description': description ?? ''
    });
  }

  Future<void> deleteVocabulary(String docId) async {
    await _firestore.collection('Users').doc(_auth.currentUser!.uid).collection('Vocabularies').doc(docId).delete();
  }



  Stream<QuerySnapshot> getWords(String vocabularyId) {
    return _firestore.collection('Users').doc(_auth.currentUser!.uid).collection('Vocabularies').doc(vocabularyId).collection('Words').snapshots();
  }


  
  Future<void> addWord(String vocabularyId, String word, String meaning) async {
    await _firestore.collection('Users')
      .doc(_auth.currentUser!.uid)
      .collection('Vocabularies')
      .doc(vocabularyId)
      .collection('Words')
      .add({
        'word': word,
        'meaning': meaning
      });
  }

  Future<void> updateWord(String vocabularyId, String wordId, String word, String meaning) async {
    await _firestore.collection('Users')
      .doc(_auth.currentUser!.uid)
      .collection('Vocabularies')
      .doc(vocabularyId)
      .collection('Words')
      .doc(wordId)
      .update({
        'word': word,
        'meaning': meaning
      });
  }

  Future<void> deleteWord(String vocabularyId, String wordId) async {
    await _firestore.collection('Users')
      .doc(_auth.currentUser!.uid)
      .collection('Vocabularies')
      .doc(vocabularyId)
      .collection('Words')
      .doc(wordId)
      .delete();
  }

}

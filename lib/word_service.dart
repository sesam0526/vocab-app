import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class WordService extends ChangeNotifier {
  final wordCollection = FirebaseFirestore.instance.collection('word');

  Future<QuerySnapshot> read(String uid) async {
    // 
    return wordCollection.where('uid', isEqualTo: uid).get();
  }

  void create(String word, String meaning, String uid) async {
    // word 만들기

    await wordCollection.add({
      'uid' : uid,
      'word' : word,
      'meaning' : meaning,
    });
    notifyListeners();
  }

  void update(String docId, bool isDone) async {
    // 
  }

  void delete(String docId) async {
    
  }
}
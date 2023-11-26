import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class StoreService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  String getCurrentUserEmail() {
    return _auth.currentUser!.email!;
  }

  Future<int> getUserMoney() async {
    try {
      String email = getCurrentUserEmail();
      var userDocument = await _firestore.collection('users').doc(email).get();
      var money = userDocument['money'];
      return money ?? 0;
    } catch (e) {
      print('Error retrieving user money: $e');
      return 0;
    }
  }

  Future<void> addMoney(int amount) async {
    try {
      String email = getCurrentUserEmail();
      var currentMoney = await getUserMoney();
      await _firestore.collection('users').doc(email).update({
        'money': currentMoney + amount,
      });
    } catch (e) {
      print('Error adding money: $e');
    }
  }

  Future<void> subtractMoney(int amount) async {
    try {
      String email = getCurrentUserEmail();
      var currentMoney = await getUserMoney();
      if (currentMoney >= amount) {
        await _firestore.collection('users').doc(email).update({
          'money': currentMoney - amount,
        });
      } else {
        print('Insufficient funds.');
      }
    } catch (e) {
      print('Error subtracting money: $e');
    }
  }

  Future<int> getUserLives() async {
    try {
      String email = getCurrentUserEmail();
      var userDocument = await _firestore.collection('users').doc(email).get();
      var lives = userDocument['lives'];
      return lives ?? 0;
    } catch (e) {
      print('Error retrieving user lives: $e');
      return 3; //오류발생시 기본값 3목숨
    }
  }

  Future<void> addLives(int amount) async {
    try {
      String email = getCurrentUserEmail();
      var currentLives = await getUserLives();
      await _firestore.collection('users').doc(email).update({
        'lives': currentLives + amount,
      });
    } catch (e) {
      print('Error adding lives: $e');
    }
  }

  Future<void> subtractLives(int amount) async {
    try {
      String email = getCurrentUserEmail();
      var currentLives = await getUserLives();
      if (currentLives >= amount) {
        await _firestore.collection('users').doc(email).update({
          'lives': currentLives - amount,
        });
      } else {
        print('Insufficient lives.');
      }
    } catch (e) {
      print('Error subtracting lives: $e');
    }
  }
}

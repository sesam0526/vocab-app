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
}

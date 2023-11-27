import 'dart:math';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_project/screens/vocabulary_service.dart';

class GameUtils {
  // 현재 사용자 uid 가져오는 함수
  static String getCurrentUserId() {
    String uid = 'abc'; // 사용자 uid
    FirebaseAuth auth = FirebaseAuth.instance; // 사용자 인증관련 작업 수행

    if (auth.currentUser != null) {
      // 현재 사용자가 인증되어 있으면
      uid = auth.currentUser!.email.toString(); // 사용자의 이메일을 UID로 사용
    }
    return uid;
  }

  // 단어 가져오는 함수
  static Future<List<Map<String, String>>> fetchWords(
      String vocabularyId) async {
    final VocabularyService vocabService = VocabularyService();
    final words = await vocabService
        .getWordsFromVocabulary(vocabularyId); // 선택한 단어장에서 단어 목록 가져옴

    // 단어 목록을 랜덤하게 섞기
    final random = Random();
    words.shuffle(random);

    return words.toList(); // 리스트로 반환
  }

  // 피드백을 보여줄 SnackBar 표시
  static void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message), // 메시지 출력
        duration: const Duration(seconds: 1), // 표시 시간 조절
      ),
    );
  }

  // 파이어베이스에 오답 노트 업데이트하는 함수
  static Future<void> addToWrongWordsList(
      String vocabularyId, Map<String, String> wordInfo) async {
    String uid = getCurrentUserId();
    String word = wordInfo['word']!;
    String meaning = wordInfo['meaning']!;

    // 오답 노트에 추가
    await FirebaseFirestore.instance
        .collection("users")
        .doc(uid)
        .collection("Vocabularies")
        .doc(vocabularyId)
        .collection("WrongWords")
        .doc(word) // 단어를 문서 ID로 사용하여 중복된 단어를 덮어쓰지 않도록 함
        .get()
        .then((docSnapshot) {
      if (docSnapshot.exists) {
        // 이미 해당 단어가 오답 노트에 존재할 경우, incorrectCount를 1 증가시키기
        int currentIncorrectCount = docSnapshot['incorrectCount'] ?? 0;
        docSnapshot.reference
            .update({'incorrectCount': currentIncorrectCount + 1});
      } else {
        // 해당 단어가 오답 노트에 존재하지 않을 경우, 새로운 문서로 추가
        FirebaseFirestore.instance
            .collection("users")
            .doc(uid)
            .collection("Vocabularies")
            .doc(vocabularyId)
            .collection("WrongWords")
            .doc(word)
            .set({
          'word': word,
          'meaning': meaning,
          'incorrectCount': 1, // 처음 틀렸으니 1로 설정
        });
      }
    });
  }

  // 게임 결과 화면 함수
  static void showGameOverDialog(
      BuildContext context,
      int totalWords,
      int correctWords,
      int incorrectWords,
      double accuracyRate,
      int lives,
      int scoreReceived,
      int moneyEarned) {
    const textStyle = TextStyle(fontSize: 18); // 글자 스타일

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('게임 종료'),
          content: SizedBox(
            height: 200,
            child: Column(
              children: [
                Text('총 단어 수: $totalWords', style: textStyle),
                Text('맞은 단어 수: $correctWords', style: textStyle),
                Text('틀린 단어 수: $incorrectWords', style: textStyle),
                Text('정답률: ${accuracyRate.toStringAsFixed(2)}%',
                    style: textStyle), // 반올림해서 소수점 둘째자리까지 표현
                Text('남은 목숨 수: $lives', style: textStyle),
                Text('받은 점수: $scoreReceived', style: textStyle),
                Text('획득한 돈: $moneyEarned', style: textStyle),
              ],
            ),
          ),
          actions: [
            TextButton(
              // 닫기 버튼을 누르면
              onPressed: () {
                Navigator.of(context).pop(); // 다이얼로그 닫힘
                Navigator.of(context).pop();
                Navigator.of(context).pop();//해당 게임 창을 나감
              },
              child: const Text('닫기'),
            ),
          ],
        );
      },
    );
  }

// 파이어베이스에 유저 점수와 돈 업데이트하는 함수
  static void updateScoreAndMoneyInFirebase(
      int scoreReceived, int moneyEarned) async {
    String uid = getCurrentUserId();

    // 점수 업데이트
    DocumentReference<Map<String, dynamic>> scoreReference = FirebaseFirestore
        .instance
        .collection("users")
        .doc(uid); // 특정 사용자의 문서에 접근

    final DocumentSnapshot<Map<String, dynamic>> scoreSnapshot =
        await scoreReference
            .get(); // Firestore에서 해당 문서를 가져와 DocumentSnapshot 객체로 저장

    int currentScore = scoreSnapshot.get('score') ?? 0; // 현재 사용자의 점수 정보
    int newScore = currentScore + scoreReceived; // 현재 점수에 받은 점수를 더함
    newScore = newScore < 0 ? 0 : newScore; // 점수는 최저 0이 되도록 함

    scoreReference.update({"score": newScore}); // 새로운 점수로 업데이트

    // 돈 업데이트
    DocumentReference<Map<String, dynamic>> moneyReference = FirebaseFirestore
        .instance
        .collection("users")
        .doc(uid); // 특정 사용자의 문서에 접근

    final DocumentSnapshot<Map<String, dynamic>> moneySnapshot =
        await moneyReference
            .get(); // Firestore에서 해당 문서를 가져와 DocumentSnapshot 객체로 저장

    int currentMoney = moneySnapshot.get('money'); // 현재 사용자의 돈 정보
    moneyReference.update(
        {"money": currentMoney + moneyEarned}); // 현재 돈에 획득한 돈을 더하여 새로운 돈으로 업데이트
  }
}

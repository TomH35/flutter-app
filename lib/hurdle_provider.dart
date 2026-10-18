import 'dart:math';

import 'package:english_words/english_words.dart' as words;
import 'package:flutter/foundation.dart';

import 'wordle.dart';

class HurdleProvider extends ChangeNotifier {
  final random = Random.secure();

  final int lettersPerRow = 5;
  final int totalAttempts = 6;

  List<String> totalWords = [];
  List<String> rowInputs = [];
  List<String> excludedLetters = [];
  List<Wordle> hurdleBoard = [];
  String targetWord = '';

  int count = 0;
  int index = 0;
  int attempts = 0;
  bool wins = false;

  bool get isValidWord =>
      totalWords.contains(rowInputs.join('').toLowerCase());

  bool get shouldCheckForAnswer => rowInputs.length == lettersPerRow;

  bool get noAttemptsLeft => attempts == totalAttempts;

  bool get isGameOver => wins || noAttemptsLeft;

  void init() {
    totalWords = words.all.where((element) => element.length == 5).toList();
    generateBoard();
    generateRandomWord();
  }

  void generateBoard() {
    hurdleBoard = List.generate(
      lettersPerRow * totalAttempts,
      (index) => Wordle(letter: ''),
    );
  }

  void generateRandomWord() {
    targetWord = totalWords[random.nextInt(totalWords.length)].toUpperCase();
    debugPrint('Target word: $targetWord');
  }

  void inputLetter(String letter) {
    if (isGameOver) return;
    if (count < lettersPerRow) {
      rowInputs.add(letter);
      hurdleBoard[index] = Wordle(letter: letter);
      count++;
      index++;
      notifyListeners();
    }
  }

  void deleteLetter() {
    if (isGameOver) return;
    if (count > 0) {
      rowInputs.removeAt(rowInputs.length - 1);
      hurdleBoard[index - 1] = Wordle(letter: '');
      count--;
      index--;
      notifyListeners();
    }
  }

  void checkAnswer() {
    final input = rowInputs.join('');
    _markLettersOnBoard();

    if (targetWord == input) {
      wins = true;
    } else if (attempts < totalAttempts) {
      _goToNextRow();
    }
    notifyListeners();
  }

  void _markLettersOnBoard() {
    final rowStart = index - lettersPerRow;
    for (int i = rowStart; i < index; i++) {
      final letter = hurdleBoard[i].letter;
      if (letter.isEmpty) continue;

      if (targetWord.contains(letter)) {
        hurdleBoard[i].existsInTarget = true;
      } else {
        hurdleBoard[i].doesNotExistInTarget = true;
        if (!excludedLetters.contains(letter)) {
          excludedLetters.add(letter);
        }
      }
    }
  }

  void _goToNextRow() {
    attempts++;
    count = 0;
    rowInputs.clear();
  }

  void reset() {
    count = 0;
    index = 0;
    attempts = 0;
    wins = false;
    rowInputs.clear();
    excludedLetters.clear();
    generateBoard();
    generateRandomWord();
    notifyListeners();
  }
}

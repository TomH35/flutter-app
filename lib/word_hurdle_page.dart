import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import 'helper_functions.dart';
import 'hurdle_provider.dart';
import 'keyboard_view.dart';
import 'wordle_view.dart';

class WordHurdlePage extends StatefulWidget {
  const WordHurdlePage({super.key});

  @override
  State<WordHurdlePage> createState() => _WordHurdlePageState();
}

class _WordHurdlePageState extends State<WordHurdlePage> {
  bool _isInitialized = false;

  @override
  void didChangeDependencies() {
    if (!_isInitialized) {
      Provider.of<HurdleProvider>(context, listen: false).init();
      _isInitialized = true;
    }
    super.didChangeDependencies();
  }

  void _handleInput(HurdleProvider provider) {
    if (provider.isGameOver) return;

    if (!provider.shouldCheckForAnswer) {
      showMsg(context, 'Enter all ${provider.lettersPerRow} letters');
      return;
    }

    if (!provider.isValidWord) {
      showMsg(context, 'Not a word in my dictionary');
      return;
    }

    provider.checkAnswer();

    if (provider.wins) {
      showResult(
        context: context,
        title: 'You Win!!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () => _playAgain(provider),
        onCancel: _quit,
      );
    } else if (provider.noAttemptsLeft) {
      showResult(
        context: context,
        title: 'You Lost!!!',
        body: 'The word was ${provider.targetWord}',
        onPlayAgain: () => _playAgain(provider),
        onCancel: _quit,
      );
    }
  }

  void _playAgain(HurdleProvider provider) {
    Navigator.of(context).pop();
    provider.reset();
  }

  void _quit() {
    Navigator.of(context).pop();
    SystemNavigator.pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Word Hurdle'),
        centerTitle: true,
        actions: [
          Consumer<HurdleProvider>(
            builder: (context, provider, child) => IconButton(
              tooltip: 'New game',
              onPressed: provider.reset,
              icon: const Icon(Icons.refresh),
            ),
          ),
        ],
      ),
      body: Center(
        child: Column(
          children: [
            Expanded(
              child: SizedBox(
                width: MediaQuery.of(context).size.width * 0.70,
                child: Consumer<HurdleProvider>(
                  builder: (context, provider, child) => GridView.builder(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 5,
                      mainAxisSpacing: 4,
                      crossAxisSpacing: 4,
                    ),
                    itemCount: provider.hurdleBoard.length,
                    itemBuilder: (context, index) {
                      final wordle = provider.hurdleBoard[index];
                      return WordleView(wordle: wordle);
                    },
                  ),
                ),
              ),
            ),

            Consumer<HurdleProvider>(
              builder: (context, provider, child) => Text(
                'Attempts: ${provider.attempts}/${provider.totalAttempts}',
                style: Theme.of(context).textTheme.titleMedium,
              ),
            ),

            Consumer<HurdleProvider>(
              builder: (context, provider, child) => KeyboardView(
                excludedLetters: provider.excludedLetters,
                onPressed: (value) {
                  provider.inputLetter(value);
                },
              ),
            ),

            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Consumer<HurdleProvider>(
                builder: (context, provider, child) => Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: provider.deleteLetter,
                      child: const Text('DELETE'),
                    ),
                    ElevatedButton(
                      onPressed: () => _handleInput(provider),
                      child: const Text('SUBMIT'),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'dart:async';
import 'package:audioplayers/audioplayers.dart';
import '../models/trademark.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with SingleTickerProviderStateMixin {
  int currentIndex = 0;
  int score = 0;
  final TextEditingController _guessController = TextEditingController();
  bool showHint = false;
  bool isCorrect = false;
  String feedback = '';
  Timer? _timer;
  int _timeLeft = 30;
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _startTimer();
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 300),
      vsync: this,
    );
    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 30;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_timeLeft > 0) {
          _timeLeft--;
        } else {
          _timer?.cancel();
          _showTimeUpDialog();
        }
      });
    });
  }

  void _showTimeUpDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Time\'s Up!'),
        content: Text('The correct answer was: ${trademarks[currentIndex].name}'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              nextTrademark();
            },
            child: const Text('Next Trademark'),
          ),
        ],
      ),
    );
  }

  Future<void> _playSound(bool isCorrect) async {
    await _audioPlayer.play(
      AssetSource(isCorrect ? 'correct.mp3' : 'wrong.mp3'),
    );
  }

  void checkGuess() {
    final guess = _guessController.text.trim().toLowerCase();
    final correctAnswer = trademarks[currentIndex].name.toLowerCase();
    
    setState(() {
      if (guess == correctAnswer) {
        score++;
        isCorrect = true;
        feedback = 'Correct! Well done!';
        _playSound(true);
        _animationController.forward().then((_) => _animationController.reverse());
      } else {
        isCorrect = false;
        feedback = 'Try again!';
        _playSound(false);
      }
    });
  }

  void nextTrademark() {
    if (currentIndex < trademarks.length - 1) {
      setState(() {
        currentIndex++;
        _guessController.clear();
        showHint = false;
        feedback = '';
        isCorrect = false;
        _startTimer();
      });
    } else {
      showDialog(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Game Over!'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Your final score: $score/${trademarks.length}'),
              const SizedBox(height: 10),
              Text(
                'Accuracy: ${((score / trademarks.length) * 100).toStringAsFixed(1)}%',
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  currentIndex = 0;
                  score = 0;
                  _guessController.clear();
                  showHint = false;
                  feedback = '';
                  isCorrect = false;
                  _startTimer();
                });
              },
              child: const Text('Play Again'),
            ),
          ],
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trademark Guessing Game'),
        backgroundColor: Colors.blue,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Score: $score',
                      style: const TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                      decoration: BoxDecoration(
                        color: _timeLeft <= 10 ? Colors.red : Colors.blue,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        'Time: $_timeLeft',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                LinearProgressIndicator(
                  value: (currentIndex + 1) / trademarks.length,
                  backgroundColor: Colors.grey[300],
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.blue),
                ),
                const SizedBox(height: 20),
                ScaleTransition(
                  scale: _scaleAnimation,
                  child: Container(
                    height: 200,
                    width: 200,
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(10),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.grey.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                        ),
                      ],
                    ),
                    child: Image.network(
                      trademarks[currentIndex].imageUrl,
                      fit: BoxFit.contain,
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: _guessController,
                  decoration: InputDecoration(
                    hintText: 'Enter trademark name',
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    filled: true,
                    fillColor: Colors.white,
                    prefixIcon: const Icon(Icons.search),
                  ),
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 18),
                  onSubmitted: (_) => checkGuess(),
                ),
                const SizedBox(height: 10),
                if (feedback.isNotEmpty)
                  AnimatedOpacity(
                    duration: const Duration(milliseconds: 300),
                    opacity: feedback.isNotEmpty ? 1.0 : 0.0,
                    child: Text(
                      feedback,
                      style: TextStyle(
                        color: isCorrect ? Colors.green : Colors.red,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    ElevatedButton.icon(
                      onPressed: checkGuess,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blue,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      icon: const Icon(Icons.check),
                      label: const Text('Check Guess'),
                    ),
                    const SizedBox(width: 10),
                    ElevatedButton.icon(
                      onPressed: () {
                        setState(() {
                          showHint = !showHint;
                        });
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.orange,
                        padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                      ),
                      icon: const Icon(Icons.lightbulb),
                      label: const Text('Show Hint'),
                    ),
                  ],
                ),
                if (showHint)
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Text(
                      'Hint: ${trademarks[currentIndex].hint}',
                      style: const TextStyle(
                        fontSize: 16,
                        fontStyle: FontStyle.italic,
                      ),
                    ),
                  ),
                const SizedBox(height: 20),
                if (isCorrect)
                  ElevatedButton.icon(
                    onPressed: nextTrademark,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),
                    ),
                    icon: const Icon(Icons.arrow_forward),
                    label: const Text('Next Trademark'),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _timer?.cancel();
    _animationController.dispose();
    _guessController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }
} 
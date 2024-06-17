import 'dart:async';
import 'dart:isolate';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:phoenix_nsmq/models.dart';
import 'package:phoenix_nsmq/store.dart';
import 'package:phoenix_nsmq/utils.dart';
import 'package:vxstate/vxstate.dart';
import 'package:onnxruntime/onnxruntime.dart';

const timerCompleted = 'TIMER_COMPLETED';
const timePerQuestion = 20;

class TimerParams {
  final SendPort sendPort;
  final Duration duration;

  TimerParams({required this.sendPort, required this.duration});
}

void timerFunction(TimerParams timerParams) {
  Timer(timerParams.duration, () {
    timerParams.sendPort.send(timerCompleted);
  });
  Timer.periodic(const Duration(seconds: 1), (timer) {
    if (timer.tick == timerParams.duration.inSeconds) {
      timer.cancel();
    }
    timerParams.sendPort.send(timer.tick);
  });
}

class QuestionsScreen extends StatefulWidget {
  const QuestionsScreen({super.key});

  @override
  State<QuestionsScreen> createState() => _QuestionsScreenState();
}

class _QuestionsScreenState extends State<QuestionsScreen> {
  final AppStore _appStore = VxState.store as AppStore;
  int _currentQuetionIndex = -1;
  int _timeLeft = 0;
  int _selectedAnswerIndex = -1;
  int _score = 0;
  late List<Question> _questions;

  late Isolate _isolate;
  bool _isFirstRun = true;

  // late ReceivePort _receivePort;

  void goToMainScreen(BuildContext context) {
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  void onAnswerQuestion(int selectedAnswerIndex) {
    // check if answer is correct
    var currentQuestion = _questions[_currentQuetionIndex];
    var correctAnswerIndex = currentQuestion.correctOptionIndex;
    var correctAnswer = currentQuestion.options[correctAnswerIndex];
    var selectedAnswer = currentQuestion.options[selectedAnswerIndex];
    var isCorrect = correctAnswer == selectedAnswer;

    _isolate.kill(priority: Isolate.immediate);

    // if wrong, show current scrore, correct answer and reason, then end the game
    if (!isCorrect) {
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Incorrect'),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'You got it wrong! The correct answer is $correctAnswer.',
                ),
                const SizedBox(height: 20),
                currentQuestion.reason.isNotEmpty
                    ? Text(
                        'Reason: ${currentQuestion.reason}',
                      )
                    : const SizedBox(),
                const SizedBox(height: 20),
                Text(
                  'Total Score: $_score',
                  style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 20.0,
                  ),
                ),
              ],
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  goToMainScreen(context);
                },
                child: const Text('Go to the Main Menu'),
              ),
            ],
          );
        },
      );
      return;
    }

    setState(() {
      _selectedAnswerIndex = -1;
      _score++;
    });

    // show dialog
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Correct'),
          content: Text('You got it right! The answer is $correctAnswer.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                goToNextQuestion();
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void goToNextQuestion() {
    if (_currentQuetionIndex < _questions.length - 1) {
      setState(() {
        _currentQuetionIndex++;
        // TODO: derive from question. whether is contains calculations or not
        _timeLeft = timePerQuestion;
      });
      startTimerIsolate();
    } else {
      // end of quiz
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: const Text('Congratulations!'),
            content: RichText(
              text: TextSpan(
                text: "You have completed the quiz: ",
                style: const TextStyle(
                  color: Colors.black,
                ),
                children: [
                  TextSpan(
                    text: "\n\nFinal score: $_score",
                    style: const TextStyle(
                      color: Colors.black,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  goToMainScreen(context);
                },
                child: const Text('Finish'),
              ),
            ],
          );
        },
      );
    }
  }

  void onTimerEnd() {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Time Up!'),
          content: const Text('You have run out of time.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
                goToNextQuestion();
              },
              child: const Text('Next'),
            ),
          ],
        );
      },
    );
  }

  void startTimerIsolate() async {
    ReceivePort receivePort = ReceivePort();
    _isolate = await Isolate.spawn(
      timerFunction,
      TimerParams(
        sendPort: receivePort.sendPort,
        // TODO: derive from question. whether is contains calculations or not
        duration: const Duration(seconds: timePerQuestion),
      ),
    );
    receivePort.listen((data) {
      if (data is int) {
        setState(() {
          // TODO: derive from question. whether is contains calculations or not
          _timeLeft = timePerQuestion - data;
        });
      } else if (data == timerCompleted) {
        _isolate.kill(priority: Isolate.immediate);
        receivePort.close();
        onTimerEnd();
      }
    });
  }

  loadTtsModel() async {
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();
    const assetFileName = 'assets/models/test.onnx';
    final rawAssetFile = await rootBundle.load(assetFileName);
    final bytes = rawAssetFile.buffer.asUint8List();
    final session = OrtSession.fromBuffer(bytes, sessionOptions);
  }

  @override
  void initState() {
    super.initState();
    // loadTtsModel();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _questions = ModalRoute.of(context)!.settings.arguments as List<Question>;
    if (_isFirstRun) {
      goToNextQuestion();
      _isFirstRun = false;
    }
  }

  @override
  void dispose() {
    _isolate.kill();
    // OrtEnv.instance.release();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    try {
      var currentQuestion = _questions[_currentQuetionIndex];

      return Scaffold(
        body: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Color(0xFF0E1647),
                        Color(0xFF0A1033),
                      ],
                    ),
                  ),
                ),
              ),
              Column(
                mainAxisSize: MainAxisSize.max,
                children: [
                  // top bar
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 50,
                      vertical: 10,
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            color: Colors.blue.shade900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          padding: const EdgeInsets.only(
                            bottom: 8.0,
                            top: 8.0,
                            right: 18.0,
                            left: 4.0,
                          ),
                          child: Row(
                            children: [
                              IconButton(
                                onPressed: () {
                                  goToMainScreen(context);
                                },
                                icon: const Icon(
                                  Icons.cancel_outlined,
                                  color: Colors.white,
                                ),
                              ),
                              const SizedBox(width: 4),
                              Text(
                                "${getEnumName(_appStore.mode)} (${getEnumName(_appStore.subject)})",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 20,
                                ),
                              ),
                            ],
                          ),
                        ),
                        Text(
                          "00:$_timeLeft",
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 24,
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.yellow.shade900,
                            borderRadius: BorderRadius.circular(4),
                          ),
                          child: RichText(
                            text: TextSpan(
                              text: "Score: ",
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                              ),
                              children: [
                                TextSpan(
                                  text: "$_score",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 20,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                  // question
                  Flexible(
                    flex: 1,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 100.0,
                      ),
                      child: Center(
                        child: Text(
                          currentQuestion.question,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                          ),
                        ),
                      ),
                    ),
                  ),

                  // answer box
                  Center(
                    child: Padding(
                      padding: const EdgeInsets.only(
                        left: 100.0,
                        right: 100.0,
                        bottom: 50.0,
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Expanded(
                            child:
                                currentQuestion.type == QuestionType.TRUE_FALSE
                                    ? Row(
                                        children: [
                                          Radio(
                                            value: 0,
                                            groupValue: _selectedAnswerIndex,
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedAnswerIndex = value;
                                                });
                                                onAnswerQuestion(value);
                                              }
                                            },
                                          ),
                                          const Text(
                                            'True',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                          const SizedBox(width: 40.0),
                                          Radio(
                                            value: 1,
                                            groupValue: _selectedAnswerIndex,
                                            onChanged: (value) {
                                              if (value != null) {
                                                setState(() {
                                                  _selectedAnswerIndex = value;
                                                });
                                                onAnswerQuestion(value);
                                              }
                                            },
                                          ),
                                          const Text(
                                            'False',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      )
                                    : const TextField(
                                        decoration: InputDecoration(
                                          border: OutlineInputBorder(),
                                          labelText: 'Type your answer',
                                        ),
                                      ),
                          ),
                          const SizedBox(width: 20),
                          IconButton(
                            onPressed: () {},
                            icon: const Icon(
                              Icons.mic,
                              color: Colors.white,
                            ),
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                Colors.blue.shade900,
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(100),
                                  side: const BorderSide(
                                    color: Colors.white,
                                    style: BorderStyle.solid,
                                    width: 4.0,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      );
    } catch (e) {
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }
  }
}

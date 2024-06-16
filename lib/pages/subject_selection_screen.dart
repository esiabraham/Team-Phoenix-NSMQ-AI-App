import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:phoenix_nsmq/models.dart';
import 'package:phoenix_nsmq/routes.dart';
import 'package:phoenix_nsmq/services.dart';
import 'package:phoenix_nsmq/store.dart';
import 'package:phoenix_nsmq/utils.dart';
import 'package:vxstate/vxstate.dart';

class SubjectSelectionScreen extends StatefulWidget {
  const SubjectSelectionScreen({super.key});

  @override
  State<SubjectSelectionScreen> createState() => _SubjectSelectionScreenState();
}

class _SubjectSelectionScreenState extends State<SubjectSelectionScreen> {
  AppStore appStore = VxState.store as AppStore;
  String? selectedSubject;

  _SubjectSelectionScreenState() {
    selectedSubject = getEnumName(appStore.subject);
  }

  onStartQuiz() {
    // save subject
    SetSubject(getEnumFromString(selectedSubject!));
    // load questions
    var questions = loadQuestionsFromDisk(getEnumFromString(selectedSubject!));
    // navigate to questions screen
    Navigator.pushNamed(context, questionsRoute, arguments: questions);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: <Widget>[
          const Image(
            width: double.infinity,
            height: double.infinity,
            fit: BoxFit.cover,
            image: AssetImage('lib/assets/images/bg.png'),
          ),
          Positioned.fill(
            child: BackdropFilter(
              filter: ImageFilter.blur(sigmaX: 40, sigmaY: 40),
              child: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                    colors: <Color>[
                      Color.fromRGBO(14, 22, 71, 0.25),
                      Color.fromRGBO(10, 16, 51, 1),
                    ],
                  ),
                ),
                child: Center(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Text(
                        "This quiz section is the True/False round.\nYou will be given a statement and you have to determine if it is true or false.\nReady? Select the subject you want to answer questions on.",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.normal,
                          decoration: TextDecoration.none,
                        ),
                      ),
                      const SizedBox(height: 50),
                      Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          DropdownButton<String>(
                            items: GameSubject.values
                                .map((e) => getEnumName(e))
                                .map((value) {
                              return DropdownMenuItem(
                                value: value,
                                child: Text(value),
                              );
                            }).toList(),
                            value: selectedSubject,
                            onChanged: (subject) {
                              setState(() {
                                selectedSubject = subject;
                              });
                            },
                            hint: const Text(
                              'Select a Subject',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 16,
                              fontWeight: FontWeight.normal,
                              decoration: TextDecoration.none,
                            ),
                            dropdownColor: const Color(0xFF0A1033),
                          ),
                          const SizedBox(width: 20),
                          ElevatedButton(
                            onPressed: () {
                              onStartQuiz();
                            },
                            style: ButtonStyle(
                              backgroundColor: MaterialStateProperty.all<Color>(
                                  const Color(0xFF3E63DD)),
                              padding:
                                  MaterialStateProperty.all<EdgeInsetsGeometry>(
                                const EdgeInsets.symmetric(
                                    horizontal: 40, vertical: 10),
                              ),
                              shape: MaterialStateProperty.all<
                                  RoundedRectangleBorder>(
                                RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                            ),
                            child: const Text(
                              'Go',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.normal,
                                decoration: TextDecoration.none,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: 8.0,
            left: 8.0,
            child: IconButton(
              onPressed: () => {Navigator.pop(context)},
              icon: const Icon(
                Icons.arrow_back,
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

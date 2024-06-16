// ignore_for_file: constant_identifier_names

import 'package:phoenix_nsmq/utils.dart';

enum GameMode {
  MASTERY,
  MULTIPLAYER,
}

enum GameSubject {
  BIOLOGY,
  CHEMISTRY,
  PHYSICS,
  // MATHS,
}

enum QuestionType {
  TRUE_FALSE,
  MULTIPLE_CHOICE,
}

abstract class Question {
  final String question;
  final List<String> options;
  final int correctOptionIndex;
  final GameSubject subject;
  final String reason;
  final QuestionType type;

  static int questionIndex = 0;
  static int correctAnswerIndex = 1;
  static int subjectIndex = 2;
  static int reasonIndex = 3;

  Question({
    required this.question,
    required this.options,
    required this.correctOptionIndex,
    required this.subject,
    required this.type,
    this.reason = '',
  });
}

class TrueFalseQuestion extends Question {
  TrueFalseQuestion({
    required super.question,
    required bool correctAnswer,
    required super.subject,
  }) : super(
          options: ['True', 'False'],
          correctOptionIndex: correctAnswer ? 0 : 1,
          type: QuestionType.TRUE_FALSE,
        );

  static TrueFalseQuestion fromList(List<dynamic> list) {
    return TrueFalseQuestion(
      question: list[Question.questionIndex] as String,
      correctAnswer: (list[Question.correctAnswerIndex] as String)
          .toLowerCase()
          .contains('t'),
      subject: GameSubject.values
          .firstWhere((e) => getEnumName(e) == list[Question.subjectIndex]),
    );
  }
}

class MultipleChoiceQuestion extends Question {
  MultipleChoiceQuestion({
    required super.question,
    required super.options,
    required super.correctOptionIndex,
    required super.subject,
  }) : super(
          type: QuestionType.MULTIPLE_CHOICE,
        );
}

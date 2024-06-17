import 'dart:io';

import 'package:phoenix_nsmq/models.dart';
import 'package:csv/csv.dart';
import 'package:phoenix_nsmq/utils.dart';

// TODO: remove hardcode
const questionsData =
    "/path/to/questions/data.csv";

List<Question> loadQuestionsFromDisk(GameSubject subject) {
  List<TrueFalseQuestion> questions = [];

  var dataFile = File(questionsData);
  var dataFileString = dataFile.readAsStringSync();
  var rows = const CsvToListConverter(eol: "\n").convert(dataFileString);

  for (var row in rows) {
    if (row[Question.subjectIndex] != getEnumName(subject)) {
      continue;
    }
    var question = TrueFalseQuestion.fromList(row);
    questions.add(question);
  }

  return questions;
}

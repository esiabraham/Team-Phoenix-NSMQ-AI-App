
import 'package:phoenix_nsmq/models.dart';

String getEnumName(Enum e) {
  return e.toString().split('.').last;
}

GameSubject getEnumFromString(String str) {
  return GameSubject.values.firstWhere(
    (e) => getEnumName(e) == str,
    orElse: () => throw Exception('Unknown enum value: $str'),
  );
}

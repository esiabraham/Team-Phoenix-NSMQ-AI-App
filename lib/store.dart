import 'package:phoenix_nsmq/models.dart';
import 'package:vxstate/vxstate.dart';

class AppStore extends VxStore {
  GameMode mode = GameMode.MASTERY;
  GameSubject subject = GameSubject.BIOLOGY;
}

// mutations
class SetMode extends VxMutation<AppStore> {
  SetMode(this.m);

  final GameMode m;

  @override
  perform() {
    store?.mode = m;
  }
}


class SetSubject extends VxMutation<AppStore> {
  SetSubject(this.s);

  final GameSubject s;

  @override
  perform() {
    store?.subject = s;
  }
}

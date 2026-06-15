import 'package:flutter/foundation.dart';
enum BuddyState { normal, thinking, reading, sad, happy }

class BuddyProvider extends ChangeNotifier {
  BuddyState _buddyState = BuddyState.normal;
  BuddyState getBuddyState() {
    return _buddyState;
  }

  void changeState(BuddyState buddystate) {
    _buddyState = buddystate;
    notifyListeners();
  }
}

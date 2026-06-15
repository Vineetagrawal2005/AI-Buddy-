import 'package:flutter/foundation.dart';
import 'package:flutter_tts/flutter_tts.dart';

enum TtsState { idle, loading, playing, completed, error }

class TtsProvider extends ChangeNotifier {
  final FlutterTts _tts = FlutterTts();
  TtsState state = TtsState.idle;

  TtsProvider() {
    _tts.setStartHandler(() {
      state = TtsState.playing;
      notifyListeners();
    });

    _tts.setCompletionHandler(() {
      state = TtsState.completed;
      notifyListeners();
    });

    _tts.setErrorHandler((msg) {
      state = TtsState.error;
      notifyListeners();
    });
  }

  Future<void> speak(String text) async {
    state = TtsState.loading;
    notifyListeners();

    // safety timeout
    Future.delayed(const Duration(seconds: 5), () {
      if (state == TtsState.loading) {
        state = TtsState.error;
        notifyListeners();
      }
    });

    try {
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.38); // slightly faster = more energetic
      await _tts.setPitch(1.0); // very high = cheerful/joyful
      await _tts.setVolume(1.0);

      var result = await _tts.speak(text);
      if (result != 1) {
        state = TtsState.error;
        notifyListeners();
      }
    } catch (e) {
      state = TtsState.error;
      notifyListeners();
    }
  }

  Future<void> stop() async {
    await _tts.stop();
    state = TtsState.idle;
    notifyListeners();
  }

  @override
  void dispose() {
    _tts.stop();
    super.dispose();
  }
}

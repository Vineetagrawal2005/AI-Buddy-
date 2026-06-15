import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';
import 'package:pabelo/data/model/quiz_model.dart';
import 'package:pabelo/data/model/story_model.dart';

enum QuizState { hidden, visible, wrong, success }

class StoryProvider extends ChangeNotifier {
  String _story = "";
List<QuizModel> _quizModel = [];
  QuizState _quizState = QuizState.hidden;
  String? _selectedOption;
  int currentIndex = 0;
  String get story => _story;
  QuizState get quizState => _quizState;
  String? get selectedOption => _selectedOption;
  QuizModel getCurrentQuiz() {
    return _quizModel[currentIndex];
  }

  bool isLastQuestion() {
    return currentIndex == _quizModel.length - 1;
  }

  void loadStory(StoryModel storyData) {
    _story = storyData.story;
    _quizModel = storyData.quiz;
    notifyListeners();
  }

  void reveal() {
    _quizState = QuizState.visible;
    notifyListeners();
  }

  void resetWrong() {
    _quizState = QuizState.visible;
    notifyListeners();
  }

  void nextQuestion() {
    currentIndex++;
    _selectedOption = null;
    _quizState = QuizState.visible;
    notifyListeners();
  }

void selectOption(String selectedOption) {
  if (_quizState == QuizState.wrong || _quizState == QuizState.success) return;
  _selectedOption = selectedOption;
  if (getCurrentQuiz().answer == _selectedOption) {
    _quizState = QuizState.success;
  } else {
    _quizState = QuizState.wrong;
    HapticFeedback.mediumImpact();
  }
  notifyListeners();
}

  void restart() {
    currentIndex = 0;
    _quizState = QuizState.hidden;
    _selectedOption = null;
    notifyListeners();
  }
}

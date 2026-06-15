import 'package:flutter/cupertino.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/data/model/quiz_model.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:pabelo/widget/option_button.dart';
import 'package:pabelo/widget/shake_widget.dart';
import 'package:pabelo/widget/success_card.dart';
import 'package:provider/provider.dart';

class Quiz extends StatelessWidget {
  const Quiz({super.key});

  @override
  Widget build(BuildContext context) {
    StoryProvider storyData = context.watch<StoryProvider>();
    QuizModel quizData = storyData.getCurrentQuiz();
    String questionQuiz = quizData.question;
    List<String> optionQuiz = quizData.options;
    QuizState quizState = storyData.quizState;
    bool isQuizStateSuccess = (quizState == QuizState.success);
    return Container(
      padding: EdgeInsets.all(AppDimens.screenPadding),
      child: AnimatedSwitcher(
        duration: Duration(milliseconds: 200),
        child: isQuizStateSuccess
            ? SuccessCard(key: ValueKey('success'))
            : Column(
                key: ValueKey('quiz'),
                children: [
                  Text(
                    questionQuiz,
                    style: AppTextStyles.quizQuestion,
                    textAlign: TextAlign.center,
                  ),
                  ...optionQuiz.map((option) {
                    bool isSelected = storyData.selectedOption == option;
                    return ShakeWidget(
                      trigger: quizState == QuizState.wrong,
                      onShakeComplete: () => storyData.resetWrong(),
                      child: Padding(
                        padding: const EdgeInsets.all(AppDimens.cardPadding),
                        child: OptionButton(
                          text: option,
                          isCorrect:
                              isSelected && quizState == QuizState.success,
                          isWrong: isSelected && quizState == QuizState.wrong,
                          onTap: () => storyData.selectOption(option),
                        ),
                      ),
                    );
                  }),
                  SizedBox(height: AppDimens.sectionSpacing,)
                ],
              ),
      ),
    );
  }
}

import 'package:confetti/confetti.dart';
import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/data/repo/story_repo.dart';
import 'package:pabelo/provider/buddy_provider.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:pabelo/provider/tts_provider.dart';
import 'package:pabelo/widget/buddy.dart';
import 'package:pabelo/widget/confetti_overlay.dart';
import 'package:pabelo/widget/error.dart';
import 'package:pabelo/widget/loading.dart';
import 'package:pabelo/widget/quiz.dart';
import 'package:pabelo/widget/story.dart';
import 'package:provider/provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late ConfettiController confettiController;
  bool _confettiPlayed = false;
  bool _quizRevealed = false;
  @override
  void initState() {
    super.initState();
    initializeStory();
  }

  void initializeStory() async {
    confettiController = ConfettiController();
    final storyProvider = context.read<StoryProvider>();
    final allData = await loadAll();
    storyProvider.loadStory(allData);
  }

  @override
  void dispose() {
    confettiController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final ttsProvider = context.watch<TtsProvider>();
    final storyProvider = context.watch<StoryProvider>();
    final buddyProvider = context.read<BuddyProvider>();

    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (ttsProvider.state == TtsState.loading) {
        buddyProvider.changeState(BuddyState.thinking);
      } else if (ttsProvider.state == TtsState.playing) {
        buddyProvider.changeState(BuddyState.reading);
      } else if (ttsProvider.state == TtsState.completed) {
        buddyProvider.changeState(BuddyState.normal);
        if (!_quizRevealed) {
          storyProvider.reveal();
          _quizRevealed = true;
        }
      } else if (ttsProvider.state == TtsState.error) {
        buddyProvider.changeState(BuddyState.sad);
      }

      if (storyProvider.quizState == QuizState.success) {
        buddyProvider.changeState(BuddyState.happy);
        if (!_confettiPlayed) {
          confettiController.play();
          _confettiPlayed = true;
        }
      } else if (storyProvider.quizState == QuizState.wrong) {
        buddyProvider.changeState(BuddyState.sad);
      } else if (storyProvider.quizState == QuizState.visible) {
        confettiController.stop();
        _confettiPlayed = false;
        buddyProvider.changeState(BuddyState.thinking);
      } else if (storyProvider.quizState == QuizState.hidden) {
        confettiController.stop();
        _confettiPlayed = false;
        _quizRevealed = false;
      }
    });
    return Scaffold(
      backgroundColor: AppColors.cardGray,
      appBar: AppBar(
        elevation: 2,
        backgroundColor: AppColors.cardGray,
        title: Text("AI Story Buddy", style: AppTextStyles.appBarTitle),
        leading: Icon(Icons.menu),
        actions: [Icon(Icons.person_outline, color: AppColors.primaryPurple)],
      ),
      body: Stack(
        alignment: Alignment.center,
        children: [
          SingleChildScrollView(
            child: (storyProvider.quizState == QuizState.hidden)
                ? Column(
                    children: [
                      Buddy(),
                      SizedBox(height: AppDimens.sectionSpacing),
                      StoryCard(),
                      SizedBox(height: AppDimens.sectionSpacing),
                      Padding(
                        padding: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.sectionSpacing,
      ),
                        child: buttonAccBuddy(
                          ttsProvider.state,
                          ttsProvider,
                          storyProvider,
                        ),
                      ),
                    ],
                  )
                : Quiz(),
          ),
          if (storyProvider.quizState != QuizState.hidden &&
              storyProvider.quizState != QuizState.success)
            Positioned(
              bottom: 16,
              right: 16,
              child: SizedBox(height: 250, width: 250, child: Buddy()),
            ),

          ConfettiOverlay(controller: confettiController),
        ],
      ),
    );
  }

  Widget buttonAccBuddy(
    TtsState ttsState,
    TtsProvider ttsProvider,
    StoryProvider storyProvider,
  ) {
    if (ttsState == TtsState.error) {
      return ErrorCard();
    } else if (ttsState == TtsState.loading) {
      return LoadingCard();
    } else if (ttsState == TtsState.playing) {
      return ElevatedButton(
        onPressed: null,

        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
          minimumSize: Size(double.infinity, AppDimens.buttonHeight),
        ),
        child: Text("Reading ...", style: AppTextStyles.buttonText),
      );
    } else {
      return ElevatedButton.icon(
        onPressed: () => ttsProvider.speak(storyProvider.story),
        label: Text("Read Me A Story", style: AppTextStyles.buttonText),
        icon: Icon(Icons.volume_up, color: AppColors.background),
        style: ElevatedButton.styleFrom(
          minimumSize: Size(double.infinity, AppDimens.buttonHeight),
          backgroundColor: AppColors.primaryPurple,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
          ),
        ),
      );
    }
  }
}

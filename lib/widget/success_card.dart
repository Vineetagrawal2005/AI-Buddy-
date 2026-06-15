import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:provider/provider.dart';

class SuccessCard extends StatefulWidget {
  const SuccessCard({super.key});
  @override
  State<SuccessCard> createState() => _SuccessCardState();
}

class _SuccessCardState extends State<SuccessCard> {

  @override
  void initState() {
    super.initState();
    Future.delayed(const Duration(seconds: 10), () {
      if (!mounted) return;
      final provider = context.read<StoryProvider>();
      if (provider.isLastQuestion()) {
        provider.restart();
      } else {
        provider.nextQuestion();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    bool isLast = context.watch<StoryProvider>().isLastQuestion();
    return Container(
      margin: EdgeInsets.symmetric(
    horizontal: AppDimens.screenPadding,
    vertical: AppDimens.sectionSpacing,
  ),
  padding: EdgeInsets.all(AppDimens.cardPadding),
  constraints: BoxConstraints(
    minHeight: 500, ),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.borderGray),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.asset('assets/image/happy.png', height: 300),
          Text(
            "Correct Answer! Brilliant!",
            style: TextStyle(
              color: AppColors.primaryPurple,
              fontSize: 22,
              fontWeight: FontWeight.bold,
            ),
          ),
          Text(
            isLast
                ? "Quiz Completed! Well Done!"
                : "Moving to next question...",
            style: AppTextStyles.storyLabel,
          ),
        ],
      ),
    );
  }
}

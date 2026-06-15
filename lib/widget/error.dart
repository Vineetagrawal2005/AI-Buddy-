import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:pabelo/provider/tts_provider.dart';
import 'package:provider/provider.dart';

class ErrorCard extends StatelessWidget {
  const ErrorCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(AppDimens.screenPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            "Oops! Buddy lost his voice!",
            style: AppTextStyles.placeholderText,
          ),
          SizedBox(height: AppDimens.sectionSpacing),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadiusGeometry.circular(
                  AppDimens.buttonRadius,
                ),
              ),
              fixedSize: Size(double.infinity, AppDimens.buttonHeight),
            ),
            onPressed: () {
              final story = context.read<StoryProvider>().story;
              context.read<TtsProvider>().speak(story);
            },
            child: Text("Try Again", style: AppTextStyles.buttonText),
          ),
        ],
      ),
    );
  }
}

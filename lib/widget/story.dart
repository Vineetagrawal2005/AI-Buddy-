import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/provider/story_provider.dart';
import 'package:provider/provider.dart';

class StoryCard extends StatelessWidget {
  const StoryCard({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: EdgeInsets.symmetric(
        horizontal: AppDimens.screenPadding,
        vertical: AppDimens.sectionSpacing,
      ),
      padding: EdgeInsets.all(AppDimens.cardPadding),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppDimens.cardRadius),
        border: Border.all(color: AppColors.borderGray, width: 1.5),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("STORY TEXT APPEARS HERE", style: AppTextStyles.storyLabel),
              Icon(Icons.menu_book, color: AppColors.borderGray),
            ],
          ),
          SizedBox(height: 12),
          Text(
            context.watch<StoryProvider>().story.isEmpty
                ? "Loading story..."
                : context.watch<StoryProvider>().story,
            style: AppTextStyles.storyText,
          ),
        ],
      ),
    );
  }
}

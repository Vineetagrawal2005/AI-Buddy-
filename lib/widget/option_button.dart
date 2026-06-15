import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';

class OptionButton extends StatelessWidget {
  const OptionButton({
    super.key,
    required this.text,
    required this.isCorrect,
    required this.isWrong,
    required this.onTap,
  });
  final String text;
  final bool isCorrect;
  final bool isWrong;
  final VoidCallback onTap;
  @override
  Widget build(BuildContext context) {
    Color color = isCorrect
        ? AppColors.successGreen
        : isWrong
        ? AppColors.errorRed
        : AppColors.borderGray;
    return InkWell(
      onTap: onTap,
      child: Container(
        padding: EdgeInsets.all(AppDimens.sectionSpacing),
        width: double.infinity,
        height: AppDimens.buttonHeight,
        decoration: BoxDecoration(
          border: BoxBorder.all(color: color),
          borderRadius: BorderRadius.circular(AppDimens.buttonRadius),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(text, style: AppTextStyles.quizOption),
            Icon(Icons.circle_outlined, color: color),
          ],
        ),
      ),
    );
  }
}

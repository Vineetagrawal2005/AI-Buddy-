import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';

class LoadingCard extends StatelessWidget {
  const LoadingCard({super.key});

  @override
  Widget build(BuildContext context) {
    return  Column(
        children: [
          CircularProgressIndicator(color: AppColors.darkPurple),
          SizedBox(height: 8),
          Text("Preparing....", style: AppTextStyles.storyLabel),
        ],
    );
  }
}

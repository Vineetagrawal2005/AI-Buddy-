import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:pabelo/core/design_constraint.dart';
import 'package:pabelo/provider/buddy_provider.dart';
import 'package:provider/provider.dart';

class Buddy extends StatelessWidget {
  const Buddy({super.key});
  @override

  Widget build(BuildContext context) {
  Map<BuddyState,String> state={
  BuddyState.normal : "assets/image/normal.png",
  BuddyState.happy : "assets/image/happy.png",
  BuddyState.reading : "assets/image/reading.png",
  BuddyState.sad : "assets/image/sad.png",
  BuddyState.thinking : "assets/image/thinking.png",
 };
 String buddyImageString=state[context.watch<BuddyProvider>().getBuddyState()] as String;
    return AspectRatio(aspectRatio: AppDimens.buddyAspectRatio,
    child: AnimatedSwitcher(duration: Duration(milliseconds: 200),
    child: Image.asset(buddyImageString,key: Key(buddyImageString),)),);
  }
}

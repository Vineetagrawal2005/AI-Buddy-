import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:pabelo/data/model/quiz_model.dart';
import 'package:pabelo/data/model/story_model.dart';

const String _assetpath = 'assets/Story_Quiz.json';
Future<StoryModel> loadAll() async {
  final jsonString = await rootBundle.loadString(_assetpath);
  final Map<String, dynamic> jsonMap = jsonDecode(jsonString);
  final String storyData = jsonMap['story'] as String;
  final List<dynamic> quizData = jsonMap['quiz'] as List<dynamic>;
  StoryModel data = StoryModel(
    story: storyData,
    quiz: quizData
        .map((item) => QuizModel.fromJson(item as Map<String, dynamic>))
        .toList(),
  );
  return data;
}

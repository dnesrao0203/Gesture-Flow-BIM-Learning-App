import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LessonProgressProvider with ChangeNotifier {
  final Map<String, int> _completedLessons = {};
  bool _isLoading = false;

  bool get isLoading => _isLoading;

  // The constructor no longer calls loadCompletedLessons().
  // This is handled by AuthWrapper when a user is confirmed to be signed in.
  LessonProgressProvider();

  // Loads completed lesson counts for the current user.
  Future<void> loadCompletedLessons() async {
    _isLoading = true;
    notifyListeners();

    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      clearProgress();
      return;
    }

    try {
      _completedLessons.clear();

      // Use efficient count queries to get the number of completed lessons per chapter.
      final chapter1Count = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedLessons')
          .where('chapter', isEqualTo: 'Chapter 1')
          .count()
          .get();
      _completedLessons['Chapter 1'] = chapter1Count.count ?? 0;

      final chapter2Count = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedLessons')
          .where('chapter', isEqualTo: 'Chapter 2')
          .count()
          .get();
      _completedLessons['Chapter 2'] = chapter2Count.count ?? 0;

      final chapter3Count = await FirebaseFirestore.instance
          .collection('users')
          .doc(user.uid)
          .collection('completedLessons')
          .where('chapter', isEqualTo: 'Chapter 3')
          .count()
          .get();
      _completedLessons['Chapter 3'] = chapter3Count.count ?? 0;

    } catch (e) {
      print("Error loading completed lessons: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Resets the progress data.
  void clearProgress() {
    _completedLessons.clear();
    _isLoading = false;
    notifyListeners();
  }

  int getCompletedLessons(String chapter) {
    return _completedLessons[chapter] ?? 0;
  }

  // Marks a lesson as complete in Firestore and updates the local state.
  Future<void> completeLesson(String chapter, String lessonTitle) async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      return;
    }

    final docId = '$chapter-$lessonTitle';
    final lessonRef = FirebaseFirestore.instance
        .collection('users')
        .doc(user.uid)
        .collection('completedLessons')
        .doc(docId);

    final docSnapshot = await lessonRef.get();
    if (docSnapshot.exists) {
      return;
    }

    try {
      await lessonRef.set({
        'chapter': chapter,
        'lessonTitle': lessonTitle,
        'completedAt': FieldValue.serverTimestamp(),
      });

      _completedLessons[chapter] = (_completedLessons[chapter] ?? 0) + 1;
      notifyListeners();
    } catch (e) {
      print("Error completing lesson: $e");
    }
  }
}
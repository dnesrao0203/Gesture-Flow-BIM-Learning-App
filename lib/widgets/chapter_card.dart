import 'package:flutter/material.dart';

class ChapterCard extends StatelessWidget {
  final String chapter;
  final String title;
  final int completedLessons;
  final int totalLessons;
  final List<Map<String, String>> lessons;
  final Function(int) onContinue;
  final IconData iconData; // ADDED: New property for the icon

  const ChapterCard({
    super.key,
    required this.chapter,
    required this.title,
    required this.completedLessons,
    required this.totalLessons,
    required this.lessons,
    required this.onContinue,
    required this.iconData, // ADDED: Add to the constructor
  });

  @override
  Widget build(BuildContext context) {
    double progress = totalLessons > 0 ? completedLessons / totalLessons : 0.0;
    bool isCompleted = progress == 1.0;

    return Card(
      color: const Color(0xFFF3F4F6),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15.0),
      ),
      elevation: 5,
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row( // ADDED: Wrap the icon and text in a Row
                  children: [
                    Icon(iconData, color: const Color(0xFF828282)), // ADDED: The icon
                    const SizedBox(width: 8), // ADDED: Spacing
                    Text(
                      chapter,
                      style: const TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF828282),
                      ),
                    ),
                  ],
                ),
                isCompleted
                    ? const Icon(
                        Icons.check_circle,
                        color: Color(0xFF219D4A),
                      )
                    : const SizedBox.shrink(),
              ],
            ),
            const SizedBox(height: 8),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Color(0xFF212121),
              ),
            ),
            const SizedBox(height: 12),
            LinearProgressIndicator(
              value: progress,
              backgroundColor: const Color(0xFFE0E0E0),
              valueColor: const AlwaysStoppedAnimation<Color>(
                Color(0xFF00A5CF), // This is the light blue color
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "$completedLessons of $totalLessons lessons completed",
              style: const TextStyle(
                fontSize: 14,
                color: Color(0xFF828282),
              ),
            ),
            const SizedBox(height: 16),
            Align(
              alignment: Alignment.centerRight,
              child: ElevatedButton(
                onPressed: () {
                  int nextLessonIndex = completedLessons;
                  if (nextLessonIndex >= totalLessons) {
                    nextLessonIndex = 0; // Start over if completed
                  }
                  onContinue(nextLessonIndex);
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: isCompleted
                      ? const Color(0xFF219D4A) // Green for completed
                      : const Color(0xFF364FC7), // Blue for continue
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
                child: Text(isCompleted ? "Start Over" : "Continue"),
              ),
            ),
          ],
        ),
      ),
    );
  }
}


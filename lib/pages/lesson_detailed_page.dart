import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background1.dart';
import 'lesson_progress_provider.dart';

class LessonDetailPage extends StatefulWidget {
  final String chapter;
  final int lessonIndex;
  final List<Map<String, String>> lessons;

  const LessonDetailPage({
    super.key,
    required this.chapter,
    required this.lessonIndex,
    required this.lessons,
  });

  @override
  LessonDetailPageState createState() => LessonDetailPageState();
}

class LessonDetailPageState extends State<LessonDetailPage> {
  late int _currentLessonIndex;

  @override
  void initState() {
    super.initState();
    _currentLessonIndex = widget.lessonIndex;
  }

  void _goToNextLesson() {
    final lessonProgress = Provider.of<LessonProgressProvider>(context, listen: false);

    final lessonTitle = widget.lessons[_currentLessonIndex]['title']!;
    lessonProgress.completeLesson(widget.chapter, lessonTitle);

    if (_currentLessonIndex < widget.lessons.length - 1) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailPage(
            chapter: widget.chapter,
            lessonIndex: _currentLessonIndex + 1,
            lessons: widget.lessons,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  void _goToPreviousLesson() {
    if (_currentLessonIndex > 0) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailPage(
            chapter: widget.chapter,
            lessonIndex: _currentLessonIndex - 1,
            lessons: widget.lessons,
          ),
        ),
      );
    } else {
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    final currentLesson = widget.lessons[_currentLessonIndex];
    final isLastLesson = _currentLessonIndex == widget.lessons.length - 1;

    final imageName = currentLesson['title']!.toLowerCase().replaceAll(' ', '_');
    final imagePathJpg = 'assets/images/$imageName.jpg';
    final imagePathGif = 'assets/images/$imageName.gif';

    return Scaffold(
      body: GradientBackground(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16.0, 40.0, 16.0, 16.0),
              child: Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.arrow_back, color: Colors.white),
                    onPressed: () {
                      Navigator.pop(context);
                    },
                  ),
                  const SizedBox(width: 8),
                  Text(widget.chapter, style: const TextStyle(fontSize: 24, color: Colors.white)),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 40.0, vertical: 20.0),
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10.0),
                ),
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  children: [
                    Text(
                      currentLesson['title']!,
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 8.0),
                    Container(
                      height: 5.0,
                      width: 100,
                      color: const Color(0xFF219D4A),
                    ),
                    const SizedBox(height: 8.0),
                    Text(
                      currentLesson['subtitle'] ?? '',
                      style: const TextStyle(fontSize: 20, color: Colors.black),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),
            ),
            Center(
              child: Image.asset(
                imagePathJpg,
                height: 300,
                width: 300,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Image.asset(
                    imagePathGif,
                    height: 300,
                    width: 300,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) => const Icon(Icons.image_not_supported, size: 200),
                  );
                },
              ),
            ),
            const SizedBox(height: 20),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: _currentLessonIndex > 0 ? _goToPreviousLesson : null,
                    child: Text(
                      'Previous',
                      style: TextStyle(
                        fontSize: 16,
                        color: _currentLessonIndex > 0 ? Colors.black : Colors.grey,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: _goToNextLesson,
                    child: Text(
                      isLastLesson ? 'Done' : 'Next',
                      style: const TextStyle(
                        fontSize: 16,
                        color: Colors.black,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 10),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              child: Column(
                children: [
                  LinearProgressIndicator(
                    value: (_currentLessonIndex + 1) / widget.lessons.length,
                    backgroundColor: Colors.white,
                    valueColor: const AlwaysStoppedAnimation<Color>(Color(0xFF219D4A)),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    '${_currentLessonIndex + 1} of ${widget.lessons.length} lessons completed',
                    style: const TextStyle(fontSize: 16, color: Colors.black),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}


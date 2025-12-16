import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../widgets/background1.dart';
import '../widgets/chapter_card.dart';
import 'lesson_detailed_page.dart';
import 'lesson_progress_provider.dart';

class LessonPage extends StatefulWidget {
  const LessonPage({super.key});

  @override
  LessonPageState createState() => LessonPageState();
}

class LessonPageState extends State<LessonPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, String>> _allLessons = [];
  List<Map<String, String>> _filteredLessons = [];

  final List<Map<String, String>> _alphabetLessons = [
    {'title': 'A', 'subtitle': 'Letter A'},
    {'title': 'B', 'subtitle': 'Letter B'},
    {'title': 'C', 'subtitle': 'Letter C'},
    {'title': 'D', 'subtitle': 'Letter D'},
    {'title': 'E', 'subtitle': 'Letter E'},
    {'title': 'F', 'subtitle': 'Letter F'},
    {'title': 'G', 'subtitle': 'Letter G'},
    {'title': 'H', 'subtitle': 'Letter H'},
    {'title': 'I', 'subtitle': 'Letter I'},
    {'title': 'J', 'subtitle': 'Letter J'},
  ];
  final List<Map<String, String>> _greetingLessons = [
    {'title': 'Hai', 'subtitle': 'Hello'},
    {'title': 'Minta Maaf', 'subtitle': 'Sorry'},
    {'title': 'Terima Kasih', 'subtitle': 'Thank You'},
    {'title': 'Ya', 'subtitle': 'Yes'},
    {'title': 'Tidak', 'subtitle': 'No'},
  ];
  final List<Map<String, String>> _colourLessons = [
    {'title': 'Merah', 'subtitle': 'Red'},
    {'title': 'Hijau', 'subtitle': 'Green'},
    {'title': 'Kuning', 'subtitle': 'Yellow'},
    {'title': 'Hitam', 'subtitle': 'Black'},
    {'title': 'Putih', 'subtitle': 'White'},
  ];

  @override
  void initState() {
    super.initState();
    _allLessons.addAll(_alphabetLessons);
    _allLessons.addAll(_greetingLessons);
    _allLessons.addAll(_colourLessons);
    _filteredLessons = _allLessons;
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchController.removeListener(_onSearchChanged);
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _filteredLessons = query.isEmpty
          ? _allLessons
          : _allLessons
              .where((lesson) =>
                  lesson['title']!.toLowerCase().contains(query) ||
                  lesson['subtitle']!.toLowerCase().contains(query))
              .toList();
    });
  }

  void _navigateToLesson(String title) {
    List<Map<String, String>> chapterLessons;
    String chapterTitle;
    int lessonIndex;

    if (_alphabetLessons.any((lesson) => lesson['title'] == title)) {
      chapterLessons = _alphabetLessons;
      chapterTitle = "Chapter 1";
    } else if (_greetingLessons.any((lesson) => lesson['title'] == title)) {
      chapterLessons = _greetingLessons;
      chapterTitle = "Chapter 2";
    } else {
      chapterLessons = _colourLessons;
      chapterTitle = "Chapter 3";
    }

    lessonIndex =
        chapterLessons.indexWhere((lesson) => lesson['title'] == title);

    if (lessonIndex != -1) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => LessonDetailPage(
            chapter: chapterTitle,
            lessonIndex: lessonIndex,
            lessons: chapterLessons,
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final lessonProgress = Provider.of<LessonProgressProvider>(context);

    return Scaffold(
      body: GradientBackground(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: 40),
              const Text(
                "Lessons",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 20),
              Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: TextField(
                  controller: _searchController,
                  decoration: const InputDecoration(
                    hintText: "Search for handsign",
                    prefixIcon: Icon(Icons.search, color: Colors.grey),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.symmetric(vertical: 20, horizontal: 20),
                  ),
                ),
              ),
              const SizedBox(height: 24),
              Expanded(
                child: _searchController.text.isEmpty
                    ? ListView(
                        children: [
                          ChapterCard(
                            chapter: "Chapter 1",
                            title: "Alphabet",
                            completedLessons:
                                lessonProgress.getCompletedLessons('Chapter 1'),
                            totalLessons: _alphabetLessons.length,
                            lessons: _alphabetLessons,
                            onContinue: (index) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonDetailPage(
                                    chapter: "Chapter 1",
                                    lessonIndex: index,
                                    lessons: _alphabetLessons,
                                  ),
                                ),
                              );
                            },
                            iconData: Icons.sort_by_alpha,
                          ),
                          const SizedBox(height: 12),
                          ChapterCard(
                            chapter: "Chapter 2",
                            title: "Greeting",
                            completedLessons:
                                lessonProgress.getCompletedLessons('Chapter 2'),
                            totalLessons: _greetingLessons.length,
                            lessons: _greetingLessons,
                            onContinue: (index) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonDetailPage(
                                    chapter: "Chapter 2",
                                    lessonIndex: index,
                                    lessons: _greetingLessons,
                                  ),
                                ),
                              );
                            },
                            iconData: Icons.waving_hand,
                          ),
                          const SizedBox(height: 12),
                          ChapterCard(
                            chapter: "Chapter 3",
                            title: "Colour",
                            completedLessons:
                                lessonProgress.getCompletedLessons('Chapter 3'),
                            totalLessons: _colourLessons.length,
                            lessons: _colourLessons,
                            onContinue: (index) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => LessonDetailPage(
                                    chapter: "Chapter 3",
                                    lessonIndex: index,
                                    lessons: _colourLessons,
                                  ),
                                ),
                              );
                            },
                            iconData: Icons.color_lens,
                          ),
                        ],
                      )
                    : ListView.builder(
                        itemCount: _filteredLessons.length,
                        itemBuilder: (context, index) {
                          final lesson = _filteredLessons[index];
                          return Card(
                            color: Colors.white,
                            margin: const EdgeInsets.symmetric(vertical: 8.0),
                            child: ListTile(
                              title: Text(lesson['title']!),
                              subtitle: Text(lesson['subtitle']!),
                              onTap: () => _navigateToLesson(lesson['title']!),
                            ),
                          );
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}


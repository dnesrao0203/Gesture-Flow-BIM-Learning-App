import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../widgets/background1.dart';
import '../widgets/chapter_card.dart';
import 'lessons_page.dart';
import 'test_page.dart';
import 'profile_page.dart';
import 'lesson_detailed_page.dart';
import 'lesson_progress_provider.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends State<HomePage> {
  int _selectedIndex = 0;
  final List<bool> _dayStreak = [false, false, false, false, true, false, false];

  //String _userName = 'User';
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final alphabetLessons = [
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
  final greetingLessons = [
    {'title': 'Hai', 'subtitle': 'Hello'},
    {'title': 'Minta Maaf', 'subtitle': 'Sorry'},
    {'title': 'Terima Kasih', 'subtitle': 'Thank You'},
    {'title': 'Ya', 'subtitle': 'Yes'},
    {'title': 'Tidak', 'subtitle': 'No'},
  ];
  final colourLessons = [
    {'title': 'Merah', 'subtitle': 'Red'},
    {'title': 'Hijau', 'subtitle': 'Green'},
    {'title': 'Kuning', 'subtitle': 'Yellow'},
    {'title': 'Hitam', 'subtitle': 'Black'},
    {'title': 'Putih', 'subtitle': 'White'},
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  Widget _buildDayStreakItem(String day, bool isCompleted) {
    return Column(
      children: [
        Container(
          width: 35,
          height: 35,
          decoration: BoxDecoration(
            color: isCompleted ? const Color(0xFFF9A825) : Colors.white.withOpacity(0.5),
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 1),
          ),
          child: Center(
            child: isCompleted
                ? const Icon(Icons.local_fire_department, color: Colors.white)
                : Text(day, style: const TextStyle(color: Colors.black)),
          ),
        ),
        const SizedBox(height: 5),
        Text(day, style: const TextStyle(color: Colors.white)),
      ],
    );
  }

  Widget _buildHomePageContent(BuildContext context) {
    final lessonProgress = Provider.of<LessonProgressProvider>(context);
    final User? currentUser = _auth.currentUser;

    return GradientBackground(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      "Welcome back,",
                      style: TextStyle(
                        fontSize: 22,
                        color: Colors.white,
                      ),
                    ),
                    StreamBuilder<DocumentSnapshot>(
                      stream: _firestore.collection('users').doc(currentUser?.uid).snapshots(),
                      builder: (context, snapshot) {
                        if (snapshot.hasData && snapshot.data!.exists) {
                          final userData = snapshot.data!.data() as Map<String, dynamic>;
                          final name = userData['name'] ?? 'User';
                          return Text(
                            name,
                            style: const TextStyle(
                              fontSize: 22,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          );
                        }
                        return const Text(
                          'User',
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ],
            ),
            const SizedBox(height: 20),
            Container(
              decoration: BoxDecoration(
                color: const Color(0xFF00A5CF),
                borderRadius: BorderRadius.circular(15),
              ),
              padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _buildDayStreakItem('Mon', _dayStreak[0]),
                  _buildDayStreakItem('Tue', _dayStreak[1]),
                  _buildDayStreakItem('Wed', _dayStreak[2]),
                  _buildDayStreakItem('Thu', _dayStreak[3]),
                  _buildDayStreakItem('Fri', _dayStreak[4]),
                  _buildDayStreakItem('Sat', _dayStreak[5]),
                  _buildDayStreakItem('Sun', _dayStreak[6]),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text(
              "Continue where you left off,",
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView(
                children: [
                  ChapterCard(
                    chapter: "Chapter 1",
                    title: "Alphabet",
                    completedLessons: lessonProgress.getCompletedLessons('Chapter 1'),
                    totalLessons: alphabetLessons.length,
                    lessons: alphabetLessons,
                    onContinue: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailPage(
                            chapter: "Chapter 1",
                            lessonIndex: index,
                            lessons: alphabetLessons,
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
                    completedLessons: lessonProgress.getCompletedLessons('Chapter 2'),
                    totalLessons: greetingLessons.length,
                    lessons: greetingLessons,
                    onContinue: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailPage(
                            chapter: "Chapter 2",
                            lessonIndex: index,
                            lessons: greetingLessons,
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
                    completedLessons: lessonProgress.getCompletedLessons('Chapter 3'),
                    totalLessons: colourLessons.length,
                    lessons: colourLessons,
                    onContinue: (index) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => LessonDetailPage(
                            chapter: "Chapter 3",
                            lessonIndex: index,
                            lessons: colourLessons,
                          ),
                        ),
                      );
                    },
                    iconData: Icons.color_lens,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      _buildHomePageContent(context),
      const LessonPage(),
      const TestPage(),
      const ProfilePage(),
    ];

    return Scaffold(
      body: pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
        selectedItemColor: Colors.black,
        unselectedItemColor: Colors.white,
        backgroundColor: const Color(0xFF00A5CF),
        type: BottomNavigationBarType.fixed,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.book), label: "Lesson"),
          BottomNavigationBarItem(icon: Icon(Icons.camera_alt), label: "Test"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}


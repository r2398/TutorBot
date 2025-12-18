import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/profile_provider.dart';
import '../providers/theme_provider.dart';
import '../models/learning_profile.dart';
import 'tutoring_view.dart';
import 'practice_zone.dart';
import 'progress_dashboard.dart';
import 'badges_view.dart';
import 'study_plan_view.dart';

class MainInterface extends StatefulWidget {
  const MainInterface({super.key});

  @override
  State<MainInterface> createState() => _MainInterfaceState();
}

class _MainInterfaceState extends State<MainInterface> {
  int _currentIndex = 0;
  Subject _currentSubject = Subject.mathematics;

  @override
  void initState() {
    super.initState();
    final profile = context.read<ProfileProvider>().profile;
    if (profile != null) {
      _currentSubject = profile.preferredSubject;
    }
  }

  @override
  Widget build(BuildContext context) {
    final profile = context.watch<ProfileProvider>().profile;

    if (profile == null) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    final views = [
      TutoringView(subject: _currentSubject),
      PracticeZone(subject: _currentSubject),
      const ProgressDashboard(),
      const BadgesView(),
      const StudyPlanView(),
    ];

    return Scaffold(
      appBar: AppBar(
        title: Text(_getTitle()),
        actions: [
          // Subject switcher (only show on tutor and practice tabs)
          if (_currentIndex < 2)
            PopupMenuButton<Subject>(
              icon: Icon(_getSubjectIcon(_currentSubject)),
              onSelected: (subject) {
                setState(() {
                  _currentSubject = subject;
                });
              },
              itemBuilder: (context) => Subject.values.map((subject) {
                return PopupMenuItem(
                  value: subject,
                  child: Row(
                    children: [
                      Icon(_getSubjectIcon(subject)),
                      const SizedBox(width: 12),
                      Text(subject.displayName),
                    ],
                  ),
                );
              }).toList(),
            ),

          // Theme toggle
          IconButton(
            icon: Icon(
              context.watch<ThemeProvider>().isDarkMode
                  ? Icons.light_mode
                  : Icons.dark_mode,
            ),
            onPressed: () {
              context.read<ThemeProvider>().toggleTheme();
            },
          ),

          // Profile menu
          PopupMenuButton<void>(
            icon: CircleAvatar(
              backgroundColor: Theme.of(context).colorScheme.primary,
              child: Text(
                profile.studentName[0].toUpperCase(),
                style:
                    TextStyle(color: Theme.of(context).colorScheme.onPrimary),
              ),
            ),
            itemBuilder: (context) => <PopupMenuEntry<void>>[
              PopupMenuItem<void>(
                enabled: false,
                child: ListTile(
                  leading: const Icon(Icons.person),
                  title: Text(profile.studentName),
                  subtitle: Text('Grade ${profile.grade.number}'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
              const PopupMenuDivider(),
              PopupMenuItem<void>(
                onTap: () async {
                  await context.read<ProfileProvider>().clearProfile();
                },
                child: const ListTile(
                  leading: Icon(Icons.logout),
                  title: Text('Sign Out'),
                  contentPadding: EdgeInsets.zero,
                ),
              ),
            ],
          ),
        ],
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: views,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.chat_bubble_outline),
            selectedIcon: Icon(Icons.chat_bubble),
            label: 'Tutor',
          ),
          NavigationDestination(
            icon: Icon(Icons.psychology_outlined),
            selectedIcon: Icon(Icons.psychology),
            label: 'Practice',
          ),
          NavigationDestination(
            icon: Icon(Icons.insights_outlined),
            selectedIcon: Icon(Icons.insights),
            label: 'Progress',
          ),
          NavigationDestination(
            icon: Icon(Icons.emoji_events_outlined),
            selectedIcon: Icon(Icons.emoji_events),
            label: 'Badges',
          ),
          NavigationDestination(
            icon: Icon(Icons.calendar_today_outlined),
            selectedIcon: Icon(Icons.calendar_today),
            label: 'Study Plan',
          ),
        ],
      ),
    );
  }

  String _getTitle() {
    switch (_currentIndex) {
      case 0:
        return 'AI Tutor';
      case 1:
        return 'Practice Zone';
      case 2:
        return 'My Progress';
      case 3:
        return 'Badges';
      case 4:
        return 'Study Plan';
      default:
        return 'TutorAnna';
    }
  }

  IconData _getSubjectIcon(Subject subject) {
    switch (subject) {
      case Subject.mathematics:
        return Icons.calculate;
      case Subject.science:
        return Icons.science;
      case Subject.socialScience:
        return Icons.public;
    }
  }
}

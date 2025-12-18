// Onboarding (4 steps)

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/learning_profile.dart';
import '../providers/profile_provider.dart';
import '../widgets/grade_selector.dart';
import '../widgets/language_selector.dart';
import '../widgets/subject_selector.dart';

class OnboardingFlow extends StatefulWidget {
  const OnboardingFlow({super.key});

  @override
  State<OnboardingFlow> createState() => _OnboardingFlowState();
}

class _OnboardingFlowState extends State<OnboardingFlow> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  String _studentName = '';
  Grade? _selectedGrade;
  Language? _selectedLanguage;
  Subject? _selectedSubject;

  final TextEditingController _nameController = TextEditingController();

  @override
  void dispose() {
    _pageController.dispose();
    _nameController.dispose();
    super.dispose();
  }

  void _nextPage() {
    if (_currentPage < 3) {
      _pageController.animateToPage(
        _currentPage + 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  void _previousPage() {
    if (_currentPage > 0) {
      _pageController.animateToPage(
        _currentPage - 1,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  Future<void> _completeOnboarding() async {
    if (_studentName.isNotEmpty &&
        _selectedGrade != null &&
        _selectedLanguage != null &&
        _selectedSubject != null) {
      final profile = LearningProfile(
        studentName: _studentName,
        grade: _selectedGrade!,
        preferredLanguage: _selectedLanguage!,
        preferredSubject: _selectedSubject!,
        lastActive: DateTime.now(),
      );

      await context.read<ProfileProvider>().saveProfile(profile);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Progress indicator
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: List.generate(4, (index) {
                  return Expanded(
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 4),
                      height: 4,
                      decoration: BoxDecoration(
                        color: index <= _currentPage
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context).colorScheme.secondary,
                        borderRadius: BorderRadius.circular(2),
                      ),
                    ),
                  );
                }),
              ),
            ),

            // Page content
            Expanded(
              child: PageView(
                controller: _pageController,
                physics: const NeverScrollableScrollPhysics(),
                onPageChanged: (page) {
                  setState(() {
                    _currentPage = page;
                  });
                },
                children: [
                  _buildNamePage(),
                  _buildGradePage(),
                  _buildLanguagePage(),
                  _buildSubjectPage(),
                ],
              ),
            ),

            // Navigation buttons
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                children: [
                  if (_currentPage > 0)
                    Expanded(
                      child: OutlinedButton(
                        onPressed: _previousPage,
                        child: const Text('Back'),
                      ),
                    ),
                  if (_currentPage > 0) const SizedBox(width: 16),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _canProceed() ? (_currentPage == 3 ? _completeOnboarding : _nextPage) : null,
                      child: Text(_currentPage == 3 ? 'Get Started' : 'Continue'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canProceed() {
    switch (_currentPage) {
      case 0:
        return _studentName.isNotEmpty;
      case 1:
        return _selectedGrade != null;
      case 2:
        return _selectedLanguage != null;
      case 3:
        return _selectedSubject != null;
      default:
        return false;
    }
  }

  Widget _buildNamePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '👋',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Welcome to TutorAnna!',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Your personal AI tutor for grades 6-12',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          TextField(
            controller: _nameController,
            decoration: const InputDecoration(
              labelText: 'What\'s your name?',
              hintText: 'Enter your name',
              prefixIcon: Icon(Icons.person_outline),
            ),
            onChanged: (value) {
              setState(() {
                _studentName = value.trim();
              });
            },
            textCapitalization: TextCapitalization.words,
          ),
        ],
      ),
    );
  }

  Widget _buildGradePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '📚',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Which grade are you in?',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'This helps us personalize your learning',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          GradeSelector(
            selectedGrade: _selectedGrade,
            onGradeSelected: (grade) {
              setState(() {
                _selectedGrade = grade;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildLanguagePage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🌐',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'Choose your language',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'I can help you learn in your preferred language',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          LanguageSelector(
            selectedLanguage: _selectedLanguage,
            onLanguageSelected: (language) {
              setState(() {
                _selectedLanguage = language;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildSubjectPage() {
    return Padding(
      padding: const EdgeInsets.all(24.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            '🎯',
            style: const TextStyle(fontSize: 64),
          ),
          const SizedBox(height: 24),
          Text(
            'What would you like to learn?',
            style: Theme.of(context).textTheme.displayMedium,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 16),
          Text(
            'Choose your preferred subject to start',
            style: Theme.of(context).textTheme.bodyLarge,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 48),
          SubjectSelector(
            selectedSubject: _selectedSubject,
            onSubjectSelected: (subject) {
              setState(() {
                _selectedSubject = subject;
              });
            },
          ),
        ],
      ),
    );
  }
}
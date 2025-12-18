import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/learning_profile.dart';
import '../models/practice_question.dart';
import '../providers/profile_provider.dart';
import '../utils/practice_generator.dart';

class PracticeZone extends StatefulWidget {
  const PracticeZone({super.key});

  @override
  State<PracticeZone> createState() => _PracticeZoneState();
}

class _PracticeZoneState extends State<PracticeZone> {
  Subject? _selectedSubject;
  String _selectedDifficulty = 'Easy';
  List<PracticeQuestion>? _currentQuestions;
  int _currentQuestionIndex = 0;
  Map<int, String> _userAnswers = {};
  bool _showResults = false;

  void _startPractice() {
    if (_selectedSubject == null) return;

    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    final questions = PracticeGenerator.generateQuestions(
      _selectedSubject!,
      profile.grade,
      5,
      difficulty: _selectedDifficulty,
    );

    setState(() {
      _currentQuestions = questions;
      _currentQuestionIndex = 0;
      _userAnswers.clear();
      _showResults = false;
    });
  }

  void _submitAnswer(String answer) {
    setState(() {
      _userAnswers[_currentQuestionIndex] = answer;
    });
  }

  void _nextQuestion() {
    if (_currentQuestionIndex < _currentQuestions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
      });
    } else {
      _finishPractice();
    }
  }

  Future<void> _finishPractice() async {
    await context.read<ProfileProvider>().incrementPracticeCompleted();

    setState(() {
      _showResults = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_currentQuestions == null) {
      return _buildSetupView();
    } else if (_showResults) {
      return _buildResultsView();
    } else {
      return _buildQuestionView();
    }
  }

  Widget _buildSetupView() {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Practice'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Choose subject and difficulty',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
            const SizedBox(height: 32),

            // Subject selection
            Text(
              'Subject',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildSubjectSelector(),

            const SizedBox(height: 32),

            // Difficulty selection
            Text(
              'Difficulty',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 12),
            _buildDifficultySelector(),

            const SizedBox(height: 48),

            // Start button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _selectedSubject != null ? _startPractice : null,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Start Practice'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSubjectSelector() {
    return Column(
      children: Subject.values.map((subject) {
        final isSelected = _selectedSubject == subject;
        IconData icon;

        switch (subject) {
          case Subject.mathematics:
            icon = Icons.calculate;
            break;
          case Subject.science:
            icon = Icons.science;
            break;
          case Subject.socialScience:
            icon = Icons.public;
            break;
        }

        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: Material(
            color: isSelected
                ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                : Theme.of(context).cardColor,
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () {
                setState(() {
                  _selectedSubject = subject;
                });
              },
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: isSelected
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).dividerColor,
                    width: isSelected ? 2 : 1,
                  ),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 48,
                      height: 48,
                      decoration: BoxDecoration(
                        color: isSelected
                            ? Theme.of(context).colorScheme.primary
                            : Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Icon(
                        icon,
                        color: isSelected
                            ? Colors.white
                            : Theme.of(context).colorScheme.primary,
                      ),
                    ),
                    const SizedBox(width: 16),
                    Text(
                      subject.displayName,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.primary
                                : null,
                          ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildDifficultySelector() {
    return Row(
      children: ['Easy', 'Medium', 'Hard'].map((difficulty) {
        final isSelected = _selectedDifficulty == difficulty;
        int dotCount =
            difficulty == 'Easy' ? 1 : (difficulty == 'Medium' ? 2 : 3);

        return Expanded(
          child: Padding(
            padding: const EdgeInsets.only(right: 12),
            child: Material(
              color: isSelected
                  ? Theme.of(context).colorScheme.primary
                  : Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(12),
              child: InkWell(
                onTap: () {
                  setState(() {
                    _selectedDifficulty = difficulty;
                  });
                },
                borderRadius: BorderRadius.circular(12),
                child: Container(
                  padding: const EdgeInsets.symmetric(vertical: 20),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelected
                          ? Theme.of(context).colorScheme.primary
                          : Theme.of(context).dividerColor,
                      width: isSelected ? 0 : 1,
                    ),
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          dotCount,
                          (index) => Container(
                            width: 6,
                            height: 6,
                            margin: const EdgeInsets.symmetric(horizontal: 2),
                            decoration: BoxDecoration(
                              color: isSelected
                                  ? Colors.white
                                  : Theme.of(context).colorScheme.onSurface,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        difficulty,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.w600,
                          color: isSelected
                              ? Colors.white
                              : Theme.of(context).colorScheme.onSurface,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildQuestionView() {
    final question = _currentQuestions![_currentQuestionIndex];
    final hasAnswered = _userAnswers.containsKey(_currentQuestionIndex);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _currentQuestions = null;
            });
          },
        ),
        title: Text(
          'Question ${_currentQuestionIndex + 1}/${_currentQuestions!.length}',
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 16),
            child: Center(
              child: Text(
                _selectedSubject!.displayName,
                style: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          // Progress bar
          LinearProgressIndicator(
            value: (_currentQuestionIndex + 1) / _currentQuestions!.length,
            backgroundColor: Theme.of(context).dividerColor,
            valueColor: AlwaysStoppedAnimation<Color>(
              Theme.of(context).colorScheme.primary,
            ),
          ),

          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(24),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Question
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(
                        color: Theme.of(context).dividerColor,
                      ),
                    ),
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),

                  const SizedBox(height: 24),

                  // Options
                  ...question.options.map((option) {
                    final isSelected =
                        _userAnswers[_currentQuestionIndex] == option;

                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: Material(
                        color: isSelected
                            ? Theme.of(context)
                                .colorScheme
                                .primary
                                .withValues(alpha: 0.1)
                            : Theme.of(context).cardColor,
                        borderRadius: BorderRadius.circular(12),
                        child: InkWell(
                          onTap:
                              hasAnswered ? null : () => _submitAnswer(option),
                          borderRadius: BorderRadius.circular(12),
                          child: Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12),
                              border: Border.all(
                                color: isSelected
                                    ? Theme.of(context).colorScheme.primary
                                    : Theme.of(context).dividerColor,
                                width: isSelected ? 2 : 1,
                              ),
                            ),
                            child: Row(
                              children: [
                                Container(
                                  width: 24,
                                  height: 24,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: isSelected
                                          ? Theme.of(context)
                                              .colorScheme
                                              .primary
                                          : Theme.of(context).dividerColor,
                                      width: 2,
                                    ),
                                    color: isSelected
                                        ? Theme.of(context).colorScheme.primary
                                        : Colors.transparent,
                                  ),
                                  child: isSelected
                                      ? const Icon(
                                          Icons.check,
                                          size: 16,
                                          color: Colors.white,
                                        )
                                      : null,
                                ),
                                const SizedBox(width: 16),
                                Expanded(
                                  child: Text(
                                    option,
                                    style:
                                        Theme.of(context).textTheme.bodyLarge,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    );
                  }),
                ],
              ),
            ),
          ),

          // Next button
          if (hasAnswered)
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withValues(alpha: 0.05),
                    blurRadius: 10,
                    offset: const Offset(0, -2),
                  ),
                ],
              ),
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: _nextQuestion,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(vertical: 18),
                      ),
                      child: Text(
                        _currentQuestionIndex == _currentQuestions!.length - 1
                            ? 'Finish'
                            : 'Next Question',
                      ),
                    ),
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildResultsView() {
    int correct = 0;
    for (int i = 0; i < _currentQuestions!.length; i++) {
      if (_userAnswers[i] == _currentQuestions![i].correctAnswer) {
        correct++;
      }
    }

    final percentage = (correct / _currentQuestions!.length * 100).round();
    final isPassed = percentage >= 60;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.close),
          onPressed: () {
            setState(() {
              _currentQuestions = null;
            });
          },
        ),
        title: const Text('Results'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Result card
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(32),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(24),
              ),
              child: Column(
                children: [
                  Container(
                    width: 120,
                    height: 120,
                    decoration: BoxDecoration(
                      color: (isPassed
                              ? Colors.green
                              : Theme.of(context).colorScheme.error)
                          .withValues(alpha: 0.1),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      isPassed ? Icons.celebration : Icons.refresh,
                      size: 60,
                      color: isPassed
                          ? Colors.green
                          : Theme.of(context).colorScheme.error,
                    ),
                  ),
                  const SizedBox(height: 24),
                  Text(
                    isPassed ? 'Great Job!' : 'Keep Practicing!',
                    style: Theme.of(context).textTheme.displaySmall,
                  ),
                  const SizedBox(height: 12),
                  Text(
                    'You scored',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$percentage%',
                    style: Theme.of(context).textTheme.displayLarge?.copyWith(
                          color: isPassed
                              ? Colors.green
                              : Theme.of(context).colorScheme.error,
                          fontWeight: FontWeight.w800,
                        ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '$correct out of ${_currentQuestions!.length} correct',
                    style: Theme.of(context).textTheme.bodyLarge,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 32),

            // Action buttons
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _startPractice,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Practice Again'),
              ),
            ),
            const SizedBox(height: 12),
            SizedBox(
              width: double.infinity,
              child: OutlinedButton(
                onPressed: () {
                  setState(() {
                    _currentQuestions = null;
                  });
                },
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 18),
                ),
                child: const Text('Choose Different Subject'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

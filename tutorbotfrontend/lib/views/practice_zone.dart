// Practice questions

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../models/learning_profile.dart';
import '../models/practice_question.dart';
import '../providers/profile_provider.dart';
import '../utils/practice_generator.dart';

class PracticeZone extends StatefulWidget {
  final Subject subject;

  const PracticeZone({super.key, required this.subject});

  @override
  State<PracticeZone> createState() => _PracticeZoneState();
}

class _PracticeZoneState extends State<PracticeZone> {
  Difficulty _selectedDifficulty = Difficulty.basic;
  List<PracticeQuestion>? _questions;
  int _currentQuestionIndex = 0;
  String? _selectedAnswer;
  bool _showExplanation = false;
  int _correctAnswers = 0;

  void _startPractice() {
    final profile = context.read<ProfileProvider>().profile;
    if (profile == null) return;

    setState(() {
      _questions = PracticeGenerator.generateQuestions(
        subject: widget.subject,
        grade: profile.grade,
        difficulty: _selectedDifficulty,
        count: 5,
      );
      _currentQuestionIndex = 0;
      _selectedAnswer = null;
      _showExplanation = false;
      _correctAnswers = 0;
    });
  }

  void _submitAnswer() {
    if (_selectedAnswer == null || _questions == null) return;

    final isCorrect = _selectedAnswer == _questions![_currentQuestionIndex].correctAnswer;
    
    if (isCorrect) {
      _correctAnswers++;
    }

    setState(() {
      _showExplanation = true;
    });
  }

  void _nextQuestion() {
    if (_questions == null) return;

    if (_currentQuestionIndex < _questions!.length - 1) {
      setState(() {
        _currentQuestionIndex++;
        _selectedAnswer = null;
        _showExplanation = false;
      });
    } else {
      _showResults();
    }
  }

  void _showResults() {
    final profileProvider = context.read<ProfileProvider>();
    profileProvider.incrementPracticeCompleted();

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        title: const Text('🎉 Practice Complete!'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'You got $_correctAnswers out of ${_questions!.length} correct!',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),
            LinearProgressIndicator(
              value: _correctAnswers / _questions!.length,
              minHeight: 8,
              borderRadius: BorderRadius.circular(4),
            ),
            const SizedBox(height: 8),
            Text(
              '${((_correctAnswers / _questions!.length) * 100).toStringAsFixed(0)}%',
              style: Theme.of(context).textTheme.headlineMedium,
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              setState(() {
                _questions = null;
              });
            },
            child: const Text('Done'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _startPractice();
            },
            child: const Text('Practice Again'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_questions == null) {
      return _buildDifficultySelection();
    }

    return _buildQuestionView();
  }

  Widget _buildDifficultySelection() {
    return Padding(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Text(
            'Choose Difficulty',
            style: Theme.of(context).textTheme.displaySmall,
          ),
          const SizedBox(height: 8),
          Text(
            'Practice ${widget.subject.displayName} questions',
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 32),
          _buildDifficultyCard(
            difficulty: Difficulty.basic,
            icon: Icons.star_outline,
            title: 'Basic',
            description: 'Foundation concepts and simple problems',
          ),
          const SizedBox(height: 16),
          _buildDifficultyCard(
            difficulty: Difficulty.intermediate,
            icon: Icons.star_half,
            title: 'Intermediate',
            description: 'Moderate difficulty with mixed concepts',
          ),
          const SizedBox(height: 16),
          _buildDifficultyCard(
            difficulty: Difficulty.advanced,
            icon: Icons.star,
            title: 'Advanced',
            description: 'Challenging problems requiring deep understanding',
          ),
          const Spacer(),
          ElevatedButton(
            onPressed: _startPractice,
            child: const Text('Start Practice'),
          ),
        ],
      ),
    );
  }

  Widget _buildDifficultyCard({
    required Difficulty difficulty,
    required IconData icon,
    required String title,
    required String description,
  }) {
    final isSelected = _selectedDifficulty == difficulty;

    return Card(
      color: isSelected
          ? Theme.of(context).colorScheme.primary
          : Theme.of(context).cardTheme.color,
      child: InkWell(
        onTap: () {
          setState(() {
            _selectedDifficulty = difficulty;
          });
        },
        borderRadius: BorderRadius.circular(16),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Row(
            children: [
              Icon(
                icon,
                size: 40,
                color: isSelected
                    ? Theme.of(context).colorScheme.onPrimary
                    : Theme.of(context).colorScheme.primary,
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: Theme.of(context).textTheme.titleLarge?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary
                                : null,
                          ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      description,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                            color: isSelected
                                ? Theme.of(context).colorScheme.onPrimary.withValues(alpha: 0.8)
                                : null,
                          ),
                    ),
                  ],
                ),
              ),
              if (isSelected)
                Icon(
                  Icons.check_circle,
                  color: Theme.of(context).colorScheme.onPrimary,
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildQuestionView() {
    final question = _questions![_currentQuestionIndex];
    final isCorrect = _selectedAnswer == question.correctAnswer;

    return Column(
      children: [
        // Progress bar
        LinearProgressIndicator(
          value: (_currentQuestionIndex + 1) / _questions!.length,
          minHeight: 6,
        ),

        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Question number and difficulty
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Question ${_currentQuestionIndex + 1}/${_questions!.length}',
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Chip(
                      label: Text(_selectedDifficulty.displayName),
                      avatar: Icon(
                        _selectedDifficulty == Difficulty.basic
                            ? Icons.star_outline
                            : _selectedDifficulty == Difficulty.intermediate
                                ? Icons.star_half
                                : Icons.star,
                        size: 18,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // Question
                Card(
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Text(
                      question.question,
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                  ),
                ),
                const SizedBox(height: 24),

                // Options
                ...question.options.map((option) {
                  final isSelected = _selectedAnswer == option;
                  final showCorrect = _showExplanation && option == question.correctAnswer;
                  final showWrong = _showExplanation && isSelected && !isCorrect;

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Material(
                      color: showCorrect
                          ? Colors.green.withValues(alpha: 0.1)
                          : showWrong
                              ? Colors.red.withValues(alpha: 0.1)
                              : isSelected
                                  ? Theme.of(context).colorScheme.primary.withValues(alpha: 0.1)
                                  : Theme.of(context).cardColor,
                      borderRadius: BorderRadius.circular(12),
                      child: InkWell(
                        onTap: _showExplanation
                            ? null
                            : () {
                                setState(() {
                                  _selectedAnswer = option;
                                });
                              },
                        borderRadius: BorderRadius.circular(12),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: showCorrect
                                  ? Colors.green
                                  : showWrong
                                      ? Colors.red
                                      : isSelected
                                          ? Theme.of(context).colorScheme.primary
                                          : Theme.of(context).dividerColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  option,
                                  style: Theme.of(context).textTheme.bodyLarge,
                                ),
                              ),
                              if (showCorrect)
                                const Icon(Icons.check_circle, color: Colors.green),
                              if (showWrong)
                                const Icon(Icons.cancel, color: Colors.red),
                            ],
                          ),
                        ),
                      ),
                    ),
                  );
                }),

                // Hint
                if (!_showExplanation && question.hint != null)
                  Card(
                    color: Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Row(
                        children: [
                          Icon(
                            Icons.lightbulb_outline,
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Text(
                              question.hint!,
                              style: Theme.of(context).textTheme.bodyMedium,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                // Explanation
                if (_showExplanation) ...[
                  const SizedBox(height: 16),
                  Card(
                    color: isCorrect
                        ? Colors.green.withValues(alpha: 0.1)
                        : Colors.orange.withValues(alpha: 0.1),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              Icon(
                                isCorrect ? Icons.check_circle : Icons.info_outline,
                                color: isCorrect ? Colors.green : Colors.orange,
                              ),
                              const SizedBox(width: 8),
                              Text(
                                isCorrect ? 'Correct!' : 'Not quite right',
                                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                                      color: isCorrect ? Colors.green : Colors.orange,
                                    ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 12),
                          Text(
                            question.explanation,
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),

        // Action buttons
        Padding(
          padding: const EdgeInsets.all(24),
          child: SafeArea(
            child: Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    onPressed: () {
                      setState(() {
                        _questions = null;
                      });
                    },
                    child: const Text('Exit'),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    onPressed: _selectedAnswer == null
                        ? null
                        : _showExplanation
                            ? _nextQuestion
                            : _submitAnswer,
                    child: Text(_showExplanation ? 'Next Question' : 'Submit Answer'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
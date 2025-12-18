import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import '../models/learning_profile.dart';

class VoiceInterfaceAdvanced extends StatefulWidget {
  final Function(String) onTextReceived;
  final Subject subject;

  const VoiceInterfaceAdvanced({
    super.key,
    required this.onTextReceived,
    required this.subject,
  });

  @override
  State<VoiceInterfaceAdvanced> createState() => _VoiceInterfaceAdvancedState();
}

class _VoiceInterfaceAdvancedState extends State<VoiceInterfaceAdvanced>
    with TickerProviderStateMixin {
  late stt.SpeechToText _speech;
  late AnimationController _pulseController;
  late AnimationController _waveController;
  late Animation<double> _scaleAnimation;
  
  bool _isListening = false;
  bool _isAvailable = false;
  bool _isTutorSpeaking = false;
  String _recognizedText = '';
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
    
    // Pulse animation for mic button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat(reverse: true);

    _scaleAnimation = Tween<double>(begin: 1.0, end: 1.2).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    // Wave animation for sound visualization
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat();
  }

  @override
  void dispose() {
    _speech.stop();
    _pulseController.dispose();
    _waveController.dispose();
    super.dispose();
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      setState(() => _isAvailable = false);
      return;
    }

    try {
      _isAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Voice error: ${error.errorMsg}'),
                backgroundColor: Theme.of(context).colorScheme.error,
              ),
            );
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' && mounted) {
            setState(() => _isListening = false);
            if (_recognizedText.isNotEmpty) {
              widget.onTextReceived(_recognizedText);
              setState(() => _recognizedText = '');
            }
          }
        },
      );

      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      if (mounted) {
        setState(() => _isAvailable = false);
      }
    }
  }

  Future<void> _toggleListening() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input is not supported on web browsers yet'),
            duration: Duration(seconds: 2),
          ),
        );
      }
      return;
    }

    if (!_isListening && _isAvailable) {
      setState(() {
        _isListening = true;
        _recognizedText = '';
      });

      await _speech.listen(
        onResult: (result) {
          setState(() {
            _recognizedText = result.recognizedWords;
            _soundLevel = result.hasConfidenceRating ? result.confidence : 0.5;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        partialResults: true,
        cancelOnError: true,
        listenMode: stt.ListenMode.confirmation,
      );
    } else if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          Expanded(
            child: Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Animated waves when listening
                  if (_isListening) _buildSoundWaves(),
                  
                  // Main mic button
                  _buildMicButton(),
                  
                  const SizedBox(height: 32),
                  
                  // Status text
                  _buildStatusText(),
                  
                  const SizedBox(height: 24),
                  
                  // Recognized text
                  if (_recognizedText.isNotEmpty) _buildRecognizedText(),
                ],
              ),
            ),
          ),
          
          // Hint text at bottom
          Padding(
            padding: const EdgeInsets.all(24),
            child: Text(
              kIsWeb
                  ? 'Voice input not available on web'
                  : _isListening
                      ? 'Listening... Tap to stop'
                      : 'Tap the mic to speak',
              style: Theme.of(context).textTheme.bodyMedium,
              textAlign: TextAlign.center,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundWaves() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 100,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.2;
              final animation = Tween<double>(
                begin: 20,
                end: 60 + (_soundLevel * 40),
              ).animate(
                CurvedAnimation(
                  parent: _waveController,
                  curve: Interval(
                    delay,
                    delay + 0.6,
                    curve: Curves.easeInOut,
                  ),
                ),
              );

              return Container(
                width: 4,
                height: animation.value,
                margin: const EdgeInsets.symmetric(horizontal: 3),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primary,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildMicButton() {
    return GestureDetector(
      onTap: _isAvailable ? _toggleListening : null,
      onLongPress: _isAvailable ? _toggleListening : null,
      child: AnimatedBuilder(
        animation: _isListening ? _scaleAnimation : const AlwaysStoppedAnimation(1.0),
        builder: (context, child) {
          return Transform.scale(
            scale: _isListening ? _scaleAnimation.value : 1.0,
            child: Container(
              width: 120,
              height: 120,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: _isListening
                    ? Theme.of(context).colorScheme.primary
                    : (_isAvailable
                        ? Theme.of(context).colorScheme.primary
                        : Theme.of(context).disabledColor),
                boxShadow: [
                  BoxShadow(
                    color: (_isListening
                            ? Theme.of(context).colorScheme.primary
                            : Colors.black)
                        .withValues(alpha: 0.3),
                    blurRadius: _isListening ? 30 : 20,
                    spreadRadius: _isListening ? 5 : 0,
                  ),
                ],
              ),
              child: Icon(
                _isListening ? Icons.mic : Icons.mic_none,
                size: 50,
                color: Colors.white,
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatusText() {
    String statusText;
    if (!_isAvailable) {
      statusText = 'Voice input unavailable';
    } else if (_isListening) {
      statusText = 'Listening...';
    } else if (_isTutorSpeaking) {
      statusText = 'Tutor is speaking';
    } else {
      statusText = 'Ready to Learn';
    }

    return Text(
      statusText,
      style: Theme.of(context).textTheme.headlineMedium,
      textAlign: TextAlign.center,
    );
  }

  Widget _buildRecognizedText() {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 32),
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: Theme.of(context).dividerColor,
        ),
      ),
      child: Column(
        children: [
          Text(
            'You said:',
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 8),
          Text(
            _recognizedText,
            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                  fontWeight: FontWeight.w500,
                ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
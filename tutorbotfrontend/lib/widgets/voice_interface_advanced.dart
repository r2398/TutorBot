import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';
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
  late AnimationController _waveController;
  late AnimationController _pulseController;

  bool _isListening = false;
  bool _isAvailable = false;
  bool _permissionGranted = false;
  bool _isPaused = false;
  String _recognizedText = '';
  String _interimText = '';
  double _soundLevel = 0.0;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();

    // Wave animation for sound bars
    _waveController = AnimationController(
      duration: const Duration(milliseconds: 1500),
      vsync: this,
    )..repeat();

    // Pulse animation for mic button
    _pulseController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    )..repeat(reverse: true);

    _checkPermissionsAndInit();
  }

  @override
  void dispose() {
    _waveController.dispose();
    _pulseController.dispose();
    _speech.stop();
    super.dispose();
  }

  Future<void> _checkPermissionsAndInit() async {
    if (kIsWeb) {
      setState(() => _isAvailable = false);
      return;
    }

    final status = await Permission.microphone.status;

    if (status.isGranted) {
      setState(() => _permissionGranted = true);
      await _initSpeech();
    } else if (status.isDenied) {
      final result = await Permission.microphone.request();
      if (result.isGranted) {
        setState(() => _permissionGranted = true);
        await _initSpeech();
      }
    } else if (status.isPermanentlyDenied) {
      _showSettingsDialog();
    }
  }

  void _showSettingsDialog() {
    if (!mounted) return;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Permission Required'),
        content: const Text(
          'Microphone permission is required. Please enable it in settings.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              openAppSettings();
              Navigator.pop(context);
            },
            child: const Text('Open Settings'),
          ),
        ],
      ),
    );
  }

  Future<void> _initSpeech() async {
    if (kIsWeb || !_permissionGranted) return;

    try {
      _isAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: ${error.errorMsg}');
          if (mounted) {
            setState(() {
              _isListening = false;
              _isPaused = false;
            });
          }
        },
        onStatus: (status) {
          debugPrint('Speech status: $status');
          if (status == 'done' || status == 'notListening') {
            if (mounted && _isListening && !_isPaused) {
              // Auto-restart if not paused
              _startListening();
            }
          }
        },
      );

      if (mounted) setState(() {});
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      if (mounted) setState(() => _isAvailable = false);
    }
  }

  Future<void> _startListening() async {
    if (kIsWeb) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Voice input is not supported on web'),
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }

    if (!_permissionGranted || !_isAvailable) {
      await _checkPermissionsAndInit();
      if (!_isAvailable) return;
    }

    setState(() {
      _isListening = true;
      _isPaused = false;
      _recognizedText = '';
      _interimText = '';
      _soundLevel = 0.0;
    });

    try {
      await _speech.listen(
        onResult: (result) {
          if (mounted) {
            setState(() {
              if (result.finalResult) {
                _recognizedText += '${result.recognizedWords} ';
                _interimText = '';
              } else {
                _interimText = result.recognizedWords;
              }
              _soundLevel =
                  result.hasConfidenceRating ? result.confidence : 0.5;
            });
          }
        },
        listenFor: const Duration(seconds: 60),
        pauseFor: const Duration(seconds: 10),
        onSoundLevelChange: (level) {
          if (mounted && !_isPaused) {
            setState(() {
              _soundLevel = level.clamp(0.0, 1.0);
            });
          }
        },
      );
    } catch (e) {
      debugPrint('Listen error: $e');
      if (mounted) {
        setState(() {
          _isListening = false;
          _isPaused = false;
        });
      }
    }
  }

  void _pauseListening() {
    if (_speech.isListening && !_isPaused) {
      _speech.stop();
      setState(() {
        _isPaused = true;
        _soundLevel = 0.0;
      });
    }
  }

  void _resumeListening() {
    if (_isPaused) {
      setState(() => _isPaused = false);
      _startListening();
    }
  }

  void _stopListening() {
    _speech.stop();
    setState(() {
      _isListening = false;
      _isPaused = false;
      _recognizedText = '';
      _interimText = '';
      _soundLevel = 0.0;
    });
  }

  void _sendMessage(String text) {
    if (text.trim().isEmpty) return;
    widget.onTextReceived(text.trim());
    setState(() {
      _recognizedText = '';
      _interimText = '';
    });
    _stopListening();
  }

  @override
  Widget build(BuildContext context) {
    final displayText = _recognizedText + _interimText;

    return Container(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Column(
        children: [
          // Transcript display (at top when listening)
          if (_isListening || displayText.isNotEmpty)
            Container(
              margin: const EdgeInsets.fromLTRB(24, 16, 24, 12),
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(
                  color: Theme.of(context).dividerColor,
                ),
              ),
              child: displayText.isEmpty
                  ? Text(
                      'Listening...',
                      style: TextStyle(
                        fontSize: 14,
                        color: Theme.of(context)
                            .textTheme
                            .bodySmall
                            ?.color
                            ?.withValues(alpha: 0.6),
                        fontStyle: FontStyle.italic,
                      ),
                    )
                  : Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          displayText,
                          style: Theme.of(context).textTheme.bodyLarge,
                        ),
                        if (_interimText.isNotEmpty)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            width: 2,
                            height: 16,
                            decoration: BoxDecoration(
                              color: Theme.of(context).colorScheme.primary,
                              borderRadius: BorderRadius.circular(1),
                            ),
                          ),
                      ],
                    ),
            ),

          const Spacer(),

          // Sound bars (centered when listening)
          if (_isListening && !_isPaused) _buildSoundBars(),

          const Spacer(),

          // Voice controls at bottom
          Padding(
            padding: const EdgeInsets.only(bottom: 24),
            child:
                _isListening ? _buildListeningControls() : _buildStartButton(),
          ),
        ],
      ),
    );
  }

  Widget _buildSoundBars() {
    return AnimatedBuilder(
      animation: _waveController,
      builder: (context, child) {
        return SizedBox(
          height: 120,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: List.generate(5, (index) {
              final delay = index * 0.15;
              final animValue = ((_waveController.value + delay) % 1.0);

              final baseHeight = 20.0;
              final maxHeight = 100.0;
              final soundFactor = 0.3 + (_soundLevel * 0.7);
              final animFactor = 0.5 + 0.5 * (1 - (animValue - 0.5).abs() * 2);
              final height = baseHeight +
                  (maxHeight - baseHeight) * animFactor * soundFactor;

              return Container(
                width: 4,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 4),
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

  Widget _buildListeningControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        // Pause/Resume button
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [
                Theme.of(context).colorScheme.primary,
                Theme.of(context).colorScheme.secondary,
              ],
            ),
            shape: BoxShape.circle,
            boxShadow: [
              BoxShadow(
                color: Theme.of(context)
                    .colorScheme
                    .primary
                    .withValues(alpha: 0.3),
                blurRadius: 12,
                offset: const Offset(0, 4),
              ),
            ],
          ),
          child: IconButton(
            onPressed: _isPaused ? _resumeListening : _pauseListening,
            icon: Icon(
              _isPaused ? Icons.play_arrow : Icons.pause,
              color: Colors.white,
              size: 32,
            ),
          ),
        ),

        const SizedBox(width: 24),

        // Stop button
        Container(
          width: 64,
          height: 64,
          decoration: BoxDecoration(
            color: Colors.red.shade50,
            shape: BoxShape.circle,
            border: Border.all(
              color: Colors.red.shade200,
              width: 2,
            ),
          ),
          child: IconButton(
            onPressed: _stopListening,
            icon: Icon(
              Icons.close,
              color: Colors.red.shade700,
              size: 32,
            ),
          ),
        ),

        // Send button (if text recognized)
        if ((_recognizedText + _interimText).trim().isNotEmpty) ...[
          const SizedBox(width: 24),
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: Colors.green.shade600,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withValues(alpha: 0.3),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              onPressed: () => _sendMessage(_recognizedText),
              icon: const Icon(
                Icons.send,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ],
    );
  }

  Widget _buildStartButton() {
    final canStart = _permissionGranted && _isAvailable && !kIsWeb;

    return Column(
      children: [
        GestureDetector(
          onTap: canStart ? _startListening : _checkPermissionsAndInit,
          child: AnimatedBuilder(
            animation: _pulseController,
            builder: (context, child) {
              final scale = 1.0 + (_pulseController.value * 0.05);
              return Transform.scale(
                scale: scale,
                child: Container(
                  width: 80,
                  height: 80,
                  decoration: BoxDecoration(
                    gradient: canStart
                        ? LinearGradient(
                            colors: [
                              Theme.of(context).colorScheme.primary,
                              Theme.of(context).colorScheme.secondary,
                            ],
                          )
                        : null,
                    color: canStart ? null : Theme.of(context).disabledColor,
                    shape: BoxShape.circle,
                    boxShadow: [
                      BoxShadow(
                        color: (canStart
                                ? Theme.of(context).colorScheme.primary
                                : Colors.black)
                            .withValues(alpha: 0.3),
                        blurRadius: 20,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: Colors.white,
                    size: 40,
                  ),
                ),
              );
            },
          ),
        ),
        const SizedBox(height: 16),
        Text(
          kIsWeb
              ? 'Voice not available on web'
              : !_permissionGranted
                  ? 'Microphone permission required'
                  : 'Tap to speak',
          style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                color: Theme.of(context)
                    .textTheme
                    .bodySmall
                    ?.color
                    ?.withValues(alpha: 0.7),
              ),
          textAlign: TextAlign.center,
        ),
      ],
    );
  }
}

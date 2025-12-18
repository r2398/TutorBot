// Voice input widget

import 'package:flutter/foundation.dart' show kIsWeb, debugPrint;
import 'package:flutter/material.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class VoiceInterface extends StatefulWidget {
  final Function(String) onTextReceived;

  const VoiceInterface({
    super.key,
    required this.onTextReceived,
  });

  @override
  State<VoiceInterface> createState() => _VoiceInterfaceState();
}

class _VoiceInterfaceState extends State<VoiceInterface> {
  late stt.SpeechToText _speech;
  bool _isListening = false;
  bool _isAvailable = false;
  String _text = '';

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _initSpeech();
  }

  Future<void> _initSpeech() async {
    if (kIsWeb) {
      // Speech recognition has limited support on web
      setState(() => _isAvailable = false);
      return;
    }
    
    try {
      _isAvailable = await _speech.initialize(
        onError: (error) {
          debugPrint('Speech error: $error');
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('Speech error: $error')),
            );
          }
        },
        onStatus: (status) => debugPrint('Speech status: $status'),
      );
      if (mounted) {
        setState(() {});
      }
    } catch (e) {
      debugPrint('Speech initialization error: $e');
      if (mounted) {
        setState(() {
          _isAvailable = false;
        });
      }
    }
  }

  Future<void> _listen() async {
    if (kIsWeb) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Voice input is not supported on web browsers yet'),
          ),
        );
      }
      return;
    }

    if (!_isListening && _isAvailable) {
      setState(() => _isListening = true);
      await _speech.listen(
        onResult: (result) {
          setState(() {
            _text = result.recognizedWords;
          });
        },
        listenFor: const Duration(seconds: 30),
        pauseFor: const Duration(seconds: 3),
        listenOptions: stt.SpeechListenOptions(
          partialResults: true,
          cancelOnError: true,
        ),
      );
    } else if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      if (_text.isNotEmpty) {
        widget.onTextReceived(_text);
        setState(() => _text = '');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: kIsWeb ? 'Voice input not available on web' : 'Tap to speak',
      child: GestureDetector(
        onTap: _isAvailable ? _listen : null,
        onLongPress: _isAvailable ? _listen : null,
        child: CircleAvatar(
          backgroundColor: _isListening
              ? Theme.of(context).colorScheme.error
              : (_isAvailable 
                  ? Theme.of(context).colorScheme.secondary
                  : Colors.grey),
          child: Icon(
            _isListening ? Icons.mic : Icons.mic_none,
            color: _isListening
                ? Colors.white
                : (_isAvailable 
                    ? Theme.of(context).colorScheme.onSecondary
                    : Colors.white),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _speech.stop();
    super.dispose();
  }
}
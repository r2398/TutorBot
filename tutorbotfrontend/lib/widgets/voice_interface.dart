// Voice input button

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
    _isAvailable = await _speech.initialize(
      onError: (error) => print('Speech error: $error'),
      onStatus: (status) => print('Speech status: $status'),
    );
    setState(() {});
  }

  Future<void> _listen() async {
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
    return GestureDetector(
      onTap: _isAvailable ? _listen : null,
      onLongPress: _isAvailable ? _listen : null,
      child: CircleAvatar(
        backgroundColor: _isListening
            ? Theme.of(context).colorScheme.error
            : Theme.of(context).colorScheme.secondary,
        child: Icon(
          _isListening ? Icons.mic : Icons.mic_none,
          color: _isListening
              ? Colors.white
              : Theme.of(context).colorScheme.onSecondary,
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

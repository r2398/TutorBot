import 'package:flutter/material.dart';
import '../models/learning_profile.dart';

class LanguageSelector extends StatelessWidget {
  final Language? selectedLanguage;
  final Function(Language) onLanguageSelected;

  const LanguageSelector({
    super.key,
    required this.selectedLanguage,
    required this.onLanguageSelected,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: Theme.of(context).dividerColor,
          width: 1.5,
        ),
      ),
      child: DropdownButton<Language>(
        value: selectedLanguage,
        isExpanded: true,
        underline: const SizedBox(),
        icon: const Icon(Icons.keyboard_arrow_down),
        hint: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 12),
          child: Text('Select language'),
        ),
        style: Theme.of(context).textTheme.titleMedium,
        borderRadius: BorderRadius.circular(12),
        items: Language.values.map((language) {
          return DropdownMenuItem<Language>(
            value: language,
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Text(language.displayName),
            ),
          );
        }).toList(),
        onChanged: (language) {
          if (language != null) {
            onLanguageSelected(language);
          }
        },
      ),
    );
  }
}
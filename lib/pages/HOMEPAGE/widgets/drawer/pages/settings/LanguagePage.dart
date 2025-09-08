import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:resturantapp/LocaleProvider.dart';
import 'package:resturantapp/generated/l10n.dart';

class LanguagePage extends StatelessWidget {
  const LanguagePage({super.key});

  @override
  Widget build(BuildContext context) {
    final localeProvider = Provider.of<LocaleProvider>(context);
    final currentLocale = localeProvider.locale.languageCode;

    final languages = [
      {'code': 'ar', 'label': 'العربية'},
      {'code': 'en', 'label': 'English'},
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(S.of(context).change_language),
        centerTitle: true,
        elevation: 0,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(20),
        itemCount: languages.length,
        itemBuilder: (context, index) {
          final lang = languages[index];
          final isSelected = currentLocale == lang['code'];

          return AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.symmetric(vertical: 10),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blue.withOpacity(0.1) : Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(
                color: isSelected ? Colors.blue : Colors.grey.shade300,
                width: 2,
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.05),
                  blurRadius: 5,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: InkWell(
              borderRadius: BorderRadius.circular(16),
              onTap: () => localeProvider.setLocale(Locale(lang['code']!)),
              child: ListTile(
                leading: Icon(
                  Icons.language,
                  color: isSelected ? Colors.blue : Colors.grey,
                ),
                title: Text(
                  lang['label']!,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: isSelected
                        ? FontWeight.bold
                        : FontWeight.normal,
                    color: isSelected ? Colors.blue : Colors.black87,
                  ),
                ),
                trailing: isSelected
                    ? const Icon(Icons.check_circle, color: Colors.blue)
                    : null,
              ),
            ),
          );
        },
      ),
    );
  }
}

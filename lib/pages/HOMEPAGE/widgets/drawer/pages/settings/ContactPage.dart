import 'package:flutter/material.dart';
import 'package:resturantapp/generated/l10n.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactPage extends StatelessWidget {
  const ContactPage({super.key});

  Future<void> _launchUrl(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      debugPrint("لا يمكن فتح الرابط: $url");
    }
  }

  @override
  Widget build(BuildContext context) {
    final contacts = [
      {
        'icon': Icons.phone,
        'title': S.of(context).contactUs,
        'subtitle': '+966123456789',
        'url': 'tel:+966123456789',
      },
      {
        'icon': Icons.email,
        'title': S.of(context).Email,
        'subtitle': 'info@example.com',
        'url': 'mailto:info@example.com',
      },
      {
        'icon': Icons.web,
        'title': S.of(context).Web,
        'subtitle': 'flutter.dev',
        'url': 'https://flutter.dev',
      },
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(S.of(context).contactUs),
        backgroundColor: Colors.white,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: contacts.length,
        itemBuilder: (context, index) {
          final contact = contacts[index];
          return Card(
            color: Colors.white,
            margin: const EdgeInsets.symmetric(vertical: 10),
            child: ListTile(
              leading: Icon(contact['icon'] as IconData, color: Colors.blue),
              title: Text(contact['title'] as String),
              subtitle: Text(contact['subtitle'] as String),
              trailing: const Icon(Icons.arrow_forward_ios, size: 18),
              onTap: () => _launchUrl(contact['url'] as String),
            ),
          );
        },
      ),
    );
  }
}

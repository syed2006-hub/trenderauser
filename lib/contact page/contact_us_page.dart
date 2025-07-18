import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:url_launcher/url_launcher.dart';

class ContactUsPage extends StatelessWidget {
  const ContactUsPage({super.key});

  final String phone = '+91 9342561101'; // No spaces for tel:
  final String adminEmail = 'syedrizwan00211@gmail.com';

  Future<void> _launchUrl(String url) async {
    if (!await launchUrl(Uri.parse(url))) {
      throw Exception('Could not launch $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: theme.colorScheme.secondary,
      body: Column(
        children: [
          // 🔺 Header with back arrow
          SafeArea(
            child: Container(
              width: double.infinity,
              height: 70.w,
              color: Theme.of(context).colorScheme.secondary,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Positioned(
                    left: 8,
                    child: IconButton(
                      onPressed: () => Navigator.of(context).pop(),
                      icon: const Icon(Icons.arrow_back_ios_new),
                    ),
                  ),
                  Center(
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          "Contact Us",
                          style: Theme.of(
                            context,
                          ).textTheme.titleLarge?.copyWith(color: Colors.white),
                        ),
                        const SizedBox(width: 10),
                        const Icon(Icons.headset_mic),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),

          // 🔺 Body
          Expanded(
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(24),
              decoration: const BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.vertical(top: Radius.circular(25)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  Text(
                    'Need Help?',
                    style: theme.textTheme.headlineSmall?.copyWith(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'We’re here to assist you. Reach out via email or phone and our team will respond promptly.',
                  ),
                  const SizedBox(height: 30),

                  // Email Section
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.email_outlined),
                    title: Text(adminEmail),
                    trailing: IconButton(
                      icon: const Icon(Icons.send),
                      onPressed:
                          () => _launchUrl("mailto:syedrizwan00211@gmail.com"),
                    ),
                    onTap: () => _launchUrl("mailto:syedrizwan00211@gmail.com"),
                  ),
                  const Divider(),

                  // Phone Section
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.phone),
                    title: Text(phone),
                    trailing: IconButton(
                      icon: const Icon(Icons.add_ic_call),
                      onPressed: () => _launchUrl("tel:+919342561101"),
                    ),
                    onTap: () => _launchUrl("tel:+919342561101"),
                  ),
                  Spacer(),
                  SizedBox(
                    width: double.infinity,
                    child: Center(
                      child: Image.asset(
                        "assets/images/logo_wo_bg.png",
                        width: 150,
                        opacity:  AlwaysStoppedAnimation(0.5),
                      ),
                    ),
                  ),
                  Spacer(),

                  Center(
                    child: Text(
                      '© 2025 Trendera. All rights reserved.',
                      style: theme.textTheme.bodySmall,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

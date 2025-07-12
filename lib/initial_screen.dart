import 'dart:ui';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shimmer/shimmer.dart';
import 'package:trendera/front_page/login%20signup%20page/signin_page.dart';
import 'package:url_launcher/url_launcher.dart';

class CustomIntroScreen extends StatefulWidget {
  const CustomIntroScreen({super.key});

  @override
  State<CustomIntroScreen> createState() => _CustomIntroScreenState();
}

class _CustomIntroScreenState extends State<CustomIntroScreen> {
  final PageController _controller = PageController();
  int currentIndex = 0;

  final List<Map<String, String>> pages = [
    {
      'image': 'assets/images/onboard1.png',
      'title': 'Trendera\nWelcomes You...',
      'subtitle': 'Find the perfect look for any occasion.',
    },
    {
      'image': 'assets/images/onboard2.png',
      'title': 'Search the Trends....',
      'subtitle': 'Find what’s trending.',
    },
    {'image': 'assets/images/onboard3.png', 'title': 'Want to login as admin'},
  ];

  void nextPage() {
    if (currentIndex < pages.length - 1) {
      _controller.nextPage(
        duration: Duration(milliseconds: 300),
        curve: Curves.easeIn,
      );
    } else {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (context) => LoginPage(isShop: false)),
      );
    }
  }

  void skip() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => LoginPage(isShop: false)),
    );
  }

  void showLinkDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) {
        return BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 6, sigmaY: 6),
          child: Center(
            child: Stack(
              children: [
                // 🟢 Dialog content
                AlertDialog(
                  backgroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  contentPadding: EdgeInsets.all(16),
                  content: SizedBox(
                    height: 200,
                    width: 300,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Copy (Or) Open the link"),
                        Text(
                          "https://syed2006-hub.github.io/trendera/",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () {
                                Clipboard.setData(
                                  ClipboardData(
                                    text:
                                        'https://syed2006-hub.github.io/trendera/',
                                  ),
                                );
                                Navigator.of(context).pop();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  SnackBar(
                                    content: Text("Copied to clipboard"),
                                  ),
                                );
                              },
                              icon: Icon(Icons.copy, color: Colors.white),
                              label: Text(
                                "Copy",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                            SizedBox(width: 10),
                            TextButton.icon(
                              style: TextButton.styleFrom(
                                backgroundColor: Colors.black,
                              ),
                              onPressed: () async {
                                final Uri url = Uri.parse(
                                  'https://syed2006-hub.github.io/trendera/',
                                );
                                if (await canLaunchUrl(url)) {
                                  final launched = await launchUrl(
                                    url,
                                    mode: LaunchMode.externalApplication,
                                  );
                                  if (!launched) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Failed to launch externally. Trying fallback...',
                                        ),
                                      ),
                                    );
                                    await launchUrl(url);
                                  }
                                } else {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        "Can't Open URL",
                                        style: TextStyle(color: Colors.white),
                                      ),
                                    ),
                                  );
                                }
                              },
                              icon: Icon(
                                Icons.arrow_outward_rounded,
                                color: Colors.white,
                              ),
                              label: Text(
                                "Open",
                                style: TextStyle(color: Colors.white),
                              ),
                              iconAlignment: IconAlignment.end,
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),

                // ✨ Shimmer overlay clipped to dialog box only
                Positioned.fill(
                  child: Center(
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: SizedBox(
                        height: 200,
                        width: 300,
                        child: IgnorePointer(
                          child: Shimmer.fromColors(
                            baseColor: Colors.white24,
                            highlightColor: Colors.white60,
                            child: Container(
                              color:
                                  Colors
                                      .white, // important for shimmer visibility
                            ),
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 61, 61, 61),
      body: Stack(
        children: [
          PageView.builder(
            controller: _controller,
            itemCount: pages.length,
            onPageChanged: (index) {
              setState(() => currentIndex = index);
            },
            itemBuilder: (context, index) {
              final page = pages[index];
              return Stack(
                fit: StackFit.expand,
                children: [
                  Image.asset(page['image']!, fit: BoxFit.cover),
                  Positioned(
                    top: index == 1 ? 30 : null,
                    bottom: 180,
                    left: 20,
                    right: 20,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.only(left: (index == 1 ? 20 : 0)),
                          child: Text(
                            page['title']!,
                            style:
                                index == 0
                                    ? TextStyle(
                                      color: Colors.white,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    )
                                    : TextStyle(
                                      color: Colors.black,
                                      fontSize: 28,
                                      fontWeight: FontWeight.bold,
                                    ),
                          ),
                        ),
                        SizedBox(height: 10),
                        index == 2
                            ? RichText(
                              text: TextSpan(
                                text: 'To avail admin side. ',
                                style: TextStyle(color: Colors.black),
                                children: [
                                  TextSpan(
                                    text: 'Click here',
                                    style: TextStyle(
                                      color: Colors.blueAccent,
                                      decoration: TextDecoration.underline,
                                    ),
                                    recognizer:
                                        TapGestureRecognizer()
                                          ..onTap = () {
                                            showLinkDialog(context);
                                          },
                                  ),
                                ],
                              ),
                            )
                            : Text(
                              index == 1 ? '' : page['subtitle']!,
                              style: TextStyle(
                                color: Colors.white70,
                                fontSize: 16,
                              ),
                            ),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),

          // Fixed bottom navigation
          Align(
            alignment: Alignment.bottomCenter,
            child: Container(
              color: Colors.transparent,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 40),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  GestureDetector(
                    onTap: skip,
                    child: Text(
                      'Skip',
                      style: TextStyle(
                        color:
                            currentIndex == pages.length - 1
                                ? Colors.black
                                : Colors.white,
                        fontSize: 16,
                      ),
                    ),
                  ),
                  Row(
                    children: List.generate(pages.length, (index) {
                      return Container(
                        margin: const EdgeInsets.symmetric(horizontal: 4),
                        width: currentIndex == index ? 15 : 8,
                        height: 8,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(30),
                          color:
                              currentIndex == index
                                  ? (currentIndex == pages.length - 1
                                      ? Colors.black
                                      : Colors.white)
                                  : (currentIndex == pages.length - 1
                                      ? Colors.black54
                                      : Colors.white54),
                        ),
                      );
                    }),
                  ),
                  GestureDetector(
                    onTap: nextPage,
                    child:
                        currentIndex == pages.length - 1
                            ? Text(
                              'Next',
                              style: TextStyle(
                                color: Colors.black,
                                fontSize: 16,
                              ),
                            )
                            : Icon(
                              Icons.arrow_forward,
                              color:
                                  currentIndex == pages.length - 1
                                      ? Colors.black
                                      : Colors.white,
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

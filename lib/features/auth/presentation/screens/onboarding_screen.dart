import 'package:flutter/material.dart';
import 'package:tifli/core/constants/app_colors.dart';
import 'package:tifli/core/constants/app_fonts.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _controller = PageController();
  int _index = 0;

  final List<_OnboardPageData> pages = [
    _OnboardPageData(
      image: "assets/images/onboard1.png",
      title: "Track Every Moment",
      subtitle: "Feeding, sleep, growth & milestones in one place.",
    ),
    _OnboardPageData(
      image: "assets/images/onboard2.jpg",
      title: "Understand Your Baby",
      subtitle: "Smart insights that help you care with confidence.",
    ),
    _OnboardPageData(
      image: "assets/images/onboard3.jpg",
      title: "Grow Together",
      subtitle: "Capture memories and watch progress over time.",
    ),
  ];

  void next() {
    if (_index == pages.length - 1) {
      Navigator.pushReplacementNamed(context, '/auth');
    } else {
      _controller.nextPage(
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFFFF6F8),
      body: SafeArea(
        child: Column(
          children: [
            // Skip button
            Align(
              alignment: Alignment.topRight,
              child: TextButton(
                onPressed: () =>
                    Navigator.pushReplacementNamed(context, "/auth"),
                child: const Text(
                  "Skip",
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                onPageChanged: (i) => setState(() => _index = i),
                itemCount: pages.length,
                itemBuilder: (context, i) {
                  return _OnboardPage(
                    image: pages[i].image,
                    title: pages[i].title,
                    subtitle: pages[i].subtitle,
                  );
                },
              ),
            ),

            // Page indicators
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                pages.length,
                (i) => AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: _index == i ? 22 : 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: _index == i
                        ? AppColors.primary
                        : Colors.grey.shade300,
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            // Next / Get Started button
            Padding(
              padding: const EdgeInsets.all(20),
              child: SizedBox(
                width: double.infinity,
                height: 55,
                child: ElevatedButton(
                  onPressed: next,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  child: Text(
                    _index == pages.length - 1 ? "Get Started" : "Next",
                    style: const TextStyle(
                      fontSize: 18,
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }
}

class _OnboardPageData {
  final String image;
  final String title;
  final String subtitle;

  _OnboardPageData({
    required this.image,
    required this.title,
    required this.subtitle,
  });
}

class _OnboardPage extends StatelessWidget {
  final String image;
  final String title;
  final String subtitle;

  const _OnboardPage({
    required this.image,
    required this.title,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(image, width: 260),
          const SizedBox(height: 40),
          Text(
            title,
            textAlign: TextAlign.center,
            style: AppFonts.heading1.copyWith(
              fontSize: 26,
              fontWeight: FontWeight.w700,
              color: AppColors.primary,
            ),
          ),
          const SizedBox(height: 12),
          Text(
            subtitle,
            textAlign: TextAlign.center,
            style: AppFonts.body.copyWith(
              fontSize: 16,
              height: 1.4,
              color: Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

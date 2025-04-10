import 'package:gap/gap.dart';
import 'package:zest/app/data/db.dart';
import 'package:zest/app/ui/home.dart';
import 'package:zest/app/ui/widgets/button.dart';
import 'package:zest/main.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnBording extends StatefulWidget {
  const OnBording({super.key});

  @override
  State<OnBording> createState() => _OnBordingState();
}

class _OnBordingState extends State<OnBording> {
  late PageController pageController;
  int pageIndex = 0;

  @override
  void initState() {
    pageController = PageController(initialPage: 0);
    super.initState();
  }

  @override
  void dispose() {
    pageController.dispose();
    super.dispose();
  }

  void onBoardHome() {
    settings.onboard = true;
    isar.writeTxnSync(() => isar.settings.putSync(settings));
    Get.off(() => const HomePage(), transition: Transition.downToUp);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: PageView.builder(
                controller: pageController,
                itemCount: data.length,
                onPageChanged: (index) {
                  setState(() {
                    pageIndex = index;
                  });
                },
                itemBuilder:
                    (context, index) => OnboardContent(
                      image: data[index].image,
                      title: data[index].title,
                      description: data[index].description,
                    ),
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                ...List.generate(
                  data.length,
                  (index) => Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 5),
                    child: DotIndicator(isActive: index == pageIndex),
                  ),
                ),
              ],
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
              child: MyTextButton(
                text: pageIndex == data.length - 1 ? 'getStart'.tr : 'next'.tr,
                onPressed: () {
                  pageIndex == data.length - 1
                      ? onBoardHome()
                      : pageController.nextPage(
                        duration: const Duration(milliseconds: 300),
                        curve: Curves.ease,
                      );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class DotIndicator extends StatelessWidget {
  const DotIndicator({super.key, this.isActive = false});

  final bool isActive;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 300),
      height: 8,
      width: 8,
      decoration: BoxDecoration(
        color:
            isActive
                ? context.theme.colorScheme.secondary
                : context.theme.colorScheme.secondaryContainer,
        shape: BoxShape.circle,
      ),
    );
  }
}

class Onboard {
  final String image, title, description;

  Onboard({
    required this.image,
    required this.title,
    required this.description,
  });
}
final List<Onboard> data = [
  Onboard(
    image: 'assets/images/Task.png',
    title: 'Stay Organized'.tr,
    description: 'Easily categorize and complete your tasks step by step.'.tr,
  ),
  Onboard(
    image: 'assets/images/Design.png',
    title: 'Boost Productivity'.tr,
    description: 'Plan, track, and optimize your work effortlessly.'.tr,
  ),
  Onboard(
    image: 'assets/images/Feedback.png',
    title: 'Achieve More'.tr,
    description: 'Stay motivated and accomplish your goals faster.'.tr,
  ),
];

class OnboardContent extends StatelessWidget {
  const OnboardContent({
    super.key,
    required this.image,
    required this.title,
    required this.description,
  });
  final String image, title, description;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Flexible(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(image, scale: 5),
              Text(
                title,
                style: context.textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w600,
                ),
              ),
              const Gap(10),
              SizedBox(
                width: 300,
                child: Text(
                  description,
                  style: context.textTheme.labelLarge?.copyWith(fontSize: 14),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}

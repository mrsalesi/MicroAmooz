import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page07.dart';

class Page06 extends StatefulWidget {
  const Page06({Key? key}) : super(key: key);

  @override
  State<Page06> createState() => _Page06State();
}

class _Page06State extends State<Page06> {
  late SwiperController _swiperController;
  int _currentSlide = 0;
  int _currentNavIndex = 2;

  final List<String> _images = [
    "images/pic08.png",
    "images/pic09.png",
    "images/pic10.png",
    "images/pic11.png",
    "images/pic12.png",
  ];

  final List<String> _titles = [
    "مدیریت بازاریابی و فروش",
    "توسعه شایستگی های فردی",
    "مدیریت تولید و بهره برداری",
    "مدیریت مالی و اقتصادی",
    "مدیریت منابع انسانی",
  ];

  @override
  void initState() {
    super.initState();
    _swiperController = SwiperController();
  }

  @override
  void dispose() {
    _swiperController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    if (!mounted) return;
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _onSlideTapped(String imagePath, String title) {
    Tooltip.dismissAllToolTips();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Page07(imagePath: imagePath, title: title),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  Swiper(
                    controller: _swiperController,
                    itemCount: _images.length,
                    autoplay: false,
                    viewportFraction: 0.85,
                    scale: 0.9,
                    onIndexChanged: (index) {
                      if (mounted) {
                        setState(() {
                          _currentSlide = index;
                        });
                      }
                    },
                    itemBuilder: (context, index) {
                      final imagePath = _images[index];
                      final title = _titles[index];
                      return GestureDetector(
                        onTap: () => _onSlideTapped(
                            imagePath, title), // اینجا title هم پاس داده می‌شه
                        child: Column(
                          children: [
                            Expanded(
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(16),
                                child: Image.asset(
                                  imagePath,
                                  fit: BoxFit.cover,
                                  width: double.infinity,
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            Text(
                              title,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                            const SizedBox(height: 30),
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    bottom: 16,
                    left: 0,
                    right: 0,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(_images.length, (index) {
                        final isActive = index == _currentSlide;
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 250),
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: isActive ? 20 : 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: isActive
                                ? const Color(0xff1291a7)
                                : Colors.grey.shade300,
                            borderRadius: BorderRadius.circular(10),
                          ),
                        );
                      }),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

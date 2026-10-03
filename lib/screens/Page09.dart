import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page10.dart';

class Page09 extends StatefulWidget {
  const Page09({Key? key}) : super(key: key);

  @override
  State<Page09> createState() => _Page09State();
}

class _Page09State extends State<Page09> {
  late SwiperController _swiperController;
  int _currentNavIndex = 2;

  // ایندکس آخرین آیتمی که کلیک شده — همون "دیفالت"
  int _selectedIndex = 0;

  final List<String> _images = [
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/lesson.png",
    "images/gem.png",
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

  void _onItemTapped(int index, String imagePath, String title) {
    setState(() {
      _selectedIndex = index;
    });

    Tooltip.dismissAllToolTips();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => const Page10(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Container(
          color: const Color(0xff1291a7),
          child: Column(
            children: [
              Expanded(
                flex: 9,
                child: Swiper(
                  controller: _swiperController,
                  index: _selectedIndex,
                  itemCount: _images.length,
                  scrollDirection: Axis.vertical,
                  layout: SwiperLayout.DEFAULT,
                  viewportFraction:
                      0.2, // ۱ / ۵ = هر بار ۵ آیتم هم‌زمان دیده می‌شه
                  scale: 1.0, // بدون کوچیک‌شدن آیتم‌های کناری
                  loop: false,
                  pagination: const SwiperPagination(),
                  control: null,
                  itemBuilder: (context, index) {
                    final imagePath = _images[index];
                    final isSelected = index == _selectedIndex;
                    return Center(
                      child: GestureDetector(
                        onTap: () => _onItemTapped(index, imagePath, "-"),
                        child: Container(
                          width: 100,
                          height: 100,
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            color: isSelected
                                ? const Color(0xff16b1cd)
                                : const Color(0x00000000),
                          ),
                          child: ClipOval(
                            child: Image.asset(
                              imagePath,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
              Expanded(
                  flex: 1,
                  child: const Text(
                      style: const TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.white),
                      "درس مورد نظر را انتخاب کنید"))
            ],
          ),
        ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }
}

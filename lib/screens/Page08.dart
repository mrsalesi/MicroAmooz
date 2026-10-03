import 'package:flutter/material.dart';
import 'package:card_swiper/card_swiper.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page09.dart';

class Page08 extends StatefulWidget {
  const Page08({Key? key}) : super(key: key);

  @override
  State<Page08> createState() => _Page08State();
}

class _Page08State extends State<Page08> {
  late SwiperController _swiperController;
  int _currentNavIndex = 2;

  final List<String> _images = [
    "images/pic13.png",
    "images/pic14.png",
    "images/pic15.png",
    "images/pic16.png",
    "images/pic17.png",
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

  void _onSlideTapped(String imagePath) {
    Tooltip.dismissAllToolTips();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => Page09(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Center(
        child: SizedBox(
          height: MediaQuery.of(context).size.height * 0.6,
          child: Swiper(
            controller: _swiperController,
            itemCount: _images.length,
            viewportFraction: 0.6,
            pagination: SwiperPagination(alignment: Alignment.bottomCenter),
            scale: 0.6, // اسلایدهای کناری ۴۰٪ کوچیک‌تر (۱ - ۰.۶ = ۰.۴)
            itemBuilder: (context, index) {
              final imagePath = _images[index];
              return GestureDetector(
                onTap: () => _onSlideTapped(imagePath),
                child: Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(20),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 10,
                        offset: const Offset(0, 5),
                      ),
                    ],
                  ),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(20),
                    child: Image.asset(
                      imagePath,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
              );
            },
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

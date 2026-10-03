import 'package:flutter/material.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page08.dart';

class Page07 extends StatefulWidget {
  final String imagePath;
  final String title;

  const Page07({
    Key? key,
    required this.imagePath,
    required this.title,
  }) : super(key: key);

  @override
  State<Page07> createState() => _Page07State();
}

class _Page07State extends State<Page07> {
  int _currentNavIndex = 2;

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Page08()),
          );
        },
        child: Column(
          children: [
            Expanded(
              child: Image.asset(
                widget.imagePath,
                fit: BoxFit.cover,
                width: double.infinity,
              ),
            ),
            Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
              child: Text(
                "به دوره ی " + widget.title + " " + "خوش آمدید",
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.black87,
                ),
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

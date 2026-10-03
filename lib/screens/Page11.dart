import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page12.dart';

class Page11 extends StatefulWidget {
  final int stageNumber;

  const Page11({Key? key, required this.stageNumber}) : super(key: key);

  @override
  State<Page11> createState() => _Page11State();
}

class _Page11State extends State<Page11> {
  int _currentNavIndex = 2;

  static const double _textX = 40;
  static const double _textY = 160;
  static const double _referenceImageWidth = 300;

  ImageStream? _imageStream;
  ImageStreamListener? _imageStreamListener;
  double? _imageAspectRatio;

  @override
  void initState() {
    super.initState();
    _resolveImage();
  }

  void _resolveImage() {
    final imageProvider = const AssetImage("images/picStateNo.png");
    _imageStream = imageProvider.resolve(const ImageConfiguration());
    _imageStreamListener = ImageStreamListener((info, _) {
      if (!mounted) return;
      setState(() {
        _imageAspectRatio = info.image.width / info.image.height;
      });
    });
    _imageStream!.addListener(_imageStreamListener!);
  }

  @override
  void dispose() {
    _imageStream?.removeListener(_imageStreamListener!);
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _goToPage12() {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: const Page12(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: GestureDetector(
        onTap: _goToPage12,
        child: Container(
          width: double.infinity,
          height: double.infinity,
          color: const Color(0xff1291a7),
          child: _imageAspectRatio == null
              ? const SizedBox.shrink()
              : LayoutBuilder(
                  builder: (context, constraints) {
                    final double maxW = constraints.maxWidth;
                    final double maxH = constraints.maxHeight;

                    double displayWidth;
                    double displayHeight;

                    if (maxW / maxH > _imageAspectRatio!) {
                      displayHeight = maxH;
                      displayWidth = displayHeight * _imageAspectRatio!;
                    } else {
                      displayWidth = maxW;
                      displayHeight = displayWidth / _imageAspectRatio!;
                    }

                    final double scale = displayWidth / _referenceImageWidth;

                    return Center(
                      child: SizedBox(
                        width: displayWidth,
                        height: displayHeight,
                        child: Stack(
                          children: [
                            Image.asset(
                              "images/picStateNo.png",
                              width: displayWidth,
                              height: displayHeight,
                              fit: BoxFit.contain,
                            ),
                            Positioned(
                              left: _textX * scale,
                              top: _textY * scale,
                              child: Text(
                                "${widget.stageNumber}",
                                style: TextStyle(
                                  fontSize: 88 * scale,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.black,
                                ),
                              ),
                            ),
                          ],
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

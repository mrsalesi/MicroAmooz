import 'package:flutter/material.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page11.dart';
import 'package:page_transition/page_transition.dart';

class StageData {
  final String title;
  final IconData icon;
  final bool alignRight; // true = سمت راست، false = سمت چپ

  StageData({
    required this.title,
    required this.icon,
    required this.alignRight,
  });
}

class Page10 extends StatefulWidget {
  const Page10({
    Key? key,
  }) : super(key: key);

  @override
  State<Page10> createState() => _Page10State();
}

class _Page10State extends State<Page10> {
  int _currentNavIndex = 2;

  final List<StageData> _stages = [
    StageData(
        title: "مرحله یک", icon: Icons.description_outlined, alignRight: true),
    StageData(
        title: "مرحله دوم",
        icon: Icons.description_outlined,
        alignRight: false),
    StageData(
        title: "مرحله سوم",
        icon: Icons.monetization_on_outlined,
        alignRight: true),
    StageData(
        title: "مرحله چهارم", icon: Icons.settings_outlined, alignRight: false),
    StageData(
        title: "مرحله پنجم", icon: Icons.event_seat_outlined, alignRight: true),
  ];

  void _onNavTapped(int index) {
    if (!mounted) return;
    setState(() {
      _currentNavIndex = index;
    });
  }

  void _onStageTapped(int stageNumber) {
    Navigator.push(
      context,
      PageTransition(
        type: PageTransitionType.leftToRight,
        child: Page11(stageNumber: stageNumber),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: SafeArea(
        child: Container(
          color: const Color(0xfff5f3ee),
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(vertical: 20),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final width = constraints.maxWidth;
                final cardWidth = width * 0.32;
                final cardHeight = cardWidth * 1.05;
                final rowGap = cardHeight * 0.58;

                return Stack(
                  children: [
                    // خط‌چین‌های اتصال بین کارت‌ها
                    CustomPaint(
                      size: Size(width,
                          rowGap * (_stages.length - 1) + cardHeight + 60),
                      painter: _DashedConnectorPainter(
                        stageCount: _stages.length,
                        cardWidth: cardWidth,
                        cardHeight: cardHeight,
                        rowGap: rowGap,
                        width: width,
                      ),
                    ),
                    // کارت‌ها
                    ...List.generate(_stages.length, (index) {
                      final stage = _stages[index];
                      final stageNumber =
                          index + 1; // شماره مرحله از ۱ شروع می‌شه
                      final top = index * rowGap;
                      return Positioned(
                        top: top + top * 0.15,
                        left: stage.alignRight ? null : width * 0.06,
                        right: stage.alignRight ? width * 0.06 : null,
                        child: GestureDetector(
                          onTap: () => _onStageTapped(stageNumber),
                          child: _StageCard(
                            title: stage.title,
                            icon: stage.icon,
                            width: cardWidth,
                            height: cardHeight,
                          ),
                        ),
                      );
                    }),
                  ],
                );
              },
            ),
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

class _StageCard extends StatelessWidget {
  final String title;
  final IconData icon;
  final double width;
  final double height;

  const _StageCard({
    required this.title,
    required this.icon,
    required this.width,
    required this.height,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: width,
      height: height + 24, // فضای اضافه برای سنجاق بالای کارت
      child: Stack(
        clipBehavior: Clip.none,
        alignment: Alignment.topCenter,
        children: [
          // بدنه‌ی کارت
          Positioned(
            top: 20,
            child: Container(
              width: width,
              height: height,
              decoration: BoxDecoration(
                color: const Color(0xffe9e9e9),
                borderRadius: BorderRadius.circular(18),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.15),
                    blurRadius: 8,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Expanded(
                    child: Center(
                      child: Icon(
                        icon,
                        size: width * 0.35,
                        color: const Color(0xff1291a7),
                      ),
                    ),
                  ),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    decoration: const BoxDecoration(
                      color: Color(0xff1291a7),
                      borderRadius: BorderRadius.only(
                        bottomLeft: Radius.circular(18),
                        bottomRight: Radius.circular(18),
                      ),
                    ),
                    child: Text(
                      title,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          // سنجاق (pin)
          Positioned(
            top: 0,
            child: _PinIcon(),
          ),
        ],
      ),
    );
  }
}

class _PinIcon extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Transform.rotate(
      angle: -0.3,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          gradient: const RadialGradient(
            colors: [Color(0xffff6b5b), Color(0xffcc2f22)],
            center: Alignment(-0.3, -0.3),
          ),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 4,
              offset: const Offset(1, 2),
            ),
          ],
        ),
      ),
    );
  }
}

class _DashedConnectorPainter extends CustomPainter {
  final int stageCount;
  final double cardWidth;
  final double cardHeight;
  final double rowGap;
  final double width;

  _DashedConnectorPainter({
    required this.stageCount,
    required this.cardWidth,
    required this.cardHeight,
    required this.rowGap,
    required this.width,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.grey.shade500
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    for (int i = 0; i < stageCount - 1; i++) {
      final bool currentRight = i % 2 == 0;
      final bool nextRight = (i + 1) % 2 == 0;

      final double currentCenterX = currentRight
          ? width - (width * 0.06) - (cardWidth / 2)
          : (width * 0.06) + (cardWidth / 2);
      final double currentCenterY = i * rowGap + 24 + cardHeight / 2;

      final double nextCenterX = nextRight
          ? width - (width * 0.06) - (cardWidth / 2)
          : (width * 0.06) + (cardWidth / 2);
      final double nextCenterY = (i + 1) * rowGap + 24 + cardHeight / 2;

      _drawDashedLine(
        canvas,
        paint,
        Offset(currentCenterX, currentCenterY),
        Offset(nextCenterX, nextCenterY),
      );
    }
  }

  void _drawDashedLine(Canvas canvas, Paint paint, Offset start, Offset end) {
    const dashWidth = 6.0;
    const dashSpace = 4.0;
    final totalDistance = (end - start).distance;
    final dashCount = (totalDistance / (dashWidth + dashSpace)).floor();
    final dx = (end.dx - start.dx) / dashCount;
    final dy = (end.dy - start.dy) / dashCount;

    double currentX = start.dx;
    double currentY = start.dy;

    for (int i = 0; i < dashCount; i++) {
      final nextX = currentX + dx * (dashWidth / (dashWidth + dashSpace));
      final nextY = currentY + dy * (dashWidth / (dashWidth + dashSpace));
      canvas.drawLine(Offset(currentX, currentY), Offset(nextX, nextY), paint);
      currentX += dx;
      currentY += dy;
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}

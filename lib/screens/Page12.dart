import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page13.dart';

class Page12 extends StatefulWidget {
  const Page12({Key? key}) : super(key: key);

  @override
  State<Page12> createState() => _Page12State();
}

class _Page12State extends State<Page12> with TickerProviderStateMixin {
  int _currentNavIndex = 2;

  // ---- پخش‌کننده صدا ----
  late AudioPlayer _audioPlayer;
  Duration _duration = Duration.zero;
  Duration _position = Duration.zero;
  bool _isPlaying = false;

  // ---- چرخش کارت ----
  late AnimationController _flipController; // 0 = رو، 1 = پشت

  // ---- سوال ----
  final String _question = "این متن سوال است؟";
  final List<String> _options = [
    "گزینه یک",
    "گزینه دو",
    "گزینه سه",
    "گزینه چهار"
  ];
  final int _correctIndex = 2; // ایندکس گزینه‌ی درست (فرضی)
  int? _selectedIndex;
  bool _answeredCorrectly = false;
  bool _hadWrongAttempt = false;

  // ---- افکت جواب درست ----
  bool _showCelebration = false;
  late AnimationController _celebrationController;
  late AudioPlayer _sfxPlayer;

  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _sfxPlayer = AudioPlayer();

    _audioPlayer.onDurationChanged.listen((d) {
      if (mounted) setState(() => _duration = d);
    });
    _audioPlayer.onPositionChanged.listen((p) {
      if (mounted) setState(() => _position = p);
    });
    _audioPlayer.onPlayerComplete.listen((_) {
      if (mounted) setState(() => _isPlaying = false);
    });

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );

    Future<void> _loadAudio() async {
      try {
        await _audioPlayer.setSourceUrl(
          "https://www.behkavosh.com/upload/p5477974873.mp3",
        );
      } catch (e) {
        debugPrint("خطا در بارگذاری فایل صوتی: $e");
        // می‌تونی اینجا یه پیام خطا هم به کاربر نشون بدی
      }
    }

    _loadAudio(); // به‌جای _audioPlayer.setSourceAsset(...)
  }

  @override
  void dispose() {
    _audioPlayer.dispose();
    _sfxPlayer.dispose();
    _flipController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() => _currentNavIndex = index);
  }

  // ---------------- کنترل پخش ----------------
  Future<void> _togglePlay() async {
    if (_isPlaying) {
      await _audioPlayer.pause();
    } else {
      await _audioPlayer.resume();
    }
    setState(() => _isPlaying = !_isPlaying);
  }

  Future<void> _seekBy(int seconds) async {
    final newPosition = _position + Duration(seconds: seconds);
    final clamped = newPosition < Duration.zero
        ? Duration.zero
        : (newPosition > _duration ? _duration : newPosition);
    await _audioPlayer.seek(clamped);
  }

  // ---------------- درگ برای چرخش کارت ----------------
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = -details.delta.dx / screenWidth; // راست به چپ = مثبت
    double newValue = _flipController.value + delta * 1.5;
    _flipController.value = newValue.clamp(0.0, 1.0);
  }

  void _onHorizontalDragEnd(DragEndDetails details) {
    if (_flipController.value > 0.5) {
      _flipController.animateTo(1.0, curve: Curves.easeOut);
    } else {
      _flipController.animateTo(0.0, curve: Curves.easeOut);
    }
  }

  // ---------------- منطق سوال ----------------
  Future<void> _onOptionTapped(int index) async {
    if (_answeredCorrectly) return;

    setState(() => _selectedIndex = index);

    if (index == _correctIndex) {
      setState(() => _answeredCorrectly = true);

      final firstTry = !_hadWrongAttempt;
      if (firstTry) {
        await _playCelebration();
      }

      await Future.delayed(const Duration(milliseconds: 600));
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const Page13()),
      );
    } else {
      setState(() => _hadWrongAttempt = true);
      await Future.delayed(const Duration(milliseconds: 700));
      if (!mounted) return;
      setState(() => _selectedIndex = null);
    }
  }

  Future<void> _playCelebration() async {
    setState(() => _showCelebration = true);
    _celebrationController.forward(from: 0);
    try {
      await _sfxPlayer.play(AssetSource("audio/correct.mp3"));
    } catch (_) {}
    await Future.delayed(const Duration(milliseconds: 900));
    if (mounted) setState(() => _showCelebration = false);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomAppBar(),
      body: Stack(
        children: [
          Container(
            width: double.infinity,
            height: double.infinity,
            color: const Color(0xfff5f3ee),
            child: Center(
              child: GestureDetector(
                onHorizontalDragUpdate: _onHorizontalDragUpdate,
                onHorizontalDragEnd: _onHorizontalDragEnd,
                child: AnimatedBuilder(
                  animation: _flipController,
                  builder: (context, child) {
                    final angle = _flipController.value * math.pi;
                    final isBack = _flipController.value > 0.5;

                    return Transform(
                      alignment: Alignment.center,
                      transform: Matrix4.identity()
                        ..setEntry(3, 2, 0.001)
                        ..rotateY(angle),
                      child: isBack
                          ? Transform(
                              alignment: Alignment.center,
                              transform: Matrix4.identity()..rotateY(math.pi),
                              child: _buildBackCard(),
                            )
                          : _buildFrontCard(),
                    );
                  },
                ),
                onTap: () {},
              ),
            ),
          ),
          if (_showCelebration) _buildCelebrationOverlay(),
        ],
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _currentNavIndex,
        onTap: _onNavTapped,
      ),
    );
  }

  // ---------------- روی کارت: پلیر صدا ----------------
  Widget _buildFrontCard() {
    final width = MediaQuery.of(context).size.width * 0.8;
    final progress = _duration.inMilliseconds == 0
        ? 0.0
        : _position.inMilliseconds / _duration.inMilliseconds;

    return Container(
      width: width,
      height: width * 1.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: width * 0.6,
            height: width * 0.3,
            child: CustomPaint(
              painter: _SemiCircleProgressPainter(progress: progress),
              child: Center(
                child: Padding(
                  padding: EdgeInsets.only(top: width * 0.08),
                  child: Text(
                    "${_formatDuration(_position)} / ${_formatDuration(_duration)}",
                    style: const TextStyle(
                      fontSize: 13,
                      color: Colors.black54,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
          ),
          const SizedBox(height: 24),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.replay_5, color: Color(0xff1291a7)),
                onPressed: () => _seekBy(-5),
              ),
              const SizedBox(width: 12),
              InkWell(
                onTap: _togglePlay,
                customBorder: const CircleBorder(),
                child: Container(
                  width: 64,
                  height: 64,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Color(0xff1291a7),
                  ),
                  child: Icon(
                    _isPlaying ? Icons.pause : Icons.play_arrow,
                    color: Colors.white,
                    size: 34,
                  ),
                ),
              ),
              const SizedBox(width: 12),
              IconButton(
                iconSize: 34,
                icon: const Icon(Icons.forward_5, color: Color(0xff1291a7)),
                onPressed: () => _seekBy(5),
              ),
            ],
          ),
          const SizedBox(height: 16),
          const Text(
            "برای مشاهده‌ی سوال، کارت را به چپ بکشید",
            style: TextStyle(fontSize: 11, color: Colors.black38),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  // ---------------- پشت کارت: سوال ----------------
  Widget _buildBackCard() {
    final width = MediaQuery.of(context).size.width * 0.8;

    return Container(
      width: width,
      height: width * 1.1,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(24),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.12),
            blurRadius: 16,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          const SizedBox(height: 8),
          Text(
            _question,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 20),
          Expanded(
            child: ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _options.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, index) => _buildOptionButton(index),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOptionButton(int index) {
    Color bgColor = const Color(0xffeef0f0);
    Color textColor = Colors.black87;

    final bool isSelectedWrong =
        _selectedIndex == index && index != _correctIndex;
    final bool showAsCorrect =
        (_selectedIndex == index && index == _correctIndex) ||
            (_answeredCorrectly && index == _correctIndex);

    if (showAsCorrect) {
      bgColor = Colors.green.shade400;
      textColor = Colors.white;
    } else if (isSelectedWrong) {
      bgColor = Colors.red.shade400;
      textColor = Colors.white;
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      child: Material(
        color: bgColor,
        borderRadius: BorderRadius.circular(12),
        child: InkWell(
          borderRadius: BorderRadius.circular(12),
          onTap: () => _onOptionTapped(index),
          child: Container(
            padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 12),
            child: Text(
              _options[index],
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.w600,
                color: textColor,
              ),
            ),
          ),
        ),
      ),
    );
  }

  // ---------------- افکت تصویری جواب درست ----------------
  Widget _buildCelebrationOverlay() {
    return Positioned.fill(
      child: IgnorePointer(
        child: Container(
          color: Colors.black.withOpacity(0.35),
          child: Center(
            child: ScaleTransition(
              scale: CurvedAnimation(
                parent: _celebrationController,
                curve: Curves.elasticOut,
              ),
              child: Container(
                width: 140,
                height: 140,
                decoration: const BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                ),
                child: const Icon(
                  Icons.check_circle,
                  color: Colors.green,
                  size: 110,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ---------------- نیم‌دایره‌ی پروگرس بار ----------------
class _SemiCircleProgressPainter extends CustomPainter {
  final double progress; // بین ۰ تا ۱

  _SemiCircleProgressPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height);
    final radius = size.width / 2;
    final rect = Rect.fromCircle(center: center, radius: radius);

    final backgroundPaint = Paint()
      ..color = Colors.grey.shade300
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    final progressPaint = Paint()
      ..color = const Color(0xff1291a7)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 8
      ..strokeCap = StrokeCap.round;

    // نیم‌دایره‌ی بالا: از ۱۸۰ درجه شروع، ۱۸۰ درجه ادامه
    canvas.drawArc(rect, math.pi, math.pi, false, backgroundPaint);
    canvas.drawArc(rect, math.pi, math.pi * progress.clamp(0.0, 1.0), false,
        progressPaint);
  }

  @override
  bool shouldRepaint(covariant _SemiCircleProgressPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}

import 'dart:math' as math;
import 'package:audioplayers/audioplayers.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';
import '../widgets/CustomBottomNav.dart';
import '../widgets/CustopAppBar.dart';
import 'Page14.dart';

class Page13 extends StatefulWidget {
  const Page13({Key? key}) : super(key: key);

  @override
  State<Page13> createState() => _Page13State();
}

class _Page13State extends State<Page13> with TickerProviderStateMixin {
  int _currentNavIndex = 2;

  // ---- ویدیو ----
  VideoPlayerController? _videoController;
  bool _isFullScreen = false;
  bool _isInitialized = false;

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
  final int _correctIndex = 1; // ایندکس گزینه‌ی درست (فرضی)
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
    _sfxPlayer = AudioPlayer();

    _flipController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );

    _celebrationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _sfxPlayer.dispose();
    _flipController.dispose();
    _celebrationController.dispose();
    super.dispose();
  }

  void _onNavTapped(int index) {
    setState(() => _currentNavIndex = index);
  }

  // ---------------- شروع ویدیو (تمام‌صفحه) ----------------
  Future<void> _openFullScreenVideo() async {
    _videoController = VideoPlayerController.asset("video/lesson1.mp4");
    await _videoController!.initialize();
    setState(() {
      _isInitialized = true;
      _isFullScreen = true;
    });
    _videoController!.play();

    if (!mounted) return;
    await Navigator.push(
      context,
      MaterialPageRoute(
        fullscreenDialog: true,
        builder: (_) => _FullScreenVideoPlayer(
          controller: _videoController!,
          onClose: () {
            Navigator.pop(context);
          },
        ),
      ),
    );

    // وقتی از فول‌اسکرین برگشت
    if (mounted) {
      setState(() => _isFullScreen = false);
    }
  }

  // ---------------- درگ برای چرخش کارت ----------------
  void _onHorizontalDragUpdate(DragUpdateDetails details) {
    final screenWidth = MediaQuery.of(context).size.width;
    final delta = -details.delta.dx / screenWidth;
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
        MaterialPageRoute(builder: (_) => const Page14()),
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

  // ---------------- روی کارت: کاور ویدیو ----------------
  Widget _buildFrontCard() {
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
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          Expanded(
            child: ClipRRect(
              borderRadius: BorderRadius.circular(16),
              child: GestureDetector(
                onTap: _openFullScreenVideo,
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Image.asset(
                      "images/videoCover.png",
                      width: double.infinity,
                      height: double.infinity,
                      fit: BoxFit.cover,
                    ),
                    Container(
                      color: Colors.black.withOpacity(0.25),
                    ),
                    Container(
                      width: 64,
                      height: 64,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        color: Colors.white,
                      ),
                      child: const Icon(
                        Icons.play_arrow,
                        color: Color(0xff1291a7),
                        size: 36,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const SizedBox(height: 12),
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

// ---------------- صفحه‌ی تمام‌صفحه‌ی پخش ویدیو ----------------
class _FullScreenVideoPlayer extends StatefulWidget {
  final VideoPlayerController controller;
  final VoidCallback onClose;

  const _FullScreenVideoPlayer({
    required this.controller,
    required this.onClose,
  });

  @override
  State<_FullScreenVideoPlayer> createState() => _FullScreenVideoPlayerState();
}

class _FullScreenVideoPlayerState extends State<_FullScreenVideoPlayer> {
  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onVideoUpdate);
  }

  void _onVideoUpdate() {
    if (mounted) setState(() {});
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onVideoUpdate);
    widget.controller.pause();
    super.dispose();
  }

  void _togglePlay() {
    if (widget.controller.value.isPlaying) {
      widget.controller.pause();
    } else {
      widget.controller.play();
    }
    setState(() {});
  }

  void _seekBy(int seconds) {
    final current = widget.controller.value.position;
    final total = widget.controller.value.duration;
    var target = current + Duration(seconds: seconds);
    if (target < Duration.zero) target = Duration.zero;
    if (target > total) target = total;
    widget.controller.seekTo(target);
  }

  String _formatDuration(Duration d) {
    final minutes = d.inMinutes.remainder(60).toString().padLeft(2, '0');
    final seconds = d.inSeconds.remainder(60).toString().padLeft(2, '0');
    return "$minutes:$seconds";
  }

  @override
  Widget build(BuildContext context) {
    final controller = widget.controller;
    final position = controller.value.position;
    final duration = controller.value.duration;
    final progress = duration.inMilliseconds == 0
        ? 0.0
        : position.inMilliseconds / duration.inMilliseconds;

    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Stack(
          children: [
            Center(
              child: controller.value.isInitialized
                  ? AspectRatio(
                      aspectRatio: controller.value.aspectRatio,
                      child: VideoPlayer(controller),
                    )
                  : const CircularProgressIndicator(color: Colors.white),
            ),
            // دکمه بستن
            Positioned(
              top: 8,
              right: 8,
              child: IconButton(
                icon: const Icon(Icons.close, color: Colors.white, size: 28),
                onPressed: widget.onClose,
              ),
            ),
            // کنترل‌ها
            Positioned(
              left: 0,
              right: 0,
              bottom: 20,
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: LinearProgressIndicator(
                      value: progress.clamp(0.0, 1.0),
                      backgroundColor: Colors.white24,
                      color: const Color(0xff1291a7),
                      minHeight: 4,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(_formatDuration(position),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                        Text(_formatDuration(duration),
                            style: const TextStyle(
                                color: Colors.white, fontSize: 11)),
                      ],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      IconButton(
                        iconSize: 34,
                        icon: const Icon(Icons.replay_5, color: Colors.white),
                        onPressed: () => _seekBy(-5),
                      ),
                      const SizedBox(width: 16),
                      InkWell(
                        onTap: _togglePlay,
                        customBorder: const CircleBorder(),
                        child: Container(
                          width: 60,
                          height: 60,
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                            color: Color(0xff1291a7),
                          ),
                          child: Icon(
                            controller.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                            color: Colors.white,
                            size: 32,
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      IconButton(
                        iconSize: 34,
                        icon: const Icon(Icons.forward_5, color: Colors.white),
                        onPressed: () => _seekBy(5),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

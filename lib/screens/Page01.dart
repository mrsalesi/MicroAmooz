import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../data/Auth.dart';
import 'Page02.dart';
import 'Page06.dart';

/// صفحه‌ی اول اپلیکیشن
/// اگر توکن ذخیره‌شده معتبر باشد مستقیم به Page06 می‌رود.
class Page01 extends StatefulWidget {
  const Page01({Key? key}) : super(key: key);

  @override
  State<Page01> createState() => _Page01State();
}

class _Page01State extends State<Page01> {
  bool _checkingToken = true;

  @override
  void initState() {
    super.initState();
    _openWithSavedToken();
  }

  Future<void> _openWithSavedToken() async {
    final result = await Auth.loginWithSavedToken();
    if (!mounted) return;
    if (result["success"] == true) {
      Navigator.pushReplacement(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: const Page06(),
        ),
      );
      return;
    }
    setState(() => _checkingToken = false);
  }

  @override
  Widget build(BuildContext context) {
    if (_checkingToken) {
      return const Scaffold(
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      body: Column(children: [
        const SizedBox(
          height: 100,
        ),
        Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                color: Colors.grey.withValues(alpha: 0.5),
                spreadRadius: 5,
                blurRadius: 7,
                offset: Offset(0, 3), // changes position of shadow
              ),
            ],
          ),
          margin: const EdgeInsets.all(30),
          child: InkWell(
            child: Image.asset(
              "images/01_small.png",
            ),
            onTap: () {
              Navigator.push(
                context,
                PageTransition(
                  type: PageTransitionType.leftToRight,
                  child: const Page02(),
                ),
              );
            },
          ),
        )
      ]),
    );
  }
}

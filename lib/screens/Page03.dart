import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../data/Auth.dart';
import '../utility/Tools.dart';
import 'Page06.dart';

class Page03 extends StatefulWidget {
  final String mobile;

  const Page03({Key? key, this.mobile = ''}) : super(key: key);

  @override
  State<Page03> createState() => _Page03State();
}

class _Page03State extends State<Page03> {
  late TextEditingController _controller;
  late FocusNode _focusNode;
  String _value = "";
  final int _otpLength = 4; // به‌جای widget.length
  bool _isLoading = false;

  Future<void> _onConfirmPressed() async {
    if (_isLoading) return;
    if (widget.mobile.isEmpty) {
      Tools.toast(ToastType.warning, "شماره موبایل برای تایید کد مشخص نیست");
      return;
    }
    if (_value.length != _otpLength) {
      Tools.toast(ToastType.warning, "کد چهار رقمی پیامک را وارد کنید");
      return;
    }

    setState(() => _isLoading = true);
    final result = await Auth.verifySms(mobile: widget.mobile, code: _value);
    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      Tools.toast(ToastType.info, result["message"]?.toString() ?? "ورود با موفقیت انجام شد");
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: const Page06(),
        ),
      );
      return;
    }

    Tools.toast(
      ToastType.danger,
      result["message"]?.toString() ?? "کد تایید هویت صحیح نمی باشد",
    );
  }

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController();
    _focusNode = FocusNode();
  }

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xffb2b2b2),
        centerTitle: true,
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: EdgeInsets.all(15.0),
              child: Image(
                image: AssetImage('images/Logo.png'),
                height: 35,
              ),
            ),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xffb2b2b2), Color(0xff1291a7)],
              stops: [0.5, 0.5],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
          child: Column(
            children: [
              const SizedBox(height: 40),
              Padding(
                padding: const EdgeInsets.only(left: 40, right: 40),
                child: Image.asset("images/02_small.png"),
              ),
              Container(
                width: 400,
                height: 330,
                margin: const EdgeInsets.only(left: 40, right: 40, top: 0),
                decoration: const BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.only(
                    bottomLeft: Radius.circular(35),
                    bottomRight: Radius.circular(35),
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      GestureDetector(
                        onTap: () => _focusNode.requestFocus(),
                        child: Stack(
                          alignment: Alignment.center,
                          children: [
                            // ردیف باکس‌های نمایشی
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: List.generate(_otpLength, (index) {
                                final isFilled = index < _value.length;
                                final isActive = index == _value.length;
                                return Container(
                                  margin:
                                      const EdgeInsets.symmetric(horizontal: 6),
                                  width: 50,
                                  height: 55,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: isActive
                                          ? Colors.blue
                                          : (isFilled
                                              ? Colors.blue.shade200
                                              : Colors.grey.shade300),
                                      width: isActive ? 2 : 1,
                                    ),
                                  ),
                                  child: Text(
                                    isFilled ? _value[index] : '',
                                    style: const TextStyle(
                                      fontSize: 22,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                );
                              }),
                            ),
                            // TextField نامرئی که واقعاً کیبورد و ورودی رو مدیریت می‌کنه
                            Opacity(
                              opacity: 0,
                              child: SizedBox(
                                width: 300,
                                height: 55,
                                child: TextField(
                                  controller: _controller,
                                  focusNode: _focusNode,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  maxLength: _otpLength,
                                  autofocus: true,
                                  decoration:
                                      const InputDecoration(counterText: ''),
                                  onChanged: (val) {
                                    setState(() {
                                      _value = val;
                                    });
                                  },
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Text(
                        "کد ارسالی را وارد نمایید",
                        style: TextStyle(
                          fontSize: 12,
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                      ),
                      InkWell(
                        onTap: _isLoading ? null : _onConfirmPressed,
                        child: Container(
                          margin: const EdgeInsets.all(30),
                          alignment: Alignment.center,
                          width: 120,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Colors.black45,
                          ),
                          child: _isLoading
                              ? const SizedBox(
                                  width: 16,
                                  height: 16,
                                  child: CircularProgressIndicator(
                                    strokeWidth: 2,
                                    color: Colors.white,
                                  ),
                                )
                              : const Text(
                                  "وارد شوید",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.white,
                                  ),
                                ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import 'Page03.dart';
import 'Page04.dart';
import 'Page05.dart';
import '../data/Auth.dart';
import '../utility/Tools.dart';

// ... بدنه‌ی کلاس بدون تغییر، فقط این خط عوض می‌شود:
// final result = await Tools.login(...)  →
// final result = await Auth.login(...)

class Page02 extends StatefulWidget {
  const Page02({Key? key}) : super(key: key);

  @override
  State<Page02> createState() => _Page02State();
}

class _Page02State extends State<Page02> {
  final TextEditingController _usernameController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _usernameController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _onLoginPressed() async {
    final username = _usernameController.text.trim();
    final password = _passwordController.text.trim();

    if (username.isEmpty) {
      Tools.toast(ToastType.warning, "لطفاً نام کاربری را وارد کنید");
      return;
    }
    if (password.isEmpty) {
      Tools.toast(ToastType.warning, "لطفاً رمز عبور را وارد کنید");
      return;
    }
    if (password.length < 4) {
      Tools.toast(ToastType.warning, "رمز عبور باید حداقل ۴ کاراکتر باشد");
      return;
    }

    setState(() => _isLoading = true);

    // تغییر کلیدی: فراخوانی از طریق Auth به‌جای Tools
    final result = await Auth.login(username: username, password: password);

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      Tools.toast(ToastType.info, "ورود با موفقیت انجام شد");
      Navigator.push(
        context,
        PageTransition(
          type: PageTransitionType.leftToRight,
          child: const Page03(),
        ),
      );
    } else {
      Tools.toast(
        ToastType.danger,
        result["message"] ?? "نام کاربری یا رمز عبور اشتباه است",
      );
    }
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
          )),
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
          child: Column(children: [
            const SizedBox(height: 40),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Image.asset("images/02_small.png"),
            ),
            Container(
                width: 400,
                height: 300,
                margin: const EdgeInsets.only(left: 40, right: 40, top: 0),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                      bottomLeft: Radius.circular(35),
                      bottomRight: Radius.circular(35),
                    )),
                child: Padding(
                  padding: const EdgeInsets.all(15.0),
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                                height: 30,
                                margin: const EdgeInsets.all(3),
                                child: TextFormField(
                                  controller: _usernameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '',
                                    contentPadding: EdgeInsets.only(left: 10),
                                  ),
                                  textDirection: TextDirection.ltr,
                                  textAlignVertical: TextAlignVertical.top,
                                )),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "نام کاربری",
                                  style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.bold),
                                )),
                          ),
                        ],
                      ),
                      const Divider(
                        color: Color(0xff1291a7),
                        thickness: 1,
                      ),
                      Container(
                        height: 30,
                        margin: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _passwordController,
                                obscureText: true,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                                textDirection: TextDirection.ltr,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "رمز عبور",
                                    style: TextStyle(
                                        fontSize: 12,
                                        fontWeight: FontWeight.bold),
                                  )),
                            ),
                          ],
                        ),
                      ),
                      const Divider(
                        color: Color(0xff1291a7),
                        thickness: 1,
                      ),
                      InkWell(
                        onTap: _isLoading ? null : _onLoginPressed,
                        child: Container(
                          margin: const EdgeInsets.all(10),
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
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const Page05(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          width: 120,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Colors.black45,
                          ),
                          child: const Text(
                            "ثبت نام کنید",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          Navigator.push(
                            context,
                            PageTransition(
                              type: PageTransitionType.leftToRight,
                              child: const Page04(),
                            ),
                          );
                        },
                        child: Container(
                          margin: const EdgeInsets.all(10),
                          alignment: Alignment.center,
                          width: 120,
                          padding: const EdgeInsets.all(5),
                          decoration: const BoxDecoration(
                            borderRadius: BorderRadius.all(Radius.circular(35)),
                            color: Colors.black45,
                          ),
                          child: const Text(
                            "فراموشی رمز",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                )),
          ]),
        ),
      ),
    );
  }
}

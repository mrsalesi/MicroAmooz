import 'package:behkavoshapp/widgets/CustopAppBar.dart';
import 'package:flutter/material.dart';
import 'package:page_transition/page_transition.dart';

import '../data/Auth.dart';
import '../utility/Tools.dart';
import 'Page02.dart';
import 'Page03.dart';
import 'Page04.dart';

/// صفحه‌ی ثبت‌نام کاربر جدید
/// فیلدها: نام، نام خانوادگی، شماره همراه
/// بعد از ولیدیشن موفق، درخواست ثبت‌نام به سرور ارسال می‌شود
class Page05 extends StatefulWidget {
  const Page05({Key? key}) : super(key: key);

  @override
  State<Page05> createState() => _Page05State();
}

class _Page05State extends State<Page05> {
  // کنترلرهای فیلدهای ورودی - برای خواندن مقدار واردشده توسط کاربر
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _lastNameController = TextEditingController();
  final TextEditingController _mobileController = TextEditingController();

  // وضعیت لودینگ - وقتی true است، دکمه‌ی ثبت‌نام غیرفعال و اسپینر نمایش داده می‌شود
  bool _isLoading = false;

  @override
  void dispose() {
    // آزادسازی حافظه‌ی کنترلرها هنگام بسته شدن صفحه
    _firstNameController.dispose();
    _lastNameController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  /// بررسی اینکه آیا شماره‌ی وارد شده یک شماره موبایل معتبر ایرانی است
  /// فرمت مورد قبول: 09xxxxxxxxx (۱۱ رقم، شروع با 09)
  bool _isValidIranianMobile(String mobile) {
    final regex = RegExp(r'^09\d{9}$');
    return regex.hasMatch(mobile);
  }

  /// متد اصلی ثبت‌نام:
  /// ۱. ولیدیشن فیلدها
  /// ۲. ارسال درخواست به سرور با Tools.register (که خودش از Tools.send استفاده می‌کند)
  /// ۳. نمایش نتیجه با Tools.toast و هدایت به صفحه‌ی بعد در صورت موفقیت
  Future<void> _onRegisterPressed() async {
    final firstName = _firstNameController.text.trim();
    final lastName = _lastNameController.text.trim();
    final mobile = _mobileController.text.trim();

    if (firstName.isEmpty) {
      Tools.toast(ToastType.warning, "لطفاً نام خود را وارد کنید");
      return;
    }
    if (lastName.isEmpty) {
      Tools.toast(ToastType.warning, "لطفاً نام خانوادگی خود را وارد کنید");
      return;
    }
    if (mobile.isEmpty) {
      Tools.toast(ToastType.warning, "لطفاً شماره همراه خود را وارد کنید");
      return;
    }
    if (!_isValidIranianMobile(mobile)) {
      Tools.toast(ToastType.warning, "شماره همراه وارد شده معتبر نیست");
      return;
    }

    setState(() => _isLoading = true);

    // تغییر کلیدی: فراخوانی از طریق Auth به‌جای Tools
    final result = await Auth.register(
      firstName: firstName,
      lastName: lastName,
      mobile: mobile,
    );

    if (!mounted) return;
    setState(() => _isLoading = false);

    if (result["success"] == true) {
      Tools.toast(ToastType.info, "ثبت‌نام با موفقیت انجام شد");
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
        result["message"] ?? "خطا در ثبت‌نام، لطفاً دوباره تلاش کنید",
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
                  image: AssetImage(
                    'images/Logo.png',
                  ),
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
            const SizedBox(
              height: 40,
            ),
            Padding(
              padding: const EdgeInsets.only(left: 40, right: 40),
              child: Image.asset(
                "images/02_small.png",
              ),
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
                      // ---------- فیلد نام ----------
                      Row(
                        children: [
                          Expanded(
                            flex: 5,
                            child: Container(
                                height: 30,
                                margin: const EdgeInsets.all(3),
                                child: TextFormField(
                                  controller: _firstNameController,
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: '',
                                    contentPadding: EdgeInsets.only(left: 10),
                                  ),
                                  textDirection: TextDirection.rtl,
                                  textAlignVertical: TextAlignVertical.top,
                                )),
                          ),
                          const Expanded(
                            flex: 2,
                            child: Align(
                                alignment: Alignment.centerRight,
                                child: Text(
                                  "نام ",
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
                      // ---------- فیلد نام خانوادگی ----------
                      Container(
                        height: 30,
                        margin: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _lastNameController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.only(right: 10),
                                ),
                                textDirection: TextDirection.rtl,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "نام خانوادگی",
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
                      // ---------- فیلد شماره همراه ----------
                      Container(
                        height: 30,
                        margin: const EdgeInsets.all(0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 5,
                              child: TextFormField(
                                controller: _mobileController,
                                decoration: const InputDecoration(
                                  border: InputBorder.none,
                                  hintText: '',
                                  contentPadding: EdgeInsets.only(left: 10),
                                ),
                                textDirection: TextDirection.ltr,
                                keyboardType: TextInputType.phone,
                                textAlignVertical: TextAlignVertical.top,
                              ),
                            ),
                            const Expanded(
                              flex: 2,
                              child: Align(
                                  alignment: Alignment.centerRight,
                                  child: Text(
                                    "شماره همراه",
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
                      // ---------- دکمه‌ی ثبت‌نام ----------
                      InkWell(
                        onTap: _isLoading ? null : _onRegisterPressed,
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
                                  "ثبت نام",
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

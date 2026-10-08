import '../utility/Tools.dart';

/// کلاس مدیریت احراز هویت کاربر، منطبق بر پروژه‌ی جاوا وب سمت سرور
/// که با Session (نه توکن) کار می‌کند.
///
/// نکته‌ی مهم درباره‌ی وضعیت لاگین:
/// چون این سرور از Session/Cookie استفاده می‌کند (نه JWT/Token)،
/// خود کوکی سشن را Tools.dart به‌صورت خودکار مدیریت می‌کند
/// (روی وب توسط خود مرورگر، روی اندروید/iOS/دسکتاپ به‌صورت دستی در حافظه).
/// بنابراین اینجا دیگر نیازی به ذخیره یا خواندن "توکن" نیست.
///
/// _isLoggedIn فقط یک پرچم کمکی محلی است که بعد از لاگین موفق true می‌شود
/// تا UI بتواند به‌سرعت (بدون زدن درخواست به سرور) بفهمد که ورود انجام
/// شده یا نه. توجه: این پرچم معادل "سشن هنوز روی سرور معتبر است" نیست؛
/// اگر سشن سمت سرور منقضی شده باشد (مثلاً بعد از مدتی بی‌کاری)، هنوز هم
/// true می‌ماند تا وقتی که یک درخواست واقعی بزنیم و سرور خطای عدم دسترسی
/// برگرداند. وقتی فرمت دقیق پاسخ سرور برای این حالت را گفتی، می‌توانیم
/// این بخش را دقیق‌تر کنیم (مثلاً خودکار logout کردن وقتی سرور ۴۰۱/۴۰۳ بدهد).
class Auth {
  // کلید ذخیره‌سازی وضعیت لاگین در حافظه‌ی محلی، صرفاً برای راحتی UI
  // (نه برای احراز هویت واقعی - احراز هویت واقعی را کوکی سشن انجام می‌دهد)
  static const String _loggedInFlagKey = "is_logged_in";

  /// این متد باید یک‌بار موقع استارت اپ (در main.dart) صدا زده بشود
  /// تا پرچم لاگین قبلی (در صورت وجود) بارگذاری شود.
  ///
  /// توجه: روی وب، اگر کاربر مرورگر را کامل ببندد و کوکی سشن منقضی
  /// شده باشد، این پرچم به‌تنهایی تضمین نمی‌کند که کاربر واقعاً هنوز
  /// لاگین است؛ فقط یک حدس اولیه برای UI است.
  static Future<void> init() async {
    // فعلاً کاری لازم نیست انجام شود چون کوکی را خود Tools مدیریت می‌کند؛
    // این متد برای یکدست ماندن الگوی فراخوانی (Auth.init در main.dart) نگه داشته شده.
  }

  /// درخواست ورود؛ معادل سمت سرور: do=Access_User.login
  ///
  /// نکته: پارامترهای کپچا فعلاً خالی ارسال می‌شوند؛ وقتی کپچا را
  /// در UI اضافه کردیم، این متد باید captchaWord و captchaImageFile را
  /// هم به‌عنوان پارامتر بگیرد و به سرور پاس بدهد.
  static Future<Map<String, dynamic>> login({
    required String username,
    required String password,
  }) async {
    final result = await Tools.send(
      "Access_User.loginAppFlutter",
      params: {
        "jj": "0",
        "captcha_image_File": "",
        "user_email": username,
        "captcha_word": "",
        "user_pass": password,
      },
    );

    // TODO: به محض اینکه فرمت دقیق JSON پاسخ سرور مشخص شد (مثلاً سرور
    // یک فیلد مثل {"result":"ok"} یا {"error":"..."} برمی‌گرداند)،
    // باید اینجا بر اساس محتوای result["data"] (نه فقط کد HTTP)
    // تشخیص بدهیم لاگین واقعاً موفق بوده یا نه، چون این سرور همیشه
    // کد ۲۰۰ برمی‌گرداند حتی برای خطاهای منطقی (مثل رمز اشتباه).
    if (result["success"] == true) {
      await _setLoggedInFlag(true);
    }

    return result;
  }

  /// درخواست ثبت‌نام
  ///
  /// نام دقیق "do" سمت سرور هنوز تأیید نشده - فعلاً بر اساس الگوی
  /// Access_User.login حدس زده شده (مثلاً Access_User.insert یا
  /// Access_User.register). لطفاً نام دقیق اکشن و پارامترهای مورد
  /// انتظار سرور (مثل اینکه دقیقاً چه کلیدهایی غیر از نام/نام خانوادگی/
  /// موبایل لازم است) را بگو تا این متد را کامل اصلاح کنم.
  static Future<Map<String, dynamic>> register({
    required String firstName,
    required String lastName,
    required String mobile,
  }) async {
    final result = await Tools.send(
      "Access_User.register", // TODO: نام دقیق اکشن سمت سرور را تأیید کن
      params: {
        "jj": "0",
        "captcha_image_File": "",
        "captcha_word": "",
        "user_name": firstName,
        "user_family": lastName,
        "user_mobile": mobile,
      },
    );

    if (result["success"] == true) {
      await _setLoggedInFlag(true);
    }

    return result;
  }

  /// درخواست خروج؛ معادل سمت سرور: do=Access_User.signOut
  static Future<Map<String, dynamic>> logout() async {
    final result = await Tools.send("Access_User.signOut");
    await _setLoggedInFlag(false);
    return result;
  }

  /// بررسی اینکه آیا کاربر (طبق آخرین اطلاع محلی) لاگین است یا نه.
  /// این فقط یک حدس سریع برای UI است، نه تأییدیه‌ی قطعی از سرور
  /// (توضیح کامل در بالای کلاس).
  static Future<bool> isLoggedIn() async {
    final value = await Tools.getValue(_loggedInFlagKey);
    return value == "true";
  }

  /// متد کمکی داخلی برای ذخیره‌ی پرچم وضعیت لاگین
  static Future<void> _setLoggedInFlag(bool value) async {
    await Tools.saveValue(_loggedInFlagKey, value.toString());
  }
}

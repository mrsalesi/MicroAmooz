import 'dart:async';
import 'package:dio/dio.dart';
import 'package:dio_cookie_manager/dio_cookie_manager.dart';
import 'package:cookie_jar/cookie_jar.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// نوع پیام Toast - برای تعیین رنگ و آیکون مناسب استفاده می‌شود
enum ToastType { warning, info, danger }

/// کلاس ابزارهای عمومی پروژه:
/// - ارسال درخواست به سرور جاوای تحت وب (پروتکل do=ClassName.methodName + Session)
/// - مدیریت خودکار کوکی سشن با dio + cookie_jar (به‌جای مدیریت دستی)
/// - ذخیره‌سازی محلی (SharedPreferences / localStorage روی وب)
/// - نمایش پیام‌های Toast سفارشی

class Tools {
  static final GlobalKey<NavigatorState> navigatorKey =
      GlobalKey<NavigatorState>();

  static const String baseUrl = "https://api.microAmooz.ir/HMIS/Server";
  static const Duration _timeoutDuration = Duration(seconds: 15);

  // نمونه‌ی Dio که برای همه‌ی درخواست‌ها استفاده می‌شود
  static late final Dio _dio;

  // Cookie Jar فقط روی پلتفرم‌های غیر وب لازم است. روی وب، خود مرورگر
  // کوکی‌ها را مدیریت می‌کند و نیازی به cookie_jar نیست (در واقع dio
  // روی وب اصلاً نمی‌تواند خودش کوکی ست کند، این کار را مرورگر انجام می‌دهد).
  static CookieJar? _cookieJar;

  /// این متد باید یک‌بار موقع استارت اپ (قبل از هر درخواستی) صدا زده شود
  /// تا Dio و مدیریت کوکی به‌درستی مقداردهی اولیه شوند.
  static Future<void> init() async {
    _dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: _timeoutDuration,
        receiveTimeout: _timeoutDuration,
        contentType: Headers.formUrlEncodedContentType,
        // روی وب withCredentials باید true باشد تا مرورگر اجازه بدهد
        // کوکی سشن (JSESSIONID) بین درخواست‌ها حفظ و ارسال شود.
        extra: {'withCredentials': true},
      ),
    );
    print(baseUrl);
    if (!kIsWeb) {
      // روی اندروید/iOS/دسکتاپ: از cookie_jar برای نگه‌داری خودکار
      // کوکی‌ها بین درخواست‌ها استفاده می‌کنیم (جایگزین مدیریت دستی قبلی)
      _cookieJar = CookieJar();
      _dio.interceptors.add(CookieManager(_cookieJar!));
    }
    // روی وب نیازی به Interceptor کوکی نیست؛ withCredentials بالا کافیست
    // و خود مرورگر کوکی Set-Cookie را می‌خواند و در درخواست بعدی می‌فرستد.
  }

  // ==================== بخش شبکه (Network) ====================

  /// متد عمومی ارسال درخواست به سرور
  ///
  /// [action] مقدار پارامتر "do" سمت سرور، مثلاً "Access_User.login"
  /// [params] سایر پارامترهای درخواست (مثل user_email, user_pass)
  ///
  /// خروجی یک Map استاندارد با کلیدهای:
  /// - success, statusCode, message, data
  static Future<Map<String, dynamic>> send(
    String action, {
    Map<String, dynamic>? params,
  }) async {
    try {
      final Map<String, dynamic> formData = {
        'do': action,
        ...?params,
      };

      final response = await _dio.post(
        '', // چون baseUrl همان آدرس کامل است، مسیر اضافه‌ای لازم نیست
        data: formData,
      );

      return {
        "success": true,
        "statusCode": response.statusCode,
        "data": response.data,
      };
    } on DioException catch (e) {
      if (e.type == DioExceptionType.connectionTimeout ||
          e.type == DioExceptionType.receiveTimeout) {
        return _errorResult("پاسخی از سرور دریافت نشد (Timeout)");
      }
      if (e.response != null) {
        // سرور پاسخ داده ولی با کد خطا (مثلاً ۴۰۰ یا ۵۰۰)
        final data = e.response!.data;
        return {
          "success": false,
          "statusCode": e.response!.statusCode,
          "message": data is Map && data.containsKey("message")
              ? data["message"]
              : "خطا از سمت سرور",
          "data": data,
        };
      }
      return _errorResult("خطای ارتباط با سرور: ${e.message}");
    } catch (e) {
      return _errorResult("خطای ناشناخته: $e");
    }
  }

  static Map<String, dynamic> _errorResult(String message) {
    return {
      "success": false,
      "statusCode": null,
      "message": message,
      "data": null,
    };
  }

  // ==================== بخش ذخیره‌سازی محلی ====================

  static Future<bool> saveValue(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.setString(key, value);
  }

  static Future<String?> getValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  static Future<bool> removeValue(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.remove(key);
  }

  // ==================== بخش Toast ====================
  // (بدون تغییر نسبت به نسخه‌ی قبلی)

  static OverlayEntry? _currentToastEntry;
  static Timer? _currentToastTimer;

  static void toast(ToastType type, String message) {
    final overlayState = navigatorKey.currentState?.overlay;
    if (overlayState == null) {
      debugPrint("Tools.toast: Overlay در دسترس نیست. پیام: $message");
      return;
    }

    _currentToastTimer?.cancel();
    _currentToastEntry?.remove();
    _currentToastEntry = null;

    late OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _ToastWidget(
        type: type,
        message: message,
        onDismissed: () {
          entry.remove();
          if (_currentToastEntry == entry) {
            _currentToastEntry = null;
          }
        },
      ),
    );

    _currentToastEntry = entry;
    overlayState.insert(entry);

    _currentToastTimer = Timer(const Duration(seconds: 3), () {
      if (_currentToastEntry == entry) {
        entry.remove();
        _currentToastEntry = null;
      }
    });
  }
}

/// ویجت داخلی نمایش Toast (بدون تغییر)
class _ToastWidget extends StatefulWidget {
  final ToastType type;
  final String message;
  final VoidCallback onDismissed;

  const _ToastWidget({
    required this.type,
    required this.message,
    required this.onDismissed,
  });

  @override
  State<_ToastWidget> createState() => _ToastWidgetState();
}

class _ToastWidgetState extends State<_ToastWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<Offset> _offsetAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0, 1.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOut));

    _controller.forward();

    Future.delayed(const Duration(milliseconds: 2500), () {
      if (mounted) {
        _controller.reverse();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Color _backgroundColor() {
    switch (widget.type) {
      case ToastType.warning:
        return const Color(0xffff9800);
      case ToastType.info:
        return const Color(0xff1291a7);
      case ToastType.danger:
        return const Color(0xffe53935);
    }
  }

  IconData _icon() {
    switch (widget.type) {
      case ToastType.warning:
        return Icons.warning_amber_rounded;
      case ToastType.info:
        return Icons.info_outline;
      case ToastType.danger:
        return Icons.error_outline;
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Positioned(
      left: 0,
      right: 0,
      bottom: bottomPadding + 24,
      child: SlideTransition(
        position: _offsetAnimation,
        child: Center(
          child: Material(
            color: Colors.transparent,
            child: Container(
              constraints: const BoxConstraints(maxWidth: 400),
              margin: const EdgeInsets.symmetric(horizontal: 20),
              padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              decoration: BoxDecoration(
                color: _backgroundColor(),
                borderRadius: BorderRadius.circular(14),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.25),
                    blurRadius: 12,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(_icon(), color: Colors.white, size: 22),
                  const SizedBox(width: 10),
                  Flexible(
                    child: Text(
                      widget.message,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 13,
                        fontWeight: FontWeight.w600,
                      ),
                      textAlign: TextAlign.right,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

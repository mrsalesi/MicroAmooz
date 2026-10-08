import 'package:http/browser_client.dart';
import 'package:http/http.dart' as http;

/// روی وب، باید withCredentials فعال باشد تا مرورگر اجازه بدهد
/// کوکی سشن (JSESSIONID) بین درخواست‌ها حفظ و ارسال شود.
/// توجه: جاوااسکریپت به هدر Set-Cookie دسترسی مستقیم ندارد (محدودیت امنیتی
/// مرورگرها)، پس مدیریت کوکی روی وب کاملاً به‌دست خود مرورگر سپرده می‌شود.
http.Client createPlatformClient() {
  final client = BrowserClient();
  client.withCredentials = true;
  return client;
}

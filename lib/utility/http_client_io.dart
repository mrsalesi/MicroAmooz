import 'package:http/http.dart' as http;

/// روی پلتفرم‌های غیر وب (اندروید، iOS، دسکتاپ)، یک کلاینت ساده‌ی http کافیست؛
/// مدیریت کوکی سشن به‌صورت دستی در Tools.dart انجام می‌شود (چون این پکیج
/// خودش کوکی را بین درخواست‌ها نگه نمی‌دارد).
http.Client createPlatformClient() {
  return http.Client();
}

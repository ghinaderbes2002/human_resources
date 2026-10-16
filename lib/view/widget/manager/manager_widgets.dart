// manager_widgets.dart
// عناصر واجهة مشتركة لشاشات الإدارة (بنفس هوية التطبيق)
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class MColors {
  static const primary = Color(0xFFE85D4A);
  static const primaryLight = Color(0xFFFF7A6B);
  static const background = Color(0xFFF8F9FA);
  static const textDark = Color(0xFF1A1A1A);
  static const text = Color(0xFF374151);
  static const textMuted = Color(0xFF6B7280);
  static const textLight = Color(0xFF9CA3AF);
  static const border = Color(0xFFE5E7EB);
  static const success = Color(0xFF10B981);
  static const danger = Color(0xFFEF4444);
  static const warning = Color(0xFFF59E0B);
  static const info = Color(0xFF3B82F6);
}

BoxDecoration mCardDecoration({double radius = 16}) => BoxDecoration(
      color: Colors.white,
      borderRadius: BorderRadius.circular(radius),
      boxShadow: [
        BoxShadow(
          color: Colors.black.withValues(alpha: 0.04),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );

/// هيكل صفحة إدارة: RTL + AppBar موحّد
class ManagerScaffold extends StatelessWidget {
  final String title;
  final Widget body;
  final List<Widget>? actions;
  final Widget? floatingActionButton;
  final PreferredSizeWidget? bottom;

  const ManagerScaffold({
    super.key,
    required this.title,
    required this.body,
    this.actions,
    this.floatingActionButton,
    this.bottom,
  });

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        backgroundColor: MColors.background,
        appBar: AppBar(
          title: Text(
            title,
            style: const TextStyle(
              fontWeight: FontWeight.w700,
              fontSize: 20,
              color: MColors.textDark,
            ),
          ),
          centerTitle: true,
          backgroundColor: Colors.white,
          surfaceTintColor: Colors.white,
          elevation: 0,
          iconTheme: const IconThemeData(color: MColors.textDark),
          actions: actions,
          bottom: bottom,
        ),
        floatingActionButton: floatingActionButton,
        body: body,
      ),
    );
  }
}

class MSectionTitle extends StatelessWidget {
  final String title;
  final Widget? trailing;
  const MSectionTitle(this.title, {super.key, this.trailing});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 4,
          height: 22,
          decoration: BoxDecoration(
            gradient: const LinearGradient(
              colors: [MColors.primary, MColors.primaryLight],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
            borderRadius: BorderRadius.circular(2),
          ),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            title,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w700,
              color: MColors.textDark,
            ),
          ),
        ),
        if (trailing != null) trailing!,
      ],
    );
  }
}

class MLoading extends StatelessWidget {
  const MLoading({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(40),
      child: Center(
        child: CircularProgressIndicator(color: MColors.primary, strokeWidth: 3),
      ),
    );
  }
}

/// حالة فارغة أو خطأ، مع زر إعادة محاولة اختياري
class MMessage extends StatelessWidget {
  final IconData icon;
  final String message;
  final Color color;
  final VoidCallback? onRetry;

  const MMessage({
    super.key,
    required this.icon,
    required this.message,
    this.color = MColors.textLight,
    this.onRetry,
  });

  const MMessage.empty(this.message, {super.key, this.icon = Icons.inbox_outlined})
      : color = MColors.textLight,
        onRetry = null;

  const MMessage.error(this.message, {super.key, this.onRetry})
      : icon = Icons.cloud_off_rounded,
        color = MColors.danger;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(vertical: 36, horizontal: 20),
      decoration: mCardDecoration(),
      child: Column(
        children: [
          Icon(icon, size: 52, color: color),
          const SizedBox(height: 12),
          Text(
            message,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w600,
              color: MColors.textMuted,
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(height: 12),
            TextButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh_rounded, color: MColors.primary),
              label: const Text('إعادة المحاولة',
                  style: TextStyle(color: MColors.primary)),
            ),
          ],
        ],
      ),
    );
  }
}

class MChip extends StatelessWidget {
  final String label;
  final Color color;
  final IconData? icon;
  const MChip(this.label, {super.key, required this.color, this.icon});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (icon != null) ...[
            Icon(icon, size: 13, color: color),
            const SizedBox(width: 4),
          ],
          Text(
            label,
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: color),
          ),
        ],
      ),
    );
  }
}

/// بطاقة إحصائية صغيرة (عدد + عنوان)
class MStatCard extends StatelessWidget {
  final String label;
  final String value;
  final Color color;
  final IconData icon;
  final VoidCallback? onTap;

  const MStatCard({
    super.key,
    required this.label,
    required this.value,
    required this.color,
    required this.icon,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: mCardDecoration(radius: 14),
        child: Row(
          children: [
            Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(value,
                      style: const TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w800,
                          color: MColors.textDark)),
                  Text(label,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 11, color: MColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

/// حقل بحث موحّد
class MSearchField extends StatelessWidget {
  final String hint;
  final ValueChanged<String> onChanged;
  final TextEditingController? controller;
  const MSearchField({super.key, required this.hint, required this.onChanged, this.controller});

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      onChanged: onChanged,
      decoration: InputDecoration(
        hintText: hint,
        prefixIcon: const Icon(Icons.search_rounded, color: MColors.textLight),
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(vertical: 12),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MColors.border),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MColors.border),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: MColors.primary),
        ),
      ),
    );
  }
}

/// تنسيق حقل إدخال في النماذج
InputDecoration mInputDecoration(String label, {String? hint, IconData? icon}) {
  return InputDecoration(
    labelText: label,
    hintText: hint,
    prefixIcon: icon != null ? Icon(icon, size: 20) : null,
    filled: true,
    fillColor: Colors.white,
    isDense: true,
    contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
    border: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MColors.border),
    ),
    enabledBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MColors.border),
    ),
    focusedBorder: OutlineInputBorder(
      borderRadius: BorderRadius.circular(12),
      borderSide: const BorderSide(color: MColors.primary, width: 1.5),
    ),
  );
}

/// نوافذ تأكيد وإشعارات
class MDialogs {
  static Future<bool> confirm({
    required String title,
    required String message,
    String confirmText = 'تأكيد',
    Color confirmColor = MColors.primary,
  }) async {
    // Navigator.pop بدلاً من Get.back حتى لا يُغلق snackbar ظاهر بدل النافذة
    final result = await Get.dialog<bool>(
      Builder(
        builder: (context) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            content: Text(message),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(false),
                child: const Text('إلغاء', style: TextStyle(color: MColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                ),
                onPressed: () => Navigator.of(context).pop(true),
                child: Text(confirmText),
              ),
            ],
          ),
        ),
      ),
    );
    return result ?? false;
  }

  /// نافذة إدخال نص (مثلاً سبب الرفض). تُرجع null عند الإلغاء.
  static Future<String?> prompt({
    required String title,
    required String label,
    bool required = false,
    String confirmText = 'حفظ',
    Color confirmColor = MColors.primary,
  }) async {
    final ctrl = TextEditingController();
    String? error;
    final result = await Get.dialog<String>(
      StatefulBuilder(
        builder: (context, setState) => Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
            title: Text(title, style: const TextStyle(fontWeight: FontWeight.w700)),
            content: TextField(
              controller: ctrl,
              maxLines: 3,
              decoration: mInputDecoration(label).copyWith(errorText: error),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('إلغاء', style: TextStyle(color: MColors.textMuted)),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: confirmColor,
                  foregroundColor: Colors.white,
                ),
                onPressed: () {
                  if (required && ctrl.text.trim().isEmpty) {
                    setState(() => error = 'هذا الحقل مطلوب');
                    return;
                  }
                  Navigator.of(context).pop(ctrl.text.trim());
                },
                child: Text(confirmText),
              ),
            ],
          ),
        ),
      ),
    );
    return result;
  }

  static void success(String message) => _snack('تم', message, MColors.success);
  static void error(String message) => _snack('خطأ', message, MColors.danger);

  static void _snack(String title, String message, Color color) {
    Get.snackbar(
      title,
      message,
      snackPosition: SnackPosition.BOTTOM,
      backgroundColor: color,
      colorText: Colors.white,
      margin: const EdgeInsets.all(16),
      borderRadius: 12,
      duration: const Duration(seconds: 3),
    );
  }
}

/// أدوات تنسيق
class MFormat {
  static String date(DateTime d) =>
      '${d.year}-${d.month.toString().padLeft(2, '0')}-${d.day.toString().padLeft(2, '0')}';

  /// "08:05:00.1234" -> "08:05"
  static String time(String? t) {
    if (t == null || t.isEmpty || t == 'None') return '--:--';
    final clean = t.contains('T') ? t.split('T').last : t;
    final parts = clean.split(':');
    if (parts.length < 2) return clean;
    return '${parts[0].padLeft(2, '0')}:${parts[1].padLeft(2, '0')}';
  }

  static String timeOfDay(TimeOfDay t) =>
      '${t.hour.toString().padLeft(2, '0')}:${t.minute.toString().padLeft(2, '0')}:00';

  /// أخذ جزء التاريخ من نص ISO
  static String dateOnly(String? s) {
    if (s == null || s.isEmpty) return '-';
    return s.length >= 10 ? s.substring(0, 10) : s;
  }

  static String money(num? v) {
    if (v == null) return '-';
    final s = v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toStringAsFixed(2);
    return '$s ج.م';
  }
}

double? mToDouble(dynamic v) {
  if (v == null) return null;
  if (v is num) return v.toDouble();
  return double.tryParse(v.toString());
}

int? mToInt(dynamic v) {
  if (v == null) return null;
  if (v is int) return v;
  if (v is num) return v.toInt();
  return int.tryParse(v.toString());
}

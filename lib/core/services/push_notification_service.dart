// push_notification_service.dart
// الإشعارات الفورية عبر Firebase Cloud Messaging
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:get/get.dart';
import 'package:human_resources/controller/manager/transaction_manager_controller.dart';
import 'package:human_resources/controller/performance_controller.dart';
import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/core/constant/App_routes.dart';
import 'package:human_resources/core/services/user_session.dart';
import 'package:human_resources/view/screen/manager/transactions/TransactionDetailPage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// معالج الرسائل في الخلفية (يجب أن يكون دالة على المستوى الأعلى).
/// النظام يعرض الإشعار تلقائياً لأن الرسالة تحتوي على notification.
@pragma('vm:entry-point')
Future<void> firebaseBackgroundHandler(RemoteMessage message) async {}

class PushNotificationService with WidgetsBindingObserver {
  PushNotificationService._();
  static final PushNotificationService instance = PushNotificationService._();

  static const _channel = AndroidNotificationChannel(
    'hr_notifications', // نفس القيمة في AndroidManifest والباك
    'إشعارات الموارد البشرية',
    description: 'إشعارات المعاملات والطلبات',
    importance: Importance.high,
  );

  final _local = FlutterLocalNotificationsPlugin();
  final _messaging = FirebaseMessaging.instance;
  bool _initialized = false;
  bool _loggingOut = false;

  /// عدد الإشعارات غير المقروءة (تستمع له أيقونة الجرس)
  final ValueNotifier<int> unreadCount = ValueNotifier<int>(0);

  /// يُستدعى مرة واحدة عند تشغيل التطبيق
  Future<void> init() async {
    if (_initialized) return;
    _initialized = true;

    await _local.initialize(
      settings: const InitializationSettings(
        android: AndroidInitializationSettings('@mipmap/ic_launcher'),
        iOS: DarwinInitializationSettings(),
      ),
      onDidReceiveNotificationResponse: (resp) => _openPayload(resp.payload),
    );

    await _local
        .resolvePlatformSpecificImplementation<
            AndroidFlutterLocalNotificationsPlugin>()
        ?.createNotificationChannel(_channel);

    // iOS: إظهار الإشعار حتى والتطبيق مفتوح
    await _messaging.setForegroundNotificationPresentationOptions(
      alert: true,
      badge: true,
      sound: true,
    );

    // التطبيق مفتوح: نعرض الإشعار محلياً على أندرويد ونحدّث العداد
    FirebaseMessaging.onMessage.listen((m) {
      _showForeground(m);
      refreshUnreadCount();
    });

    // الضغط على الإشعار والتطبيق في الخلفية
    FirebaseMessaging.onMessageOpenedApp.listen((m) => openTarget(m.data));

    // تحديث الرمز تلقائياً
    _messaging.onTokenRefresh.listen((t) => _sendToken(t));

    // تحديث العداد عند العودة للتطبيق
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) refreshUnreadCount();
  }

  Future<void> refreshUnreadCount() async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) return;
    final res = await ManagerApi.instance.get('/notifications/unread-count');
    if (res.ok && res.data is Map) {
      unreadCount.value = (res.data['unread_count'] as num?)?.toInt() ?? 0;
    }
  }

  /// يُستدعى بعد تسجيل الدخول وعند فتح التطبيق والمستخدم مسجّل
  Future<void> registerDevice() async {
    _loggingOut = false;
    try {
      final settings = await _messaging.requestPermission(
        alert: true,
        badge: true,
        sound: true,
      );
      if (settings.authorizationStatus == AuthorizationStatus.denied) return;

      final token = await _messaging.getToken();
      if (token != null) await _sendToken(token);
    } catch (e) {
      debugPrint('FCM register error: $e');
    }
    refreshUnreadCount();
  }

  /// يُستدعى قبل تسجيل الخروج (قبل حذف التوكن من التخزين).
  /// محدود بمهلة قصيرة حتى لا يتأخر تسجيل الخروج إذا لم يتوفر اتصال.
  Future<void> unregisterDevice() async {
    _loggingOut = true;
    unreadCount.value = 0;
    try {
      await () async {
        final token = await _messaging.getToken();
        if (token != null) {
          await ManagerApi.instance.delete(
            '/notifications/device-token',
            body: {'token': token},
          );
        }
        await _messaging.deleteToken();
      }()
          .timeout(const Duration(seconds: 5));
    } catch (e) {
      debugPrint('FCM unregister error: $e');
    }
  }

  /// فتح الشاشة المناسبة إذا فُتح التطبيق من إشعار وهو مغلق تماماً.
  /// يُستدعى من الشاشة الرئيسية بعد بنائها.
  Future<void> handleInitialMessage() async {
    final message = await _messaging.getInitialMessage();
    if (message != null) {
      await openTarget(message.data);
      return;
    }
    // إشعار محلي (عُرض والتطبيق مفتوح) ثم ضُغط بعد إغلاق التطبيق
    final details = await _local.getNotificationAppLaunchDetails();
    if (details?.didNotificationLaunchApp == true) {
      _openPayload(details!.notificationResponse?.payload);
    }
  }

  Future<void> _sendToken(String token) async {
    if (_loggingOut) return;
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) return; // غير مسجّل دخول
    await ManagerApi.instance.post(
      '/notifications/device-token',
      body: {'token': token, 'platform': Platform.isIOS ? 'ios' : 'android'},
    );
  }

  void _showForeground(RemoteMessage message) {
    final n = message.notification;
    if (n == null || Platform.isIOS) return; // iOS يعرضه النظام
    _local.show(
      id: message.hashCode,
      title: n.title,
      body: n.body,
      notificationDetails: NotificationDetails(
        android: AndroidNotificationDetails(
          _channel.id,
          _channel.name,
          channelDescription: _channel.description,
          importance: Importance.high,
          priority: Priority.high,
          styleInformation: BigTextStyleInformation(n.body ?? ''),
        ),
      ),
      payload: jsonEncode(message.data),
    );
  }

  void _openPayload(String? payload) {
    Map<String, dynamic> data = {};
    try {
      data = jsonDecode(payload ?? '{}') as Map<String, dynamic>;
    } catch (_) {}
    openTarget(data);
  }

  /// فتح الشاشة المناسبة للإشعار حسب نوعه (يُستخدم أيضاً من شاشة الإشعارات)
  static Future<void> openTarget(Map<String, dynamic> data) async {
    final prefs = await SharedPreferences.getInstance();
    if (prefs.getString('token') == null) return; // غير مسجّل دخول

    // تعليم الإشعار كمقروء عند فتحه من الإشعار الفوري
    final notificationId = int.tryParse(data['notification_id']?.toString() ?? '');
    if (notificationId != null) {
      ManagerApi.instance
          .put('/notifications/$notificationId/read')
          .then((_) => instance.refreshUnreadCount());
    }

    final entityType = data['entity_type']?.toString();
    final entityId = int.tryParse(data['entity_id']?.toString() ?? '');

    switch (entityType) {
      case 'transaction':
        final session = await UserSession.load();
        if (entityId != null && session.isManager) {
          // المدير: تفاصيل المعاملة مباشرة
          if (Get.isRegistered<TransactionManagerController>()) {
            // شاشة المعاملات مفتوحة أصلاً: نفتح التفاصيل فوقها
            Get.to(() => TransactionDetailPage(transactionId: entityId));
          } else {
            Get.toNamed(
              AppRoute.transactionsManagement,
              arguments: {'openTransactionId': entityId},
            );
          }
        } else {
          _goTo(AppRoute.transactionScreen);
        }
        break;
      case 'kpi_summary':
        final year = int.tryParse(data['year']?.toString() ?? '');
        final month = int.tryParse(data['month']?.toString() ?? '');
        if (Get.isRegistered<PerformanceController>() && year != null && month != null) {
          // شاشة التقييم مفتوحة أصلاً: ننتقل للشهر المطلوب
          Get.find<PerformanceController>().openMonth(year, month);
        } else {
          Get.toNamed(
            AppRoute.myPerformance,
            arguments: {'year': year, 'month': month},
          );
        }
        break;
      case 'leave':
      case 'advance':
        _goTo(AppRoute.transactionScreen);
        break;
      default:
        // مكافأة، جزاء، غياب، وغيرها
        _goTo(AppRoute.notifications);
    }
  }

  /// الانتقال لشاشة إلا إذا كانت هي المفتوحة حالياً
  static void _goTo(String route) {
    if (Get.currentRoute != route) Get.toNamed(route);
  }
}

// notifications_controller.dart
import 'package:get/get.dart';
import 'package:human_resources/core/classes/manager_api.dart';
import 'package:human_resources/core/classes/staterequest.dart';
import 'package:human_resources/core/services/push_notification_service.dart';

class AppNotification {
  final int id;
  final String title;
  final String message;
  final String type;
  final String priority;
  bool isRead;
  final String? entityType;
  final int? entityId;
  final Map<String, dynamic> extraData;
  final DateTime? createdAt;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.type,
    required this.priority,
    required this.isRead,
    this.entityType,
    this.entityId,
    this.extraData = const {},
    this.createdAt,
  });

  /// بيانات فتح الشاشة المرتبطة (نفس صيغة بيانات الإشعار الفوري)
  Map<String, dynamic> get target => {
        ...extraData,
        'entity_type': entityType,
        'entity_id': entityId,
      };

  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'] ?? 0,
      title: json['title'] ?? '',
      message: json['message'] ?? '',
      type: json['notification_type'] ?? 'general',
      priority: json['priority'] ?? 'medium',
      isRead: json['is_read'] ?? false,
      entityType: json['entity_type'],
      entityId: json['entity_id'],
      extraData: json['extra_data'] is Map
          ? Map<String, dynamic>.from(json['extra_data'])
          : const {},
      createdAt: DateTime.tryParse(json['created_at'] ?? ''),
    );
  }
}

class NotificationsController extends GetxController {
  final _api = ManagerApi.instance;

  Staterequest staterequest = Staterequest.none;
  List<AppNotification> items = [];
  String? errorMessage;

  int get unreadCount => items.where((n) => !n.isRead).length;

  @override
  void onInit() {
    super.onInit();
    fetch();
  }

  Future<void> fetch() async {
    staterequest = Staterequest.loading;
    update();

    final res = await _api.get('/notifications', query: {'limit': 100});
    if (res.ok && res.data is Map) {
      items = ((res.data['notifications'] ?? []) as List)
          .map((e) => AppNotification.fromJson(e))
          .toList();
      staterequest = Staterequest.success;
    } else {
      errorMessage = res.messageOr('فشل تحميل الإشعارات');
      staterequest = Staterequest.failure;
    }
    update();
  }

  Future<void> markRead(AppNotification n) async {
    if (n.isRead) return;
    n.isRead = true;
    update();
    await _api.put('/notifications/${n.id}/read');
    PushNotificationService.instance.refreshUnreadCount();
  }

  Future<void> markAllRead() async {
    for (final n in items) {
      n.isRead = true;
    }
    update();
    await _api.put('/notifications/mark-all-read');
    PushNotificationService.instance.refreshUnreadCount();
  }

  Future<void> remove(AppNotification n) async {
    items.remove(n);
    update();
    await _api.delete('/notifications/${n.id}');
    PushNotificationService.instance.refreshUnreadCount();
  }
}

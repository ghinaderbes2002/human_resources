import 'package:get/get.dart';
import 'package:human_resources/core/services/SharedPreferences.dart';

class ServerConfig {
  static final ServerConfig _instance = ServerConfig._internal();
  factory ServerConfig() => _instance;
  ServerConfig._internal();

  static const String _key = "server_link";
  String _serverLink =
      // "http://38.242.132.87:3001/api"; 
      //"http://10.90.234.51:5000/api"; 
      "http://192.168.74.15:3000/api"; 

  String get serverLink => _serverLink;

  Future<void> loadServerLink() async {
    final myServices = Get.find<MyServices>();
    final savedLink = myServices.sharedPref.getString(_key);
    if (savedLink != null && savedLink.isNotEmpty) {
      _serverLink = savedLink;
    }
  }

  // Future<void> updateServerLink(String newLink) async {
  //   _serverLink = newLink;
  //   final myServices = Get.find<MyServices>();
  //   await myServices.sharedPref.setString(_key, newLink);
  // }

  // Future<void> resetToDefault() async {
  //   _serverLink = "http://192.168.74.4:5000/api";
  //   final myServices = Get.find<MyServices>();
  //   await myServices.sharedPref.setString(_key, _serverLink);
  // }
}

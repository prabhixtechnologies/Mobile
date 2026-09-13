import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:prabhix_api_core/prabhix_api_core.dart';

class PushRegistration {
  static Future<void> register(ApiClient api) async {
    try {
      if (Firebase.apps.isEmpty) {
        await Firebase.initializeApp();
      }
      final messaging = FirebaseMessaging.instance;
      await messaging.requestPermission();
      final token = await messaging.getToken();
      if (token == null || token.isEmpty) return;
      await api.registerPushToken(token: token);
    } catch (e) {
      debugPrint('MobiStack push skipped: $e');
    }
  }
}

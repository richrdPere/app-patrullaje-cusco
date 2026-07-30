import 'dart:async';

import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';

typedef FcmTokenChanged = Future<void> Function(String token);

class FirebaseMessagingService {
  FirebaseMessagingService._();

  static final FirebaseMessagingService instance = FirebaseMessagingService._();

  final FirebaseMessaging _messaging = FirebaseMessaging.instance;

  StreamSubscription<String>? _tokenSubscription;

  String? _currentToken;

  String? get currentToken => _currentToken;

  Future<void> initialize({required FcmTokenChanged onTokenChanged}) async {
    await _requestPermission();

    await _registerInitialToken(onTokenChanged);

    _listenTokenRefresh(onTokenChanged);
  }

  Future<void> _requestPermission() async {
    final settings = await _messaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
      announcement: false,
      carPlay: false,
      criticalAlert: false,
      provisional: false,
    );

    debugPrint('Permiso FCM: ${settings.authorizationStatus}');
  }

  Future<void> _registerInitialToken(FcmTokenChanged onTokenChanged) async {
    try {
      final token = await _messaging.getToken();

      if (token == null || token.isEmpty) {
        debugPrint('FCM no devolvió un token.');
        return;
      }

      _currentToken = token;

      debugPrint('Token FCM inicial: $token');

      await onTokenChanged(token);
    } catch (error, stackTrace) {
      debugPrint(
        'Error obteniendo el token FCM: '
        '$error\n$stackTrace',
      );
    }
  }

  void _listenTokenRefresh(FcmTokenChanged onTokenChanged) {
    _tokenSubscription?.cancel();

    _tokenSubscription = _messaging.onTokenRefresh.listen(
      (token) async {
        _currentToken = token;

        debugPrint('Token FCM renovado: $token');

        try {
          await onTokenChanged(token);
        } catch (error, stackTrace) {
          debugPrint(
            'Error registrando token renovado: '
            '$error\n$stackTrace',
          );
        }
      },
      onError: (Object error, StackTrace stackTrace) {
        debugPrint(
          'Error escuchando renovación FCM: '
          '$error\n$stackTrace',
        );
      },
    );
  }

  Future<String?> refreshToken() async {
    final token = await _messaging.getToken();
    _currentToken = token;
    return token;
  }

  Future<void> deleteToken() async {
    await _messaging.deleteToken();
    _currentToken = null;
  }

  Future<void> dispose() async {
    await _tokenSubscription?.cancel();
  }
}

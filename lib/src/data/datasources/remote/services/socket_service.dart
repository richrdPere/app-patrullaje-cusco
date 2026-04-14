// ignore_for_file: unnecessary_this, constant_identifier_names

import 'package:flutter/material.dart';

import 'package:socket_io_client/socket_io_client.dart' as IO;

// Environment
import 'package:sis_patrullaje_cusco/src/config/constants/environment.dart'
    as url_socket;

enum ServerStatus { Online, Offline, Connecting }

class SocketService with ChangeNotifier {
  ServerStatus _serverStatus = ServerStatus.Connecting;
  late IO.Socket _socket;

  ServerStatus get serverStatus => this._serverStatus;

  IO.Socket get socket => this._socket;
  Function get emit => this._socket.emit;

  void connent() {
    // Dart client
    this._socket = IO.io(url_socket.Environment.socketUrl, {
      'transports': ['websocket'],
      'autoConnect': true,
      'forceNew': true,
    });

    this._socket.on('connect', (_) {
      this._serverStatus = ServerStatus.Online;
      notifyListeners();
    });

    this._socket.on('disconnect', (_) {
      this._serverStatus = ServerStatus.Offline;
      notifyListeners();
    });
  }

  void disconnet() {
    this._socket.disconnect();
  }
}

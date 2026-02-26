import 'dart:convert';
import 'package:stomp_dart_client/stomp.dart';
import 'package:stomp_dart_client/stomp_config.dart';
import 'package:stomp_dart_client/stomp_frame.dart';

class LiveScoreSocket {
  StompClient? _client;

  void connect({
    required String tournamentId,   // ⭐ add
    required String matchId,
    required Function(Map<String, dynamic>) onData,
  }) {
    _client = StompClient(
      config: StompConfig.SockJS(
        url: "http://127.0.0.1:8080/ws",
        onConnect: (frame) {
          print("WS CONNECTED");

          // subscribe for updates
          _client!.subscribe(
            destination: '/topic/live-score/$matchId',
            callback: (frame) {
              final body = frame.body;
              if (body == null || body.isEmpty) return;

              print("WS DATA: $body");
              onData(json.decode(body));
            },
          );

          // request snapshot
          _client!.send(
            destination: '/app/live-score/$tournamentId/$matchId',
            body: '',
          );
        },
        onStompError: (f) => print("STOMP ERROR ${f.body}"),
        onWebSocketError: (e) => print("WS ERROR $e"),
        onDisconnect: (_) => print("WS DISCONNECTED"),
      ),
    );

    _client!.activate();
  }

  void disconnect() => _client?.deactivate();
}
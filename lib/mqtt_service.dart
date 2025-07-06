import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';

class MqttService {
  final String server = 'mqtt-dashboard.com';
  final String clientIdentifier;
  MqttServerClient? client;
  final StreamController<String> _locationStreamController =
      StreamController<String>.broadcast();

  Stream<String> get locationStream => _locationStreamController.stream;

  MqttService({required this.clientIdentifier});

  Future<void> connect() async {
    client = MqttServerClient(server, clientIdentifier);

    if (kIsWeb) {
      client!.port = 8884;
      client!.secure = true;
      client!.useWebSocket = true;
    } else {
      client!.port = 1883;
    }

    client!.logging(on: true);
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean();

    print('MQTT_LOGS::Mensagem de conexão criada, tentando conectar...');
    client!.connectionMessage = connMessage;

    try {
      await client!.connect().timeout(const Duration(seconds: 10));
    } catch (e) {
      print('MQTT_LOGS::EXCEPTION ao conectar: $e');
      client!.disconnect();
    }
  }

  void onConnected() {
    print('MQTT_LOGS::CALLBACK - Conectado com sucesso!');
  }

  void onDisconnected() {
    print('MQTT_LOGS::CALLBACK - Desconectado!');
  }

  void subscribeToTopic(String topic) {
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.subscribe(topic, MqttQos.atMostOnce);
      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);
        _locationStreamController.add(payload);
      });
    }
  }

  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('MQTT_LOGS:: Mensagem "$message" publicada no tópico "$topic"');
    }
  }

  void disconnect() {
    if (client != null) {
      client!.disconnect();
    }
  }
}

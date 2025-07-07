import 'package:flutter/foundation.dart';
import 'package:mqtt_client/mqtt_client.dart';
import 'package:mqtt_client/mqtt_server_client.dart';
import 'dart:async';

class MqttService {
  // ALTERADO: Usando o broker público do Mosquitto
  final String server = 'test.mosquitto.org';
  final String clientIdentifier;
  MqttServerClient? client;
  final StreamController<String> _locationStreamController =
      StreamController<String>.broadcast();

  Stream<String> get locationStream => _locationStreamController.stream;

  MqttService({required this.clientIdentifier});

  Future<void> connect() async {
    client = MqttServerClient(server, clientIdentifier);

    // Configuração de conexão baseada na plataforma
    if (kIsWeb) {
      // ALTERADO: Configurações para Web (WS - WebSocket não seguro)
      client!.port = 8080; // Porta de WebSocket do Mosquitto
      client!.useWebSocket = true;
      print('MQTT_LOGS:: Usando WebSockets no host $server porta 8080.');
    } else {
      // Configurações para Mobile (TCP padrão)
      client!.port = 1883;
    }

    // Configurações gerais e de log
    client!.logging(on: true);
    client!.onConnected = onConnected;
    client!.onDisconnected = onDisconnected;

    final connMessage = MqttConnectMessage()
        .withClientIdentifier(clientIdentifier)
        .startClean();

    print(
        'MQTT_LOGS::Mensagem de conexão criada, tentando conectar ao Mosquitto...');
    client!.connectionMessage = connMessage;

    try {
      await client!.connect().timeout(const Duration(seconds: 15));
    } catch (e) {
      print('MQTT_LOGS::EXCEPTION ao conectar: $e');
      client!.disconnect();
    }
  }

  // Callbacks para logar o status da conexão
  void onConnected() {
    print('MQTT_LOGS::CALLBACK - Conectado com sucesso ao Mosquitto!');
  }

  void onDisconnected() {
    print('MQTT_LOGS::CALLBACK - Desconectado!');
  }

  // Método para se inscrever em um tópico e receber mensagens
  void subscribeToTopic(String topic) {
    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      print('MQTT_LOGS:: Inscrevendo-se no tópico $topic');
      client!.subscribe(topic, MqttQos.atMostOnce);

      client!.updates!.listen((List<MqttReceivedMessage<MqttMessage?>>? c) {
        final recMess = c![0].payload as MqttPublishMessage;
        final payload =
            MqttPublishPayload.bytesToStringAsString(recMess.payload.message);

        _locationStreamController.add(payload);
        print(
            'MQTT_LOGS:: Mensagem recebida: $payload do tópico: ${c[0].topic}>');
      });
    }
  }

  // Método para publicar uma mensagem
  void publishMessage(String topic, String message) {
    final builder = MqttClientPayloadBuilder();
    builder.addString(message);

    if (client != null &&
        client!.connectionStatus!.state == MqttConnectionState.connected) {
      client!.publishMessage(topic, MqttQos.atMostOnce, builder.payload!);
      print('MQTT_LOGS:: Mensagem "$message" publicada no tópico "$topic"');
    } else {
      print('MQTT_LOGS:: Cliente não conectado. Não foi possível publicar.');
    }
  }

  // Método para desconectar
  void disconnect() {
    print('MQTT_LOGS:: Desconectando...');
    if (client != null) {
      client!.disconnect();
    }
  }
}

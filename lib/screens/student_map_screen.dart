import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:mqtt_client/mqtt_client.dart';

import '../auth_provider.dart';
import '../mqtt_service.dart';

class StudentMapScreen extends StatefulWidget {
  @override
  _StudentMapScreenState createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  late MqttService mqttService;
  StreamSubscription? mqttSubscription;

  final LatLng _mapCenter = LatLng(-22.9068, -43.1729);
  LatLng? _busPosition;

  @override
  void initState() {
    super.initState();
    _setupMqtt();
  }

  void _setupMqtt() async {
    final clientId = 'student-${DateTime.now().millisecondsSinceEpoch}';
    mqttService = MqttService(clientIdentifier: clientId);
    await mqttService.connect();

    if (mounted &&
        mqttService.client?.connectionStatus?.state ==
            MqttConnectionState.connected) {
      const topic = 'uff/onibus/UFF-01/localizacao';
      mqttService.subscribeToTopic(topic);

      mqttSubscription =
          mqttService.locationStream.listen((String locationData) {
        final parts = locationData.split(',');
        if (parts.length == 2) {
          final lat = double.tryParse(parts[0]);
          final lng = double.tryParse(parts[1]);

          if (lat != null && lng != null) {
            if (mounted) {
              setState(() {
                _busPosition = LatLng(lat, lng);
              });
            }
          }
        }
      });
    }
  }

  @override
  void dispose() {
    mqttSubscription?.cancel();
    mqttService.disconnect();
    super.dispose();
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    // A linha abaixo pode causar erro se a rota for acessada sem argumentos.
    // Em um app real, teríamos um tratamento de erro melhor aqui.
    final routeName = ModalRoute.of(context)?.settings.arguments as String? ??
        "Rota Desconhecida";

    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoramento da Rota'),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text('Sair', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          _buildInfoPanel(routeName),
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _mapCenter,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.buss_temporeal',
                ),
                if (_busPosition != null)
                  MarkerLayer(
                    markers: [
                      Marker(
                        width: 80.0,
                        height: 80.0,
                        point: _busPosition!,
                        child: Icon(Icons.directions_bus,
                            color: Colors.green, size: 40),
                      ),
                    ],
                  ),
              ],
            ),
          ),
          _buildStopsPanel(),
        ],
      ),
    );
  }

  // --- MÉTODOS DE UI QUE ESTAVAM FALTANDO ---

  Widget _buildInfoPanel(String routeName) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(routeName,
                      style:
                          TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                  Text('Ônibus UFF-01',
                      style: TextStyle(color: Colors.grey[600])),
                ],
              ),
              Chip(
                label: Text('ONLINE'),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(color: Colors.green.shade800),
              )
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoMetric('~', 'até próxima parada'),
              _buildInfoMetric('~', 'ocupação'),
              _buildInfoMetric('~', 'chegada estimada'),
            ],
          )
        ],
      ),
    );
  }

  Widget _buildInfoMetric(String value, String label) {
    return Column(
      children: [
        Text(value,
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        Text(label, style: TextStyle(color: Colors.grey[600], fontSize: 12)),
      ],
    );
  }

  Widget _buildStopsPanel() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('Próximas Paradas',
              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
          SizedBox(height: 12),
          _buildStopItem('1', 'Terminal Centro', 'Horário indisponível',
              isActive: true),
          SizedBox(height: 8),
          _buildStopItem('2', 'Ponto da Rua XV', 'Horário indisponível',
              isActive: false),
        ],
      ),
    );
  }

  Widget _buildStopItem(String number, String name, String eta,
      {bool isActive = false}) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isActive ? Colors.blue : Colors.grey[400],
            child: Text(number,
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.bold)),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
              Text(eta,
                  style: TextStyle(color: Colors.grey[700], fontSize: 12)),
            ],
          ),
        ],
      ),
    );
  }
}

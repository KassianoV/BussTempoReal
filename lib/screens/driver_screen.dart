import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:provider/provider.dart';
import 'package:geolocator/geolocator.dart';

import '../auth_provider.dart';
import '../mqtt_service.dart';

class DriverScreen extends StatefulWidget {
  @override
  _DriverScreenState createState() => _DriverScreenState();
}

class _DriverScreenState extends State<DriverScreen> {
  late MqttService mqttService;

  // Revertido: Removemos a variável _isMqttConnected
  bool _isSharing = false;

  LatLng? _currentPosition;
  StreamSubscription<Position>? _positionStreamSubscription;

  @override
  void initState() {
    super.initState();
    _setupMqtt(); // A configuração do MQTT continua aqui
    _determinePosition();
  }

  // A configuração do MQTT continua a mesma, mas não atualiza mais o estado da UI
  void _setupMqtt() async {
    final clientId = 'driver-UFF-01-${DateTime.now().millisecondsSinceEpoch}';
    mqttService = MqttService(clientIdentifier: clientId);
    await mqttService.connect();
    // A verificação do status e o setState foram removidos daqui
  }

  Future<void> _determinePosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled)
      return Future.error('Serviços de localização desabilitados.');

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied)
        return Future.error('Permissão de localização foi negada.');
    }

    if (permission == LocationPermission.deniedForever)
      return Future.error('Permissão de localização negada permanentemente.');

    Position position = await Geolocator.getCurrentPosition();
    if (mounted) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
      });
    }
  }

  @override
  void dispose() {
    _positionStreamSubscription?.cancel();
    mqttService.disconnect();
    super.dispose();
  }

  void _toggleSharing() {
    // A lógica de publicação agora não verifica mais se o MQTT está conectado,
    // ela simplesmente tenta publicar. O status da conexão veremos no console.
    if (!_isSharing) {
      final locationSettings = LocationSettings(
        accuracy: LocationAccuracy.high,
        distanceFilter: 10,
      );
      _positionStreamSubscription =
          Geolocator.getPositionStream(locationSettings: locationSettings)
              .listen((Position position) {
        if (mounted) {
          setState(() {
            _currentPosition = LatLng(position.latitude, position.longitude);
          });
        }

        const topic = 'uff/onibus/UFF-01/localizacao';
        final message = '${position.latitude},${position.longitude}';
        mqttService.publishMessage(topic, message);
      });
    } else {
      _positionStreamSubscription?.cancel();
    }

    if (mounted) {
      setState(() {
        _isSharing = !_isSharing;
      });
    }
  }

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Modo Motorista'),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text('Sair', style: TextStyle(color: Colors.white)),
          )
        ],
      ),
      body: Column(
        children: [
          ListTile(
            leading: CircleAvatar(child: Text('🚌')),
            title: Text('Ônibus UFF-01',
                style: TextStyle(fontWeight: FontWeight.bold)),
            subtitle: Text('Placa: ABC1D23'),
          ),
          Expanded(
            child: _currentPosition == null
                ? Center(child: CircularProgressIndicator())
                : FlutterMap(
                    options: MapOptions(
                      initialCenter: _currentPosition!,
                      initialZoom: 17.0,
                    ),
                    children: [
                      TileLayer(
                        urlTemplate:
                            'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                        userAgentPackageName: 'com.example.buss_temporeal',
                      ),
                      MarkerLayer(
                        markers: [
                          Marker(
                            width: 80.0,
                            height: 80.0,
                            point: _currentPosition!,
                            child: Icon(Icons.directions_bus,
                                color: Colors.blue, size: 40),
                          ),
                        ],
                      ),
                    ],
                  ),
          ),
          // Revertido: Painel inferior sem o texto de status e com o botão sempre ativo
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Compartilhamento de Localização',
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    Chip(
                      label: Text(_isSharing ? 'ATIVO' : 'INATIVO'),
                      backgroundColor: _isSharing
                          ? Colors.green.shade100
                          : Colors.red.shade100,
                      labelStyle: TextStyle(
                          color: _isSharing
                              ? Colors.green.shade800
                              : Colors.red.shade800),
                    ),
                  ],
                ),
                SizedBox(height: 8),
                Text(
                    'Ative para compartilhar sua localização em tempo real com os alunos.'),
                SizedBox(height: 16),
                ElevatedButton(
                  onPressed: _toggleSharing, // Botão sempre ativo
                  child: Text(_isSharing
                      ? 'Desativar Compartilhamento'
                      : 'Ativar Compartilhamento'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: _isSharing
                        ? Colors.green
                        : Colors.red, // A cor só depende do _isSharing
                    foregroundColor: Colors.white,
                    padding: EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

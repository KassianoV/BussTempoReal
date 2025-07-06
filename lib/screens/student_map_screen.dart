import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart'; // 1. Importe o flutter_map
import 'package:latlong2/latlong.dart'; // 2. Importe o latlong2
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class StudentMapScreen extends StatefulWidget {
  @override
  _StudentMapScreenState createState() => _StudentMapScreenState();
}

class _StudentMapScreenState extends State<StudentMapScreen> {
  // Posição inicial simulada
  final LatLng _initialPosition = LatLng(-22.9068, -43.1729);

  // Marcador do ônibus que seria atualizado via MQTT
  final Marker _busMarker = Marker(
    width: 80.0,
    height: 80.0,
    point: LatLng(-22.9068, -43.1729), // Posição inicial
    child: Icon(Icons.directions_bus, color: Colors.green, size: 40),
  );

  void _logout() {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushNamedAndRemoveUntil('/', (route) => false);
  }

  @override
  Widget build(BuildContext context) {
    final routeName = ModalRoute.of(context)!.settings.arguments as String;

    return Scaffold(
      appBar: AppBar(
        title: Text('Monitoramento da Rota'),
        actions: [
          TextButton(
            onPressed: _logout,
            child: Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Column(
        children: [
          _buildInfoPanel(routeName),
          // 3. Substitua o GoogleMap pelo FlutterMap
          Expanded(
            child: FlutterMap(
              options: MapOptions(
                initialCenter: _initialPosition,
                initialZoom: 14,
              ),
              children: [
                TileLayer(
                  urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                  userAgentPackageName: 'com.example.buss_temporeal',
                ),
                // Camada de Marcadores
                MarkerLayer(
                  markers: [_busMarker], // Exibe o marcador do ônibus
                ),
              ],
            ),
          ),
          _buildStopsPanel(),
        ],
      ),
    );
  }

  // O resto do código (_buildInfoPanel, _buildStopsPanel, etc.) continua o mesmo.
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
                  Text(
                    routeName,
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  Text(
                    'Ônibus UFF-01',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                ],
              ),
              Chip(
                label: Text('ONLINE'),
                backgroundColor: Colors.green.shade100,
                labelStyle: TextStyle(color: Colors.green.shade800),
              ),
            ],
          ),
          SizedBox(height: 16),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildInfoMetric('2 min', 'até próxima parada'),
              _buildInfoMetric('68%', 'ocupação'),
              _buildInfoMetric('8:25', 'chegada estimada'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildInfoMetric(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
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
          Text(
            'Próximas Paradas',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          SizedBox(height: 12),
          _buildStopItem(
            '1',
            'Terminal Centro',
            'Chegando em 2 min',
            isActive: true,
          ),
          SizedBox(height: 8),
          _buildStopItem(
            '2',
            'Ponto da Rua XV',
            'Chegando em 8 min',
            isActive: false,
          ),
        ],
      ),
    );
  }

  Widget _buildStopItem(
    String number,
    String name,
    String eta, {
    bool isActive = false,
  }) {
    return Opacity(
      opacity: isActive ? 1.0 : 0.6,
      child: Row(
        children: [
          CircleAvatar(
            radius: 16,
            backgroundColor: isActive ? Colors.blue : Colors.grey[400],
            child: Text(
              number,
              style: TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(name, style: TextStyle(fontWeight: FontWeight.w600)),
              Text(
                eta,
                style: TextStyle(color: Colors.grey[700], fontSize: 12),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

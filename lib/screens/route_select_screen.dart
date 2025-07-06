import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../auth_provider.dart';

class RouteSelectScreen extends StatelessWidget {
  void _selectRoute(BuildContext context, String routeName) {
    // Passa o nome da rota para a próxima tela
    Navigator.of(context).pushNamed('/student-map', arguments: routeName);
  }

  void _logout(BuildContext context) {
    Provider.of<AuthProvider>(context, listen: false).logout();
    Navigator.of(context).pushReplacementNamed('/');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Selecione sua Rota'),
        actions: [
          TextButton(
            onPressed: () => _logout(context),
            child: Text('Sair', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Para onde você vai?',
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                SizedBox(height: 20),
                _buildRouteOption(
                  context,
                  '🏛️',
                  'UFF Centro',
                  'Campus do Centro',
                  'centro',
                ),
                _buildRouteOption(
                  context,
                  '🏖️',
                  'Praia Vermelha',
                  'Campus Praia Vermelha',
                  'praia-vermelha',
                ),
                _buildRouteOption(
                  context,
                  '🏢',
                  'Gragoatá',
                  'Campus Gragoatá',
                  'gragoata',
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRouteOption(
    BuildContext context,
    String icon,
    String title,
    String subtitle,
    String routeId,
  ) {
    return ListTile(
      leading: CircleAvatar(child: Text(icon, style: TextStyle(fontSize: 24))),
      title: Text(title, style: TextStyle(fontWeight: FontWeight.bold)),
      subtitle: Text(subtitle),
      onTap: () => _selectRoute(context, title),
      contentPadding: EdgeInsets.all(8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
    );
  }
}

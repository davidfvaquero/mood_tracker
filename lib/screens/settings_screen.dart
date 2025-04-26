import 'package:flutter/material.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Ajustes')),
      body: ListView(
        children: [
          SwitchListTile(
            title: const Text('Notificaciones'),
            value: true,
            onChanged: (value) {}, // TODO: Implementar lógica
          ),
          const ListTile(
            leading: Icon(Icons.palette),
            title: Text('Tema de la aplicación'),
            // TODO: Implementar selector de tema
          ),
          const ListTile(
            leading: Icon(Icons.security),
            title: Text('Privacidad y Seguridad'),
          ),
          // Añadir más opciones según necesidades
        ],
      ),
    );
  }
}
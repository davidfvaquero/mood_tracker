import 'package:flutter/material.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final tips = [
      'Haz 5 minutos de respiración profunda',
      'Sal a caminar al aire libre',
      'Escribe tres cosas por las que estés agradecido',
      'Llama a un amigo o familiar',
      'Practica mindfulness durante 10 minutos'
    ];

    return Scaffold(
      appBar: AppBar(title: const Text('Consejos Útiles')),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(tips[index]),
            onTap: () {}, // TODO: Implementar detalle del consejo
          ),
        ),
      ),
    );
  }
}
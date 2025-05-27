import 'package:flutter/material.dart';
import '../models/tip.dart';
import 'tip_detail_screen.dart';

class TipsScreen extends StatelessWidget {
  final List<Tip> tips = const [
    Tip(
      titulo: 'Haz 5 minutos de respiración profunda',
      descripcion: 'Técnica de relajación para reducir el estrés',
      pasos: [
        'Siéntate en posición cómoda',
        'Coloca una mano en tu pecho y otra en el abdomen',
        'Inhala profundamente por 4 segundos',
        'Exhala lentamente durante 6 segundos',
        'Repite durante 5 minutos',
      ],
      duracion: '5-10 min',
      categoria: 'Relajación',
    ),
    Tip(
      titulo: 'Sal a caminar al aire libre',
      descripcion: 'Reconecta con la naturaleza y despeja tu mente',
      pasos: [
        'Elige un parque o área natural cercana',
        'Camina a ritmo moderado',
        'Observa tu entorno',
        'Respira profundamente',
        'Desconéctate de dispositivos electrónicos',
      ],
      duracion: '15-30 min',
      categoria: 'Ejercicio',
    ),
    Tip(
      titulo: 'Escribe tres cosas por las que estés agradecido',
      descripcion: 'Practica la gratitud para mejorar tu perspectiva emocional',
      pasos: [
        'Toma un cuaderno o abre una app de notas',
        'Escribe tres cosas que te hagan sentir agradecido',
        'Sé específico y reflexiona sobre por qué te hacen sentir bien',
        'Repite esta práctica diariamente',
      ],
      duracion: '5 min',
      categoria: 'Mindfulness',
    ),
    Tip(
      titulo: 'Llama a un amigo o familiar',
      descripcion: 'Fortalece conexiones sociales para mejorar tu ánimo',
      pasos: [
        'Elige a alguien con quien te sientas cómodo',
        'Llamale o envíale un mensaje de voz',
        'Comparte cómo te sientes',
        'Escucha activamente su respuesta',
        'Agradece por su apoyo',
      ],
      duracion: '15-30 min',
      categoria: 'Social',
    ),
    Tip(
      titulo: 'Practica mindfulness durante 10 minutos',
      descripcion: 'Enfócate en el momento presente para reducir la ansiedad',
      pasos: [
        'Siéntate con postura erguida',
        'Enfócate en tu respiración natural',
        'Observa pensamientos sin juzgar',
        'Usa un ancla sensorial (sonidos, sensaciones)',
        'Vuelve suavemente al presente cuando divagues',
      ],
      duracion: '10 min',
      categoria: 'Mindfulness',
    ),
    Tip(
      titulo: 'Toma un descanso lejos de pantallas',
      descripcion: 'Desconéctate de dispositivos para reducir la fatiga visual',
      pasos: [
        'Busca un lugar tranquilo',
        'Cierra los ojos y respira profundamente',
        'Estira el cuello y hombros',
        'Haz una caminata corta si es posible',
        'Vuelve a tus actividades con la mente despejada',
      ],
      duracion: '5-10 min',
      categoria: 'Descanso',
    ),
    Tip(
      titulo: 'Escucha música relajante',
      descripcion: 'Utiliza la música para calmar tu mente y cuerpo',
      pasos: [
        'Elige una lista de reproducción o álbum relajante',
        'Encuentra un lugar cómodo para sentarte o acostarte',
        'Cierra los ojos y concéntrate en la música',
        'Permite que la música te envuelva y te relaje',
        'Disfruta del momento sin distracciones',
      ],
      duracion: '10-30 min',
      categoria: 'Relajación',
    ),
    Tip(
      titulo: 'Practica estiramientos suaves',
      descripcion: 'Alivia la tensión muscular y mejora la circulación',
      pasos: [
        'Encuentra un espacio cómodo',
        'Realiza estiramientos de cuello, hombros y espalda',
        'Mantén cada estiramiento durante 15-30 segundos',
        'Respira profundamente mientras te estiras',
        'Repite según sea necesario',
      ],
      duracion: '10-15 min',
      categoria: 'Ejercicio',
    ),
    Tip(
      titulo: 'Dedica tiempo a un hobby que disfrutes',
      descripcion:
          'Realiza una actividad que te apasione para mejorar tu estado de ánimo',
      pasos: [
        'Elige un hobby que te guste (leer, pintar, cocinar)',
        'Dedica al menos 30 minutos a esta actividad',
        'Permítete disfrutar sin distracciones',
        'Reflexiona sobre cómo te sientes al finalizar',
      ],
      duracion: '30-60 min',
      categoria: 'Ocio',
    ),
    Tip(
      titulo: 'Bebe agua para mantenerte hidratado',
      descripcion: 'La hidratación es clave para el bienestar físico y mental',
      pasos: [
        'Llena un vaso o botella con agua fresca',
        'Bebe sorbos pequeños y constantes',
        'Presta atención a cómo te sientes al hidratarte',
        'Repite cada vez que sientas sed',
      ],
      duracion: '2 min',
      categoria: 'Salud',
    ),
    Tip(
      titulo: 'Repite una afirmacion positiva en voz alta',
      descripcion: 'Refuerza tu autoestima y confianza',
      pasos: [
        'Elige una afirmación positiva (ej. "Soy capaz y valioso")',
        'Encuentra un lugar tranquilo para concentrarte',
        'Repite la afirmación en voz alta varias veces',
        'Visualiza el significado de la afirmación',
        'Siente cómo te empodera',
      ],
      duracion: '3 min',
      categoria: 'Emocional',
    ),
    Tip(
      titulo: 'Organiza una pequeña meta diaria y celébrala',
      descripcion:
          'Establece un objetivo alcanzable para mejorar tu motivación',
      pasos: [
        'Define una meta simple',
        'Dividela en pasos pequeños',
        'Establece un plazo realista',
        'Alcanza la meta y reconoce tu logro',
        'Celebra con algo que disfrutes',
      ],
      duracion: 'Variable',
      categoria: 'Productividad',
    ),
    Tip(
      titulo: 'Ofrece ayuda a alguien que lo necesite',
      descripcion: 'Altruismo para generar bienestar mutuo',
      pasos: [
        'Identifica a alguien que necesite apoyo',
        'Ofrece tu ayuda de manera genuina',
        'Escucha sus necesidades y preocupaciones',
        'Brinda tu apoyo de la mejor manera posible',
        'Reflexiona sobre cómo te sientes al ayudar',
      ],
      duracion: 'Variable',
      categoria: 'Social',
    ),
    Tip(
      titulo: 'Ordena un espacio de tu hogar',
      descripcion: 'Organiza un área para reducir el desorden mental',
      pasos: [
        'Elige un espacio pequeño (escritorio, armario)',
        'Retira todo lo innecesario',
        'Organiza lo que queda de manera funcional',
        'Limpia el área para mayor claridad',
        'Disfruta del nuevo orden',
      ],
      duracion: '15-30 min',
      categoria: 'Productividad',
    ),
    Tip(
      titulo: 'Acaricia a una mascota o planta',
      descripcion: 'Conexión con seres vivos para reducir estrés',
      pasos: [
        'Busca a tu mascota o una planta cercana',
        'Tómate un momento para acariciarla suavemente',
        'Observa sus reacciones y disfruta del momento',
        'Respira profundamente mientras interactúas',
        'Agradece por la compañía que te brindan',
      ],
      duracion: '5 min',
      categoria: 'Emocional',
    ),
    Tip(
      titulo: 'Observa el cielo',
      descripcion: 'Conéctate con la naturaleza y relaja tu mente',
      pasos: [
        'Encuentra un lugar cómodo al aire libre',
        'Mira hacia arriba y observa las nubes o estrellas',
        'Respira profundamente y relájate',
        'Permite que tu mente divague mientras observas',
        'Disfruta de la calma que te brinda el cielo',
      ],
      duracion: '5-10 min',
      categoria: 'Mindfulness',
    ),
    Tip(
      titulo: 'Desconéctate de redes sociales por una hora',
      descripcion: 'Reduce la sobrecarga de información y mejora tu bienestar',
      pasos: [
        'Configura una alarma para una hora',
        'Cierra todas las aplicaciones de redes sociales',
        'Activa modo avión o silencia notificaciones',
        'Dedica este tiempo a actividades offline (leer, meditar)',
        'Reflexiona sobre cómo te sientes al desconectarte',
      ],
      duracion: '1 hora',
      categoria: 'Descanso',
    ),
    Tip(
      titulo: 'Visualiza un lugar que te transmita paz',
      descripcion: 'Utiliza la visualización para reducir la ansiedad',
      pasos: [
        'Encuentra un lugar tranquilo para sentarte',
        'Cierra los ojos y respira profundamente',
        'Imagina un lugar que te haga sentir en paz (playa, bosque)',
        'Visualiza los detalles: sonidos, olores, sensaciones',
        'Permite que esa sensación de paz te envuelva',
      ],
      duracion: '5-10 min',
      categoria: 'Mindfulness',
    ),
    Tip(
      titulo: 'Prueba una nueva receta saludable',
      descripcion: 'Cocina terapéutica para estimular creatividad',
      pasos: [
        'Elige ingredientes nutritivos',
        'Enfócate en el proceso, no solo en el resultado',
        'Experimenta con combinaciones',
        'Disfruta la comida conscientemente',
      ],
      duracion: '30-60 min',
      categoria: 'Creatividad',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Consejos Útiles')),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder:
            (context, index) => Card(
              margin: const EdgeInsets.all(8),
              child: ListTile(
                leading: const Icon(Icons.lightbulb_outline),
                title: Text(tips[index].titulo),
                onTap:
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => TipDetailScreen(tip: tips[index]),
                      ),
                    ),
              ),
            ),
      ),
    );
  }
}

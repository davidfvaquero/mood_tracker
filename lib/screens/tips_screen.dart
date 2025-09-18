import 'package:flutter/material.dart';
import '../models/tip.dart';
import 'tip_detail_screen.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';

class TipsScreen extends StatelessWidget {
  const TipsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final localizations = AppLocalizations.of(context)!;
    
    final List<Tip> tips = [
      Tip(
        titulo: localizations.breathingTipTitle,
        descripcion: localizations.breathingTipDescription,
        pasos: [
          localizations.breathingTipStep1,
          localizations.breathingTipStep2,
          localizations.breathingTipStep3,
          localizations.breathingTipStep4,
          localizations.breathingTipStep5,
        ],
        duracion: localizations.duration5to10,
        categoria: localizations.relaxationCategory,
      ),
      Tip(
        titulo: localizations.walkTipTitle,
        descripcion: localizations.walkTipDescription,
        pasos: [
          localizations.walkTipStep1,
          localizations.walkTipStep2,
          localizations.walkTipStep3,
          localizations.walkTipStep4,
          localizations.walkTipStep5,
        ],
        duracion: localizations.duration15to30,
        categoria: localizations.exerciseCategory,
      ),
      Tip(
        titulo: localizations.gratitudeTipTitle,
        descripcion: localizations.gratitudeTipDescription,
        pasos: [
          localizations.gratitudeTipStep1,
          localizations.gratitudeTipStep2,
          localizations.gratitudeTipStep3,
          localizations.gratitudeTipStep4,
        ],
        duracion: localizations.duration5,
        categoria: localizations.mindfulnessCategory,
      ),
      Tip(
        titulo: localizations.callTipTitle,
        descripcion: localizations.callTipDescription,
        pasos: [
          localizations.callTipStep1,
          localizations.callTipStep2,
          localizations.callTipStep3,
          localizations.callTipStep4,
          localizations.callTipStep5,
        ],
        duracion: localizations.duration15to30,
        categoria: localizations.socialCategory,
      ),
      Tip(
        titulo: localizations.mindfulnessTipTitle,
        descripcion: localizations.mindfulnessTipDescription,
        pasos: [
          localizations.mindfulnessTipStep1,
          localizations.mindfulnessTipStep2,
          localizations.mindfulnessTipStep3,
          localizations.mindfulnessTipStep4,
          localizations.mindfulnessTipStep5,
        ],
        duracion: localizations.duration10,
        categoria: localizations.mindfulnessCategory,
      ),
      Tip(
        titulo: localizations.screenBreakTipTitle,
        descripcion: localizations.screenBreakTipDescription,
        pasos: [
          localizations.screenBreakTipStep1,
          localizations.screenBreakTipStep2,
          localizations.screenBreakTipStep3,
          localizations.screenBreakTipStep4,
          localizations.screenBreakTipStep5,
        ],
        duracion: localizations.duration5to10,
        categoria: localizations.restCategory,
      ),
      Tip(
        titulo: localizations.musicTipTitle,
        descripcion: localizations.musicTipDescription,
        pasos: [
          localizations.musicTipStep1,
          localizations.musicTipStep2,
          localizations.musicTipStep3,
          localizations.musicTipStep4,
          localizations.musicTipStep5,
        ],
        duracion: localizations.duration10to30,
        categoria: localizations.relaxationCategory,
      ),
      Tip(
        titulo: localizations.stretchTipTitle,
        descripcion: localizations.stretchTipDescription,
        pasos: [
          localizations.stretchTipStep1,
          localizations.stretchTipStep2,
          localizations.stretchTipStep3,
          localizations.stretchTipStep4,
          localizations.stretchTipStep5,
        ],
        duracion: localizations.duration10to15,
        categoria: localizations.exerciseCategory,
      ),
      Tip(
        titulo: localizations.hobbyTipTitle,
        descripcion: localizations.hobbyTipDescription,
        pasos: [
          localizations.hobbyTipStep1,
          localizations.hobbyTipStep2,
          localizations.hobbyTipStep3,
          localizations.hobbyTipStep4,
        ],
        duracion: localizations.duration30to60,
        categoria: localizations.leisureCategory,
      ),
      Tip(
        titulo: localizations.waterTipTitle,
        descripcion: localizations.waterTipDescription,
        pasos: [
          localizations.waterTipStep1,
          localizations.waterTipStep2,
          localizations.waterTipStep3,
          localizations.waterTipStep4,
        ],
        duracion: localizations.duration2,
        categoria: localizations.healthCategory,
      ),
      Tip(
        titulo: localizations.affirmationTipTitle,
        descripcion: localizations.affirmationTipDescription,
        pasos: [
          localizations.affirmationTipStep1,
          localizations.affirmationTipStep2,
          localizations.affirmationTipStep3,
          localizations.affirmationTipStep4,
          localizations.affirmationTipStep5,
        ],
        duracion: localizations.duration3,
        categoria: localizations.emotionalCategory,
      ),
      Tip(
        titulo: localizations.goalTipTitle,
        descripcion: localizations.goalTipDescription,
        pasos: [
          localizations.goalTipStep1,
          localizations.goalTipStep2,
          localizations.goalTipStep3,
          localizations.goalTipStep4,
          localizations.goalTipStep5,
        ],
        duracion: localizations.durationVariable,
        categoria: localizations.productivityCategory,
      ),
      Tip(
        titulo: localizations.helpTipTitle,
        descripcion: localizations.helpTipDescription,
        pasos: [
          localizations.helpTipStep1,
          localizations.helpTipStep2,
          localizations.helpTipStep3,
          localizations.helpTipStep4,
          localizations.helpTipStep5,
        ],
        duracion: localizations.durationVariable,
        categoria: localizations.socialCategory,
      ),
      Tip(
        titulo: localizations.organizeTipTitle,
        descripcion: localizations.organizeTipDescription,
        pasos: [
          localizations.organizeTipStep1,
          localizations.organizeTipStep2,
          localizations.organizeTipStep3,
          localizations.organizeTipStep4,
          localizations.organizeTipStep5,
        ],
        duracion: localizations.duration15to30,
        categoria: localizations.productivityCategory,
      ),
      Tip(
        titulo: localizations.petTipTitle,
        descripcion: localizations.petTipDescription,
        pasos: [
          localizations.petTipStep1,
          localizations.petTipStep2,
          localizations.petTipStep3,
          localizations.petTipStep4,
          localizations.petTipStep5,
        ],
        duracion: localizations.duration5,
        categoria: localizations.emotionalCategory,
      ),
      Tip(
        titulo: localizations.skyTipTitle,
        descripcion: localizations.skyTipDescription,
        pasos: [
          localizations.skyTipStep1,
          localizations.skyTipStep2,
          localizations.skyTipStep3,
          localizations.skyTipStep4,
          localizations.skyTipStep5,
        ],
        duracion: localizations.duration5to10,
        categoria: localizations.mindfulnessCategory,
      ),
      Tip(
        titulo: localizations.socialMediaTipTitle,
        descripcion: localizations.socialMediaTipDescription,
        pasos: [
          localizations.socialMediaTipStep1,
          localizations.socialMediaTipStep2,
          localizations.socialMediaTipStep3,
          localizations.socialMediaTipStep4,
          localizations.socialMediaTipStep5,
        ],
        duracion: localizations.duration1hour,
        categoria: localizations.restCategory,
      ),
      Tip(
        titulo: localizations.visualizeTipTitle,
        descripcion: localizations.visualizeTipDescription,
        pasos: [
          localizations.visualizeTipStep1,
          localizations.visualizeTipStep2,
          localizations.visualizeTipStep3,
          localizations.visualizeTipStep4,
          localizations.visualizeTipStep5,
        ],
        duracion: localizations.duration5to10,
        categoria: localizations.mindfulnessCategory,
      ),
      Tip(
        titulo: localizations.recipeTipTitle,
        descripcion: localizations.recipeTipDescription,
        pasos: [
          localizations.recipeTipStep1,
          localizations.recipeTipStep2,
          localizations.recipeTipStep3,
          localizations.recipeTipStep4,
        ],
        duracion: localizations.duration30to60,
        categoria: localizations.creativityCategory,
      ),
    ];

    return Scaffold(
      appBar: AppBar(title: Text(localizations.usefulTips)),
      body: ListView.builder(
        itemCount: tips.length,
        itemBuilder: (context, index) => Card(
          margin: const EdgeInsets.all(8),
          child: ListTile(
            leading: const Icon(Icons.lightbulb_outline),
            title: Text(tips[index].titulo),
            onTap: () => Navigator.push(
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

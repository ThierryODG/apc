import 'package:flutter/material.dart';

import 'package:apc_frontend/shared/presentation/module_home_screen.dart';

class PrepressWorkspace extends StatelessWidget {
  const PrepressWorkspace({super.key});

  @override
  Widget build(BuildContext context) => const ModuleHomeScreen(
    icon: Icons.design_services_outlined,
    eyebrow: 'PAO · PRÉPARATION',
    title: 'Espace préparation graphique',
    description: 'Préparation des fichiers reçus, vérifications techniques et validation avant atelier.',
    modules: [
      'Fichiers à vérifier et consignes de production',
      'Dimensions, résolution et conformité des fichiers',
      'Aperçus et versions préparées',
      'Validation PAO avant impression',
    ],
  );
}

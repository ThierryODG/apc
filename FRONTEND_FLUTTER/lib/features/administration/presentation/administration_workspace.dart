import 'package:flutter/material.dart';

import 'package:apc_frontend/shared/presentation/module_home_screen.dart';

class AdministrationWorkspace extends StatelessWidget {
  const AdministrationWorkspace({super.key});

  @override
  Widget build(BuildContext context) => const ModuleHomeScreen(
    icon: Icons.admin_panel_settings_outlined,
    eyebrow: 'DIRECTION · ADMINISTRATION',
    title: 'Espace de direction',
    description: 'Administration des équipes, paramètres de l’entreprise et pilotage des activités.',
    modules: [
      'Utilisateurs, départements et affectations',
      'Paramètres de l’entreprise et des sites',
      'Suivi d’activité et indicateurs de direction',
      'Historique des actions administratives',
    ],
  );
}

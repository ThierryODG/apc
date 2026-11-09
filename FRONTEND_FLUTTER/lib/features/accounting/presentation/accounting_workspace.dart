import 'package:flutter/material.dart';

import 'package:apc_frontend/shared/presentation/module_home_screen.dart';

class AccountingWorkspace extends StatelessWidget {
  const AccountingWorkspace({super.key});

  @override
  Widget build(BuildContext context) => const ModuleHomeScreen(
    icon: Icons.account_balance_wallet_outlined,
    eyebrow: 'COMPTABILITÉ · CAISSE',
    title: 'Espace comptabilité',
    description: 'Suivi des règlements et des soldes liés aux commandes de l’imprimerie.',
    modules: [
      'Factures et pièces comptables',
      'Acomptes, paiements et soldes',
      'Moyens de paiement et rapprochements',
      'Rapports financiers autorisés',
    ],
  );
}

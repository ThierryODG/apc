String workspaceTitle(Map<String, dynamic> user) {
  final roles = (user['roles'] as List? ?? const []).map((role) => '$role');
  if (roles.contains('SuperAdmin') || roles.contains('DirecteurGeneral')) {
    return 'Direction · Administration';
  }
  if (roles.contains('Secretaire')) return 'Secrétariat · Commercial';
  if (roles.contains('Comptable')) return 'Comptabilité';
  if (roles.contains('Graphiste')) return 'Atelier · Préparation PAO';
  if (roles.contains('Machiniste')) return 'Atelier · Production';
  final department = user['department'];
  if (department is Map && department['name'] is String) {
    return department['name'] as String;
  }
  return 'Équipe APC';
}

String workspaceMessage(Map<String, dynamic> user) {
  final roles = (user['roles'] as List? ?? const []).map((role) => '$role');
  if (roles.contains('Machiniste')) {
    return 'Retrouve ici les informations utiles à ton poste et aux travaux de l’atelier.';
  }
  if (roles.contains('Graphiste')) {
    return 'Retrouve ici les informations utiles à la préparation des fichiers.';
  }
  if (roles.contains('Comptable')) {
    return 'Retrouve ici les informations utiles au suivi comptable.';
  }
  if (roles.contains('Secretaire')) {
    return 'Suis les demandes, les clients et les devis reçus au bureau.';
  }
  if (roles.contains('SuperAdmin') || roles.contains('DirecteurGeneral')) {
    return 'Retrouve ici les informations de gestion et de pilotage de APC.';
  }
  return 'Retrouve les activités de ton espace de travail.';
}

String workspacePendingMessage(Map<String, dynamic> user) {
  final roles = (user['roles'] as List? ?? const []).map((role) => '$role');
  if (roles.contains('Machiniste')) {
    return 'Les ordres de travail et le suivi de production seront affichés ici dès que le module atelier sera disponible.';
  }
  if (roles.contains('Graphiste')) {
    return 'Les fichiers à préparer et les validations PAO seront affichés ici dès que le module fichiers sera disponible.';
  }
  if (roles.contains('Comptable')) {
    return 'Les factures, paiements et soldes seront affichés ici dès que le module comptabilité sera disponible.';
  }
  return 'Les paramètres et indicateurs de pilotage seront ajoutés à mesure que les modules internes seront livrés.';
}

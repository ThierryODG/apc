import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../core/state/auth_state.dart';

class PosTopbar extends StatelessWidget {
  final TextEditingController searchController;
  final ValueChanged<String>? onSearchChanged;

  const PosTopbar({
    super.key,
    required this.searchController,
    this.onSearchChanged,
  });

  @override
  Widget build(BuildContext context) {
    final auth = AuthState();
    final user = auth.currentUser;
    final fiscalYear = auth.activeFiscalYear;

    return Container(
      height: 56,
      padding: const EdgeInsets.symmetric(horizontal: 18),
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        border: Border(bottom: BorderSide(color: AppColors.bord)),
      ),
      child: Row(
        children: [
          // Barre de recherche F3
          Container(
            width: 420,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
            decoration: BoxDecoration(
              color: AppColors.fond,
              borderRadius: BorderRadius.circular(6),
              border: Border.all(color: AppColors.bord),
            ),
            child: Row(
              children: [
                const Icon(Icons.search, size: 18, color: AppColors.gris),
                const SizedBox(width: 8),
                Expanded(
                  child: TextField(
                    controller: searchController,
                    onChanged: onSearchChanged,
                    style: const TextStyle(fontSize: 13),
                    decoration: const InputDecoration(
                      hintText: 'Rechercher prestation, article, client…',
                      hintStyle: TextStyle(color: AppColors.gris, fontSize: 13),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(3),
                    border: Border.all(color: AppColors.bord),
                  ),
                  child: const Text('F3', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.gris)),
                ),
              ],
            ),
          ),

          const Spacer(),

          // Badge Exercice actif (ex: 2025-2026)
          if (fiscalYear != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              margin: const EdgeInsets.only(right: 14),
              decoration: BoxDecoration(
                color: AppColors.bleu.withOpacity(0.08),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.bleu.withOpacity(0.2)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 7,
                    height: 7,
                    decoration: const BoxDecoration(color: AppColors.vert, shape: BoxShape.circle),
                  ),
                  const SizedBox(width: 6),
                  Text(
                    fiscalYear.name,
                    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu),
                  ),
                ],
              ),
            ),

          // Bouton Notifications
          Container(
            width: 34,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.fond,
              borderRadius: BorderRadius.circular(6),
            ),
            child: const Stack(
              alignment: Alignment.center,
              children: [
                Icon(Icons.notifications_none_rounded, size: 18, color: AppColors.texte),
                Positioned(
                  top: 7,
                  right: 7,
                  child: CircleAvatar(radius: 3.5, backgroundColor: AppColors.orange),
                ),
              ],
            ),
          ),
          const SizedBox(width: 14),

          // Profil utilisateur & Déconnexion
          PopupMenuButton<String>(
            onSelected: (val) {
              if (val == 'logout') auth.logout();
            },
            offset: const Offset(0, 42),
            itemBuilder: (context) => [
              PopupMenuItem(
                enabled: false,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(user?.name ?? 'Utilisateur', style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.bleu)),
                    Text(user?.email ?? '', style: const TextStyle(fontSize: 11, color: AppColors.gris)),
                  ],
                ),
              ),
              const PopupMenuDivider(),
              const PopupMenuItem(
                value: 'logout',
                child: Row(
                  children: [
                    Icon(Icons.logout, size: 16, color: AppColors.rouge),
                    SizedBox(width: 8),
                    Text('Se déconnecter', style: TextStyle(color: AppColors.rouge, fontWeight: FontWeight.w600)),
                  ],
                ),
              ),
            ],
            child: Container(
              padding: const EdgeInsets.fromLTRB(4, 4, 12, 4),
              decoration: BoxDecoration(
                color: AppColors.fond,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.bord),
              ),
              child: Row(
                children: [
                  CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.orange,
                    child: Text(
                      user != null && user.name.isNotEmpty ? user.name.substring(0, 2).toUpperCase() : 'AP',
                      style: const TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.w800),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    user?.name ?? 'Secrétariat',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.texte),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.arrow_drop_down, size: 16, color: AppColors.gris),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}


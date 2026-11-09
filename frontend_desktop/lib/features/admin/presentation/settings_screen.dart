import 'package:flutter/material.dart';

import '../../../core/constants/app_colors.dart';

class SettingsScreen extends StatefulWidget {
  const SettingsScreen({super.key});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  final _printerNameCtrl = TextEditingController(text: 'Imprimante thermique');
  final _copiesCtrl = TextEditingController(text: '1');
  final _backupPathCtrl = TextEditingController(text: 'C:/APC/backups');
  final _receiptFooterCtrl = TextEditingController(
    text: 'Merci pour votre confiance. Africa Print Communication.',
  );

  bool _autoPrint = true;
  bool _saveLogs = true;
  bool _autoBackup = true;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
          decoration: const BoxDecoration(
            color: AppColors.blanc,
            border: Border(bottom: BorderSide(color: AppColors.bord)),
          ),
          child: Row(
            children: [
              Container(
                width: 34,
                height: 34,
                decoration: BoxDecoration(
                  color: AppColors.bleu.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(
                  Icons.settings_rounded,
                  size: 18,
                  color: AppColors.bleu,
                ),
              ),
              const SizedBox(width: 12),
              const Text(
                'Paramètres de l’application',
                style: TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w900,
                  color: AppColors.bleu,
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 900),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _buildCard(
                      title: 'Impression & caisse',
                      children: [
                        Row(
                          children: [
                            Expanded(
                              child: _Field(
                                label: 'Imprimante par défaut',
                                child: TextField(
                                  controller: _printerNameCtrl,
                                  decoration: const InputDecoration(
                                    hintText: 'Nom de l’imprimante',
                                  ),
                                ),
                              ),
                            ),
                            const SizedBox(width: 16),
                            Expanded(
                              child: _Field(
                                label: 'Nombre de copies',
                                child: TextField(
                                  controller: _copiesCtrl,
                                  keyboardType: TextInputType.number,
                                  decoration: const InputDecoration(
                                    hintText: '1',
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Impression automatique au paiement',
                          ),
                          value: _autoPrint,
                          onChanged: (v) => setState(() => _autoPrint = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: 'Sauvegarde & sécurité',
                      children: [
                        _Field(
                          label: 'Dossier de sauvegarde',
                          child: TextField(
                            controller: _backupPathCtrl,
                            decoration: const InputDecoration(
                              hintText: 'Chemin du dossier de sauvegarde',
                            ),
                          ),
                        ),
                        const SizedBox(height: 12),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Sauvegarde automatique quotidienne',
                          ),
                          value: _autoBackup,
                          onChanged: (v) => setState(() => _autoBackup = v),
                        ),
                        SwitchListTile(
                          contentPadding: EdgeInsets.zero,
                          title: const Text(
                            'Journalisation des actions système',
                          ),
                          value: _saveLogs,
                          onChanged: (v) => setState(() => _saveLogs = v),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    _buildCard(
                      title: 'Message reçu / devis',
                      children: [
                        _Field(
                          label: 'Pied de page imprimé',
                          child: TextField(
                            controller: _receiptFooterCtrl,
                            maxLines: 3,
                            decoration: const InputDecoration(
                              hintText: 'Message affiché sur les reçus',
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 24),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton.icon(
                        onPressed: () {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Paramètres enregistrés localement.',
                              ),
                              backgroundColor: AppColors.vert,
                            ),
                          );
                        },
                        icon: const Icon(Icons.save_rounded),
                        label: const Text(
                          'ENREGISTRER LES PARAMÈTRES',
                          style: TextStyle(
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.5,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppColors.bleu,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCard({required String title, required List<Widget> children}) {
    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.bord),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              color: AppColors.bleu,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 14),
          ...children,
        ],
      ),
    );
  }
}

class _Field extends StatelessWidget {
  final String label;
  final Widget child;

  const _Field({required this.label, required this.child});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(bottom: 6),
          child: Text(
            label,
            style: const TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: AppColors.bleu,
            ),
          ),
        ),
        child,
      ],
    );
  }
}

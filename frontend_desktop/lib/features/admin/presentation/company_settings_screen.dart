import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class CompanySettingsScreen extends StatefulWidget {
  const CompanySettingsScreen({super.key});
  @override State<CompanySettingsScreen> createState() => _CompanySettingsScreenState();
}

class _CompanySettingsScreenState extends State<CompanySettingsScreen> {
  final _nameCtrl = TextEditingController();
  final _ifuCtrl = TextEditingController();
  final _rccmCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _receiptFooterCtrl = TextEditingController();

  final List<TextEditingController> _phoneCtrls = [TextEditingController()];
  final List<TextEditingController> _emailCtrls = [TextEditingController()];

  bool _loading = true;
  bool _saving = false;
  String? _error;
  String? _success;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.adminCompany);
      final c = res['company'] ?? res;
      setState(() {
        _nameCtrl.text = c['name'] ?? '';
        _ifuCtrl.text = c['ifu'] ?? '';
        _rccmCtrl.text = c['rccm'] ?? '';
        _addressCtrl.text = c['address'] ?? '';
        _receiptFooterCtrl.text = c['receipt_footer'] ?? '';

        final phones = (c['phone'] ?? '').toString().split(RegExp(r'[,;/]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        _phoneCtrls.clear();
        if (phones.isEmpty) {
          _phoneCtrls.add(TextEditingController());
        } else {
          for (final p in phones) {
            _phoneCtrls.add(TextEditingController(text: p));
          }
        }

        final emails = (c['email'] ?? '').toString().split(RegExp(r'[,;/]')).map((e) => e.trim()).where((e) => e.isNotEmpty).toList();
        _emailCtrls.clear();
        if (emails.isEmpty) {
          _emailCtrls.add(TextEditingController());
        } else {
          for (final em in emails) {
            _emailCtrls.add(TextEditingController(text: em));
          }
        }

        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      final phoneString = _phoneCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(' / ');
      final emailString = _emailCtrls.map((c) => c.text.trim()).where((t) => t.isNotEmpty).join(' ; ');

      await ApiClient().put(ApiEndpoints.adminCompany, {
        'name': _nameCtrl.text.trim(),
        'ifu': _ifuCtrl.text.trim(),
        'rccm': _rccmCtrl.text.trim(),
        'phone': phoneString,
        'email': emailString,
        'address': _addressCtrl.text.trim(),
        'receipt_footer': _receiptFooterCtrl.text.trim(),
      });
      setState(() { _success = 'Informations de l\'entreprise enregistrées avec succès.'; _saving = false; });
    } catch (e) {
      setState(() { _error = e.toString(); _saving = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScreenHeader(
          title: 'Fiche Entreprise & Identifiants Légaux',
          icon: Icons.business_rounded,
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
                  child: Center(
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 820),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (_error != null) _AlertBanner(message: _error!, color: AppColors.rouge),
                          if (_success != null) _AlertBanner(message: _success!, color: AppColors.vert),

                          // Aperçu du logo de l'entreprise
                          Container(
                            padding: const EdgeInsets.all(16),
                            margin: const EdgeInsets.only(bottom: 24),
                            decoration: BoxDecoration(
                              color: AppColors.blanc,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.bord),
                            ),
                            child: Row(
                              children: [
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(6),
                                  child: Image.asset(
                                    'assets/brand/logo.png',
                                    height: 52,
                                    fit: BoxFit.contain,
                                    errorBuilder: (_, __, ___) => const Icon(Icons.business, size: 40, color: AppColors.bleu),
                                  ),
                                ),
                                const SizedBox(width: 16),
                                const Expanded(
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        'Logo officiel de l\'entreprise',
                                        style: TextStyle(fontSize: 13, fontWeight: FontWeight.w800, color: AppColors.bleu),
                                      ),
                                      SizedBox(height: 2),
                                      Text(
                                        'Ce logo est automatiquement affiché sur la barre latérale, les reçus et les devis.',
                                        style: TextStyle(fontSize: 11, color: AppColors.gris),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          ),

                          _SectionTitle('INFORMATIONS JURIDIQUES & FISCALES'),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Raison sociale / Nom complet *'),
                                    _Input(controller: _nameCtrl, hint: 'Africa Print Communication'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Numéro IFU'),
                                    _Input(controller: _ifuCtrl, hint: 'Identifiant Fiscal Unique'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 14),
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Numéro RCCM'),
                                    _Input(controller: _rccmCtrl, hint: 'Registre du Commerce (RCCM)'),
                                  ],
                                ),
                              ),
                              const SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const _FieldLabel('Adresse géographique'),
                                    _Input(controller: _addressCtrl, hint: 'Siège social, Ville, Pays'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),

                          // Téléphones multiples avec bouton "+"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SectionTitle('NUMÉROS DE TÉLÉPHONE'),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _phoneCtrls.add(TextEditingController()));
                                },
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Ajouter un numéro', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._phoneCtrls.asMap().entries.map((entry) {
                            final i = entry.key;
                            final ctrl = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _Input(
                                      controller: ctrl,
                                      hint: 'Ex: +229 01 23 45 67',
                                    ),
                                  ),
                                  if (_phoneCtrls.length > 1) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.rouge, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _phoneCtrls.removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 20),

                          // Emails multiples avec bouton "+"
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              _SectionTitle('ADRESSES EMAIL'),
                              TextButton.icon(
                                onPressed: () {
                                  setState(() => _emailCtrls.add(TextEditingController()));
                                },
                                icon: const Icon(Icons.add_rounded, size: 16),
                                label: const Text('Ajouter un email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                              ),
                            ],
                          ),
                          const SizedBox(height: 8),
                          ..._emailCtrls.asMap().entries.map((entry) {
                            final i = entry.key;
                            final ctrl = entry.value;
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 8),
                              child: Row(
                                children: [
                                  Expanded(
                                    child: _Input(
                                      controller: ctrl,
                                      hint: 'Ex: contact@africaprint.com',
                                    ),
                                  ),
                                  if (_emailCtrls.length > 1) ...[
                                    const SizedBox(width: 8),
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle_outline_rounded, color: AppColors.rouge, size: 20),
                                      onPressed: () {
                                        setState(() {
                                          _emailCtrls.removeAt(i);
                                        });
                                      },
                                    ),
                                  ],
                                ],
                              ),
                            );
                          }),

                          const SizedBox(height: 24),

                          _SectionTitle('PIED DE PAGE DES REÇUS & FACTURES'),
                          const SizedBox(height: 10),
                          const _FieldLabel('Mention légale & remerciements imprimés'),
                          _Input(
                            controller: _receiptFooterCtrl,
                            hint: 'Ex: Les marchandises vendues ne sont ni reprises ni échangées. Merci pour votre confiance !',
                            maxLines: 3,
                          ),
                          const SizedBox(height: 6),
                          const Text(
                            'Ce texte apparaît tout en bas de chaque ticket de caisse et reçu imprimé.',
                            style: TextStyle(fontSize: 11, color: AppColors.gris),
                          ),
                          const SizedBox(height: 28),

                          // Bouton Enregistrer unique en bas de formulaire
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton.icon(
                              onPressed: _saving ? null : _save,
                              icon: _saving
                                  ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                                  : const Icon(Icons.check_circle_rounded, size: 18),
                              label: const Text('ENREGISTRER LA FICHE ENTREPRISE', style: TextStyle(fontWeight: FontWeight.w900, letterSpacing: 0.5)),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.bleu,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                        ],
                      ),
                    ),
                  ),
                ),
        ),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle(this.title);

  @override
  Widget build(BuildContext context) => Text(
    title,
    style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.bleu),
  );
}

class _AlertBanner extends StatelessWidget {
  final String message;
  final Color color;
  const _AlertBanner({required this.message, required this.color});

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(12),
    margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(
      color: color.withOpacity(0.08),
      borderRadius: BorderRadius.circular(6),
      border: Border.all(color: color.withOpacity(0.3)),
    ),
    child: Text(message, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

class _ScreenHeader extends StatelessWidget {
  final String title;
  final IconData icon;

  const _ScreenHeader({required this.title, required this.icon});

  @override
  Widget build(BuildContext context) => Container(
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
          child: Icon(icon, size: 18, color: AppColors.bleu),
        ),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
      ],
    ),
  );
}

class _FieldLabel extends StatelessWidget {
  final String label;
  const _FieldLabel(this.label);

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 6),
    child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
  );
}

class _Input extends StatelessWidget {
  final TextEditingController controller;
  final String hint;
  final int maxLines;

  const _Input({required this.controller, required this.hint, this.maxLines = 1});

  @override
  Widget build(BuildContext context) => TextField(
    controller: controller,
    maxLines: maxLines,
    decoration: InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      isDense: true,
    ),
    style: const TextStyle(fontSize: 13),
  );
}

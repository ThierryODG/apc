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
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _addressCtrl = TextEditingController();
  final _receiptFooterCtrl = TextEditingController();
  bool _loading = true; bool _saving = false; String? _error; String? _success;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.adminCompany);
      final c = res['company'] ?? res;
      setState(() {
        _nameCtrl.text = c['name'] ?? '';
        _ifuCtrl.text = c['ifu'] ?? '';
        _rccmCtrl.text = c['rccm'] ?? '';
        _phoneCtrl.text = c['phone'] ?? '';
        _emailCtrl.text = c['email'] ?? '';
        _addressCtrl.text = c['address'] ?? '';
        _receiptFooterCtrl.text = c['receipt_footer'] ?? '';
        _loading = false;
      });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  Future<void> _save() async {
    setState(() { _saving = true; _error = null; _success = null; });
    try {
      await ApiClient().put(ApiEndpoints.adminCompany, {
        'name': _nameCtrl.text.trim(), 'ifu': _ifuCtrl.text.trim(), 'rccm': _rccmCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim(), 'email': _emailCtrl.text.trim(),
        'address': _addressCtrl.text.trim(), 'receipt_footer': _receiptFooterCtrl.text.trim(),
      });
      setState(() { _success = 'Informations enregistrées avec succès.'; _saving = false; });
    } catch (e) { setState(() { _error = e.toString(); _saving = false; }); }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Paramètres Entreprise', icon: Icons.business_rounded, actionLabel: 'Enregistrer', onAction: _saving ? null : _save),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(padding: const EdgeInsets.all(24), child: Center(child: SizedBox(width: 600, child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [

                if (_error != null) _AlertBanner(message: _error!, color: AppColors.rouge),
                if (_success != null) _AlertBanner(message: _success!, color: AppColors.vert),

                _SectionTitle('INFORMATIONS LÉGALES'),
                const SizedBox(height: 12),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Nom de l\'entreprise *'), _Input(controller: _nameCtrl, hint: 'Africa Print Communication')])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('N° IFU'), _Input(controller: _ifuCtrl, hint: 'Identifiant Fiscal Unique')])),
                ]),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('N° RCCM'), _Input(controller: _rccmCtrl, hint: 'Registre du Commerce')])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Téléphone'), _Input(controller: _phoneCtrl, hint: '+229 00 00 00 00')])),
                ]),
                const SizedBox(height: 14),
                Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Email'), _Input(controller: _emailCtrl, hint: 'contact@africaprint.com')])),
                  const SizedBox(width: 16),
                  Expanded(child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [const _FieldLabel('Adresse'), _Input(controller: _addressCtrl, hint: 'Adresse complète')])),
                ]),
                const SizedBox(height: 24),

                _SectionTitle('IMPRESSION DES REÇUS'),
                const SizedBox(height: 12),
                const _FieldLabel('Pied de page du reçu'),
                _Input(controller: _receiptFooterCtrl, hint: 'Ex: Merci pour votre confiance ! Tél: +229...', maxLines: 3),
                const SizedBox(height: 8),
                const Text('Ce texte apparaîtra en bas de chaque reçu imprimé.', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                const SizedBox(height: 24),

                // Bouton Enregistrer
                SizedBox(width: double.infinity, child: ElevatedButton.icon(
                  onPressed: _saving ? null : _save,
                  icon: _saving ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.save_rounded, size: 16),
                  label: const Text('ENREGISTRER LES MODIFICATIONS', style: TextStyle(fontWeight: FontWeight.w900)),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
                )),
              ])))),
      ),
    ]);
  }
}

class _SectionTitle extends StatelessWidget {
  final String title; const _SectionTitle(this.title);
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.only(bottom: 8),
    decoration: const BoxDecoration(border: Border(bottom: BorderSide(color: AppColors.bord))),
    child: Text(title, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, letterSpacing: 0.5, color: AppColors.bleu)),
  );
}

class _AlertBanner extends StatelessWidget {
  final String message; final Color color;
  const _AlertBanner({required this.message, required this.color});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 16),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(message, style: TextStyle(color: color, fontSize: 12, fontWeight: FontWeight.w600)),
  );
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)),
      const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)), const SizedBox(width: 20),
      if (child != null) Expanded(child: child!) else const Spacer(),
      if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

class _FieldLabel extends StatelessWidget {
  final String label; const _FieldLabel(this.label);
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.only(bottom: 6), child: Text(label, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)));
}

class _Input extends StatelessWidget {
  final TextEditingController controller; final String hint; final int maxLines;
  const _Input({required this.controller, required this.hint, this.maxLines = 1});
  @override Widget build(BuildContext context) => TextField(controller: controller, maxLines: maxLines, decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12), border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)), contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true), style: const TextStyle(fontSize: 13));
}


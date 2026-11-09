import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/customer.dart';

class CustomersScreen extends StatefulWidget {
  const CustomersScreen({super.key});

  @override
  State<CustomersScreen> createState() => _CustomersScreenState();
}

class _CustomersScreenState extends State<CustomersScreen> {
  List<Customer> _customers = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();
  List<Customer> _filtered = [];

  @override
  void initState() {
    super.initState();
    _load();
    _searchCtrl.addListener(() {
      final q = _searchCtrl.text.toLowerCase();
      setState(() {
        _filtered = _customers.where((c) =>
          c.name.toLowerCase().contains(q) ||
          (c.phone ?? '').contains(q) ||
          (c.email ?? '').toLowerCase().contains(q)
        ).toList();
      });
    });
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryCustomers);
      final List data = res['data'] ?? res['customers'] ?? [];
      setState(() {
        _customers = data.map((c) => Customer.fromJson(c)).toList();
        _filtered = List.from(_customers);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openCreateDialog() async {
    final created = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _CreateCustomerDialog(),
    );
    if (created == true) _load();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── En-tête ──────────────────────────────────────────
        _ScreenHeader(
          title: 'Clients',
          icon: Icons.people_alt_rounded,
          actionLabel: '+ Nouveau client',
          onAction: _openCreateDialog,
          child: SizedBox(
            width: 280,
            child: TextField(
              controller: _searchCtrl,
              decoration: InputDecoration(
                hintText: 'Rechercher...',
                prefixIcon: const Icon(Icons.search_rounded, size: 16),
                contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                isDense: true,
              ),
            ),
          ),
        ),

        // ── Tableau ──────────────────────────────────────────
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Aucun client trouvé.', style: TextStyle(color: AppColors.gris)))
                      : _CustomersTable(customers: _filtered),
        ),
      ],
    );
  }
}

class _CustomersTable extends StatelessWidget {
  final List<Customer> customers;
  const _CustomersTable({required this.customers});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Container(
        decoration: BoxDecoration(
          color: AppColors.blanc,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: AppColors.bord),
        ),
        child: Column(
          children: [
            // En-tête colonnes
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: AppColors.bord)),
                borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
              ),
              child: const Row(
                children: [
                  Expanded(flex: 3, child: _ColHeader('NOM')),
                  Expanded(flex: 2, child: _ColHeader('TÉLÉPHONE')),
                  Expanded(flex: 3, child: _ColHeader('EMAIL')),
                  Expanded(flex: 2, child: _ColHeader('N° IFU')),
                  Expanded(flex: 2, child: _ColHeader('CODE')),
                ],
              ),
            ),
            Expanded(
              child: ListView.separated(
                itemCount: customers.length,
                separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                itemBuilder: (ctx, i) {
                  final c = customers[i];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                    child: Row(
                      children: [
                        Expanded(flex: 3, child: Row(
                          children: [
                            CircleAvatar(
                              radius: 14,
                              backgroundColor: AppColors.bleu.withOpacity(0.1),
                              child: Text(c.name.substring(0, 1).toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                            ),
                            const SizedBox(width: 8),
                            Expanded(child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600), overflow: TextOverflow.ellipsis)),
                          ],
                        )),
                        Expanded(flex: 2, child: Text(c.phone ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris))),
                        Expanded(flex: 3, child: Text(c.email ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris), overflow: TextOverflow.ellipsis)),
                        Expanded(flex: 2, child: Text(c.ifuNumber ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris))),
                        Expanded(flex: 2, child: Text(c.code, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.bleu))),
                      ],
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _CreateCustomerDialog extends StatefulWidget {
  const _CreateCustomerDialog();

  @override
  State<_CreateCustomerDialog> createState() => _CreateCustomerDialogState();
}

class _CreateCustomerDialogState extends State<_CreateCustomerDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ifuCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Le nom est obligatoire.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.secretaryCustomers, {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'ifu': _ifuCtrl.text.trim().isEmpty ? null : _ifuCtrl.text.trim(),
      });
      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 400,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            _DialogHeader(title: 'Nouveau Client', icon: Icons.person_add_rounded),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null) _ErrorBanner(_error!),
                  _FieldLabel('Nom *'),
                  _Input(controller: _nameCtrl, hint: 'Nom complet ou raison sociale'),
                  const SizedBox(height: 14),
                  _FieldLabel('Téléphone'),
                  _Input(controller: _phoneCtrl, hint: '+229 00 00 00 00'),
                  const SizedBox(height: 14),
                  _FieldLabel('Email'),
                  _Input(controller: _emailCtrl, hint: 'email@exemple.com'),
                  const SizedBox(height: 14),
                  _FieldLabel('N° IFU'),
                  _Input(controller: _ifuCtrl, hint: 'Numéro Identifiant Fiscal Unique'),
                ],
              ),
            ),
            _DialogActions(
              onConfirm: _loading ? null : _submit,
              confirmLabel: 'Enregistrer',
              isLoading: _loading,
            ),
          ],
        ),
      ),
    );
  }
}



// ─────────────────────────────────────────────────────────────────────────────
// Widgets locaux partagés dans ce fichier
// ─────────────────────────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
      decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))),
      child: Row(children: [
        Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)),
        const SizedBox(width: 12),
        Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)),
        const SizedBox(width: 20),
        if (child != null) Expanded(child: child!) else const Spacer(),
        if (actionLabel != null && onAction != null)
          ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
      ]),
    );
  }
}

class _ColHeader extends StatelessWidget {
  final String label;
  const _ColHeader(this.label);
  @override
  Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5));
}

class _DialogHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  const _DialogHeader({required this.title, required this.icon});
  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: const BoxDecoration(color: AppColors.bleu, borderRadius: BorderRadius.vertical(top: Radius.circular(10))),
      child: Row(children: [
        Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10),
        Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))),
        IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints()),
      ]),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  final String message;
  const _ErrorBanner(this.message);
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 14),
    decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.rouge.withOpacity(0.3))),
    child: Text(message, style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600)),
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
  final TextInputType? keyboardType;
  final int maxLines;
  const _Input({required this.controller, required this.hint, this.keyboardType, this.maxLines = 1});
  @override
  Widget build(BuildContext context) => TextField(
    controller: controller, keyboardType: keyboardType, maxLines: maxLines,
    decoration: InputDecoration(hintText: hint, hintStyle: const TextStyle(color: AppColors.gris, fontSize: 12),
      border: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(6), borderSide: const BorderSide(color: AppColors.bord)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10), isDense: true),
    style: const TextStyle(fontSize: 13),
  );
}

class _DialogActions extends StatelessWidget {
  final VoidCallback? onConfirm;
  final String confirmLabel;
  final bool isLoading;
  const _DialogActions({this.onConfirm, this.confirmLabel = 'Enregistrer', this.isLoading = false});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
    child: Row(children: [
      Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bord), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('Annuler'))),
      const SizedBox(width: 10),
      Expanded(flex: 2, child: ElevatedButton(
        onPressed: isLoading ? null : onConfirm,
        style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))),
        child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700)),
      )),
    ]),
  );
}

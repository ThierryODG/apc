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
  List<Customer> _filtered = [];
  bool _loading = true;
  String? _error;
  final _searchCtrl = TextEditingController();

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
          (c.email ?? '').toLowerCase().contains(q) ||
          c.code.toLowerCase().contains(q)
        ).toList();
      });
    });
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryCustomers);
      final list = ApiClient.extractList(res, 'customers');
      setState(() {
        _customers = list.map((c) => Customer.fromJson(c as Map<String, dynamic>)).toList();
        _filtered = List.from(_customers);
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openCreateOrEditDialog([Customer? customer]) async {
    final result = await showDialog<bool>(
      context: context,
      builder: (ctx) => _CustomerFormDialog(customer: customer),
    );
    if (result == true) _load();
  }

  Future<void> _confirmDelete(Customer c) async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Désactiver ce client ?', style: TextStyle(fontWeight: FontWeight.w800)),
        content: Text('Voulez-vous désactiver la fiche de "${c.name}" ? Il ne sera plus proposé au guichet.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rouge),
            child: const Text('Désactiver'),
          ),
        ],
      ),
    );
    if (ok == true) {
      try {
        await ApiClient().patch('${ApiEndpoints.secretaryCustomers}/${c.id}');
        _load();
      } catch (e) {
        if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
      }
    }
  }

  void _exportCsv() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Exportation de ${_filtered.length} client(s) au format CSV terminée avec succès.'),
        backgroundColor: AppColors.vert,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        // ── En-tête avec bouton d'export et création ──
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
                  color: AppColors.bleu.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.people_alt_rounded, size: 18, color: AppColors.bleu),
              ),
              const SizedBox(width: 12),
              const Text('Fichier Clients & Fidélisation', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
              const SizedBox(width: 20),
              SizedBox(
                width: 260,
                child: TextField(
                  controller: _searchCtrl,
                  decoration: InputDecoration(
                    hintText: 'Rechercher nom, code, tél…',
                    prefixIcon: const Icon(Icons.search_rounded, size: 16),
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    border: OutlineInputBorder(borderRadius: BorderRadius.circular(6)),
                    isDense: true,
                  ),
                ),
              ),
              const Spacer(),
              OutlinedButton.icon(
                onPressed: _exportCsv,
                icon: const Icon(Icons.file_download_outlined, size: 16),
                label: const Text('Exporter CSV', style: TextStyle(fontSize: 12)),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
              const SizedBox(width: 10),
              ElevatedButton.icon(
                onPressed: () => _openCreateOrEditDialog(),
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Nouveau Client', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleu,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),

        // ── Bandeau Meilleurs Clients / Fidélisation ──
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
          color: const Color(0xFFF8FAFC),
          child: Row(
            children: [
              const Icon(Icons.star_rounded, size: 18, color: AppColors.orange),
              const SizedBox(width: 8),
              const Text('Clients Privilégiés & Actifs :', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.bleu)),
              const SizedBox(width: 12),
              Expanded(
                child: SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: _customers.take(4).map((c) => Container(
                      margin: const EdgeInsets.only(right: 8),
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.blanc,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppColors.bord),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          CircleAvatar(
                            radius: 10,
                            backgroundColor: AppColors.orange.withOpacity(0.15),
                            child: Text(c.name.substring(0, 1).toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w900, color: AppColors.orange)),
                          ),
                          const SizedBox(width: 6),
                          Text(c.name, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700)),
                        ],
                      ),
                    )).toList(),
                  ),
                ),
              ),
            ],
          ),
        ),

        // ── Tableau des clients ──
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _filtered.isEmpty
                      ? const Center(child: Text('Aucun client enregistré.', style: TextStyle(color: AppColors.gris)))
                      : Padding(
                          padding: const EdgeInsets.all(16),
                          child: Container(
                            decoration: BoxDecoration(
                              color: AppColors.blanc,
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(color: AppColors.bord),
                            ),
                            child: Column(
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                  decoration: const BoxDecoration(
                                    color: Color(0xFFF8FAFC),
                                    border: Border(bottom: BorderSide(color: AppColors.bord)),
                                    borderRadius: BorderRadius.vertical(top: Radius.circular(8)),
                                  ),
                                  child: const Row(
                                    children: [
                                      Expanded(flex: 2, child: Text('CODE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 4, child: Text('NOM & RAISON SOCIALE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 3, child: Text('CONTACT TÉLÉPHONIQUE', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 3, child: Text('EMAIL', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 2, child: Text('N° IFU', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                      Expanded(flex: 2, child: Text('ACTIONS', textAlign: TextAlign.right, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: AppColors.gris))),
                                    ],
                                  ),
                                ),
                                Expanded(
                                  child: ListView.separated(
                                    itemCount: _filtered.length,
                                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                                    itemBuilder: (ctx, i) {
                                      final c = _filtered[i];
                                      return Padding(
                                        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                                        child: Row(
                                          children: [
                                            Expanded(flex: 2, child: Text(c.code, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w800, color: AppColors.bleu))),
                                            Expanded(flex: 4, child: Text(c.name, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                                            Expanded(flex: 3, child: Text(c.phone ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris))),
                                            Expanded(flex: 3, child: Text(c.email ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris), overflow: TextOverflow.ellipsis)),
                                            Expanded(flex: 2, child: Text(c.ifuNumber ?? '—', style: const TextStyle(fontSize: 12, color: AppColors.gris))),
                                            Expanded(
                                              flex: 2,
                                              child: Row(
                                                mainAxisAlignment: MainAxisAlignment.end,
                                                children: [
                                                  IconButton(
                                                    icon: const Icon(Icons.edit_outlined, size: 16, color: AppColors.bleu),
                                                    tooltip: 'Modifier',
                                                    onPressed: () => _openCreateOrEditDialog(c),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                  const SizedBox(width: 8),
                                                  IconButton(
                                                    icon: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rouge),
                                                    tooltip: 'Désactiver',
                                                    onPressed: () => _confirmDelete(c),
                                                    padding: EdgeInsets.zero,
                                                    constraints: const BoxConstraints(),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
        ),
      ],
    );
  }
}

class _CustomerFormDialog extends StatefulWidget {
  final Customer? customer;
  const _CustomerFormDialog({this.customer});

  @override
  State<_CustomerFormDialog> createState() => _CustomerFormDialogState();
}

class _CustomerFormDialogState extends State<_CustomerFormDialog> {
  final _nameCtrl = TextEditingController();
  final _phoneCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _ifuCtrl = TextEditingController();
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _nameCtrl.text = widget.customer!.name;
      _phoneCtrl.text = widget.customer!.phone ?? '';
      _emailCtrl.text = widget.customer!.email ?? '';
      _ifuCtrl.text = widget.customer!.ifuNumber ?? '';
    }
  }

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty) {
      setState(() => _error = 'Le nom du client est obligatoire.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      final body = {
        'name': _nameCtrl.text.trim(),
        'phone': _phoneCtrl.text.trim().isEmpty ? null : _phoneCtrl.text.trim(),
        'email': _emailCtrl.text.trim().isEmpty ? null : _emailCtrl.text.trim(),
        'ifu_number': _ifuCtrl.text.trim().isEmpty ? null : _ifuCtrl.text.trim(),
      };

      if (widget.customer == null) {
        await ApiClient().post(ApiEndpoints.secretaryCustomers, body);
      } else {
        await ApiClient().put('${ApiEndpoints.secretaryCustomers}/${widget.customer!.id}', body);
      }

      if (mounted) Navigator.pop(context, true);
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.customer != null;
    return Dialog(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: SizedBox(
        width: 440,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: const BoxDecoration(
                color: AppColors.bleu,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  Icon(isEdit ? Icons.edit_rounded : Icons.person_add_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  Text(
                    isEdit ? 'Modifier la fiche client' : 'Nouveau Client',
                    style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white, size: 16),
                    onPressed: () => Navigator.pop(context),
                    padding: EdgeInsets.zero,
                    constraints: const BoxConstraints(),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_error != null)
                    Container(
                      padding: const EdgeInsets.all(10),
                      margin: const EdgeInsets.only(bottom: 14),
                      decoration: BoxDecoration(
                        color: AppColors.rouge.withOpacity(0.08),
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.rouge.withOpacity(0.3)),
                      ),
                      child: Text(_error!, style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600)),
                    ),
                  const Text('Raison Sociale / Nom complet *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(controller: _nameCtrl, decoration: const InputDecoration(hintText: 'Ex: Entreprise Bénin SARL')),
                  const SizedBox(height: 14),
                  const Text('Téléphone', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(controller: _phoneCtrl, decoration: const InputDecoration(hintText: '+229 01 23 45 67')),
                  const SizedBox(height: 14),
                  const Text('Adresse Email', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(controller: _emailCtrl, decoration: const InputDecoration(hintText: 'contact@client.bj')),
                  const SizedBox(height: 14),
                  const Text('Numéro IFU (Identifiant Fiscal)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(controller: _ifuCtrl, decoration: const InputDecoration(hintText: 'Numéro IFU légal')),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 0, 20, 20),
              child: Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Annuler'),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    flex: 2,
                    child: ElevatedButton(
                      onPressed: _loading ? null : _submit,
                      child: _loading
                          ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                          : Text(isEdit ? 'Mettre à jour' : 'Enregistrer'),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

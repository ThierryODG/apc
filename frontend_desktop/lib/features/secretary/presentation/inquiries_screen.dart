import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';
import '../../../models/customer.dart';

class InquiriesScreen extends StatefulWidget {
  const InquiriesScreen({super.key});

  @override
  State<InquiriesScreen> createState() => _InquiriesScreenState();
}

class _InquiriesScreenState extends State<InquiriesScreen> {
  List<Map<String, dynamic>> _inquiries = [];
  bool _loading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryInquiries);
      final list = ApiClient.extractList(res, 'inquiries');
      setState(() {
        _inquiries = list.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  Future<void> _openNewInquiryDialog() async {
    final ok = await showDialog<bool>(
      context: context,
      builder: (ctx) => const _NewInquiryDialog(),
    );
    if (ok == true) _load();
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return '$thousands ${remainder.toString().padLeft(3, '0')} F';
    }
    return '$n F';
  }

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
                  color: AppColors.bleu.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: const Icon(Icons.request_quote_rounded, size: 18, color: AppColors.bleu),
              ),
              const SizedBox(width: 12),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Demandes de Devis & Proformas', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                  Text('Recueil des besoins clients transmis à la Comptabilité', style: TextStyle(fontSize: 11, color: AppColors.gris)),
                ],
              ),
              const Spacer(),
              ElevatedButton.icon(
                onPressed: _openNewInquiryDialog,
                icon: const Icon(Icons.add_rounded, size: 16),
                label: const Text('Créer une demande de devis', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w800)),
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.bleu,
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                ),
              ),
            ],
          ),
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _inquiries.isEmpty
                      ? const Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.request_quote_outlined, size: 48, color: AppColors.bord),
                              SizedBox(height: 10),
                              Text('Aucune demande de devis pour le moment.', style: TextStyle(color: AppColors.gris, fontSize: 13)),
                            ],
                          ),
                        )
                      : ListView.separated(
                          padding: const EdgeInsets.all(20),
                          itemCount: _inquiries.length,
                          separatorBuilder: (_, __) => const SizedBox(height: 10),
                          itemBuilder: (_, i) {
                            final inq = _inquiries[i];
                            final status = inq['status'] ?? 'pending';
                            final isConverted = status == 'converted' || status == 'completed';

                            return Container(
                              padding: const EdgeInsets.all(16),
                              decoration: BoxDecoration(
                                color: AppColors.blanc,
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.bord),
                              ),
                              child: Row(
                                children: [
                                  Container(
                                    width: 40,
                                    height: 40,
                                    decoration: BoxDecoration(
                                      color: (isConverted ? AppColors.vert : AppColors.orange).withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(8),
                                    ),
                                    child: Icon(
                                      isConverted ? Icons.check_circle_outline_rounded : Icons.pending_actions_rounded,
                                      size: 20,
                                      color: isConverted ? AppColors.vert : AppColors.orange,
                                    ),
                                  ),
                                  const SizedBox(width: 14),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Text(
                                              inq['quote_number'] ?? '#${inq['id']}',
                                              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bleu),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              inq['title'] ?? 'Demande de devis',
                                              style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w800),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Client : ${inq['customer']?['name'] ?? 'Client inconnu'} ${inq['customer']?['phone'] != null ? '(${inq['customer']['phone']})' : ''}',
                                          style: const TextStyle(fontSize: 11, color: AppColors.gris),
                                        ),
                                        if (inq['description'] != null && inq['description'].toString().isNotEmpty) ...[
                                          const SizedBox(height: 2),
                                          Text(
                                            inq['description'],
                                            style: const TextStyle(fontSize: 11, color: AppColors.texte),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ],
                                      ],
                                    ),
                                  ),
                                  const SizedBox(width: 16),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        _fmt(inq['estimated_amount']),
                                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu),
                                      ),
                                      const SizedBox(height: 4),
                                      Container(
                                        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                        decoration: BoxDecoration(
                                          color: (isConverted ? AppColors.vert : AppColors.orange).withOpacity(0.1),
                                          borderRadius: BorderRadius.circular(10),
                                        ),
                                        child: Text(
                                          isConverted ? 'Validé en Commande' : 'En attente Chiffrage Compta',
                                          style: TextStyle(
                                            fontSize: 10,
                                            fontWeight: FontWeight.w800,
                                            color: isConverted ? AppColors.vert : AppColors.orange,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}

class _NewInquiryDialog extends StatefulWidget {
  const _NewInquiryDialog();

  @override
  State<_NewInquiryDialog> createState() => _NewInquiryDialogState();
}

class _NewInquiryDialogState extends State<_NewInquiryDialog> {
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _amountCtrl = TextEditingController();
  List<Customer> _customers = [];
  Customer? _selectedCustomer;
  bool _loading = false;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadCustomers();
  }

  Future<void> _loadCustomers() async {
    try {
      final res = await ApiClient().get(ApiEndpoints.secretaryCustomers);
      final list = ApiClient.extractList(res, 'customers');
      setState(() {
        _customers = list.map((c) => Customer.fromJson(c as Map<String, dynamic>)).toList();
        if (_customers.isNotEmpty) _selectedCustomer = _customers.first;
      });
    } catch (_) {}
  }

  Future<void> _submit() async {
    if (_titleCtrl.text.trim().isEmpty || _selectedCustomer == null) {
      setState(() => _error = 'Client et objet du devis sont obligatoires.');
      return;
    }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.secretaryInquiries, {
        'customer_id': _selectedCustomer!.id,
        'title': _titleCtrl.text.trim(),
        'description': _descCtrl.text.trim(),
        'estimated_amount': double.tryParse(_amountCtrl.text.trim()) ?? 0.0,
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
        width: 460,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: const BoxDecoration(
                color: AppColors.bleu,
                borderRadius: BorderRadius.vertical(top: Radius.circular(10)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.request_quote_rounded, color: Colors.white, size: 18),
                  const SizedBox(width: 8),
                  const Text('Nouvelle Demande de Devis', style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900)),
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
                      margin: const EdgeInsets.only(bottom: 12),
                      decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.08), borderRadius: BorderRadius.circular(6)),
                      child: Text(_error!, style: const TextStyle(color: AppColors.rouge, fontSize: 12)),
                    ),
                  const Text('Client demandeur *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  if (_customers.isEmpty)
                    const Text('Chargement des clients…', style: TextStyle(fontSize: 12, color: AppColors.gris))
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(border: Border.all(color: AppColors.bord), borderRadius: BorderRadius.circular(6)),
                      child: DropdownButtonHideUnderline(
                        child: DropdownButton<Customer>(
                          value: _selectedCustomer,
                          isExpanded: true,
                          items: _customers.map((c) => DropdownMenuItem(
                            value: c,
                            child: Text('${c.name} (${c.code})', style: const TextStyle(fontSize: 13)),
                          )).toList(),
                          onChanged: (v) => setState(() => _selectedCustomer = v),
                        ),
                      ),
                    ),
                  const SizedBox(height: 14),
                  const Text('Objet / Prestation demandée *', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(controller: _titleCtrl, decoration: const InputDecoration(hintText: 'Ex: Impression 5000 Dépliants 3 volets')),
                  const SizedBox(height: 14),
                  const Text('Détails techniques & spécifications', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _descCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(hintText: 'Grammage, dimensions, finitions souhaitées…'),
                  ),
                  const SizedBox(height: 14),
                  const Text('Montant indicatif ou budget estimé (FCFA)', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu)),
                  const SizedBox(height: 6),
                  TextField(
                    controller: _amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(hintText: '0', suffixText: 'FCFA'),
                  ),
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
                          : const Text('Transmettre à la Compta'),
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

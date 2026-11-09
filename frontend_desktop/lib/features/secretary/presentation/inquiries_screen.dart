import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

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
      final List data = res['data'] ?? res['inquiries'] ?? [];
      setState(() {
        _inquiries = data.cast<Map<String, dynamic>>();
        _loading = false;
      });
    } catch (e) {
      setState(() { _error = e.toString(); _loading = false; });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        _ScreenHeader(
          title: 'Devis & Demandes',
          icon: Icons.request_quote_rounded,
          actionLabel: '+ Nouvelle demande',
          onAction: () {}, // TODO
        ),
        Expanded(
          child: _loading
              ? const Center(child: CircularProgressIndicator())
              : _error != null
                  ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
                  : _inquiries.isEmpty
                      ? const Center(child: Text('Aucune demande.', style: TextStyle(color: AppColors.gris)))
                      : ListView.builder(
                          padding: const EdgeInsets.all(16),
                          itemCount: _inquiries.length,
                          itemBuilder: (_, i) {
                            final inq = _inquiries[i];
                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                leading: Container(
                                  width: 36,
                                  height: 36,
                                  decoration: BoxDecoration(
                                    color: AppColors.orange.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(8),
                                  ),
                                  child: const Icon(Icons.request_quote_rounded, size: 18, color: AppColors.orange),
                                ),
                                title: Text(inq['subject'] ?? 'Demande #${inq['id']}',
                                    style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700)),
                                subtitle: Text(inq['customer']?['name'] ?? 'Client inconnu',
                                    style: const TextStyle(fontSize: 11)),
                                trailing: _StatusBadge(
                                  label: inq['status'] ?? 'pending',
                                  color: inq['status'] == 'completed' ? AppColors.vert : AppColors.orange,
                                ),
                              ),
                            );
                          },
                        ),
        ),
      ],
    );
  }
}



// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14),
    decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))),
    child: Row(children: [
      Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)),
      const SizedBox(width: 12),
      Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)),
      const SizedBox(width: 20),
      if (child != null) Expanded(child: child!) else const Spacer(),
      if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700))),
    ]),
  );
}

class _StatusBadge extends StatelessWidget {
  final String label; final Color color; const _StatusBadge({required this.label, required this.color});
  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
    decoration: BoxDecoration(color: color.withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: color.withOpacity(0.3))),
    child: Text(label, style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: color)),
  );
}

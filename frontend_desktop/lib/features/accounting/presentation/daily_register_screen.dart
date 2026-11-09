import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class DailyRegisterScreen extends StatefulWidget {
  const DailyRegisterScreen({super.key});
  @override State<DailyRegisterScreen> createState() => _DailyRegisterScreenState();
}

class _DailyRegisterScreenState extends State<DailyRegisterScreen> {
  Map<String, dynamic>? _register;
  bool _loading = true; String? _error;
  bool _actionLoading = false;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.dailyRegisterCurrent);
      setState(() { _register = res['register']; _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  Future<void> _openRegister() async {
    final amountCtrl = TextEditingController(text: '0');
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: const Row(
          children: [
            Icon(Icons.lock_open_rounded, color: AppColors.vert, size: 20),
            SizedBox(width: 8),
            Text('Ouverture de caisse', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800)),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Indiquez le fond de caisse initial en espèces pour aujourd\'hui :',
              style: TextStyle(fontSize: 12, color: AppColors.gris),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: amountCtrl,
              keyboardType: const TextInputType.numberWithOptions(decimal: true),
              autofocus: true,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800),
              decoration: const InputDecoration(
                labelText: 'Fond de caisse initial',
                suffixText: 'FCFA',
              ),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          ElevatedButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vert),
            child: const Text('Ouvrir la session'),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() => _actionLoading = true);
    try {
      final initialBalance = double.tryParse(amountCtrl.text.replaceAll(',', '.').trim()) ?? 0.0;
      await ApiClient().post(ApiEndpoints.dailyRegisterOpen, {
        'opening_balance': initialBalance,
      });
      await _load();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Session de caisse ouverte avec succès.'), backgroundColor: AppColors.vert),
        );
      }
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
    } finally { setState(() => _actionLoading = false); }
  }

  Future<void> _closeRegister() async {
    final confirm = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Clôture de caisse', style: TextStyle(fontWeight: FontWeight.w900)),
      content: const Text('Voulez-vous clôturer la caisse ? Cette action génère un rapport Z et ferme la journée.'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
        ElevatedButton(
          onPressed: () => Navigator.pop(ctx, true),
          style: ElevatedButton.styleFrom(backgroundColor: AppColors.rouge),
          child: const Text('Clôturer', style: TextStyle(color: Colors.white)),
        ),
      ],
    ));
    if (confirm != true) return;
    setState(() => _actionLoading = true);
    try {
      await ApiClient().post(ApiEndpoints.dailyRegisterClose, {});
      await _load();
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Caisse clôturée. Rapport Z généré.'), backgroundColor: AppColors.vert));
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
    } finally { setState(() => _actionLoading = false); }
  }

  String _fmt(dynamic v) {
    final n = (double.tryParse('$v') ?? 0).toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')} FCFA';
    return '$n FCFA';
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Clôture de Caisse (Z-Report)', icon: Icons.lock_clock_rounded),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : Center(child: SizedBox(width: 560, child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [

                // Statut de la caisse
                _RegisterStatusCard(register: _register, onOpen: _openRegister, onClose: _closeRegister, loading: _actionLoading),
                const SizedBox(height: 24),

                if (_register != null) ...[
                  // Résumé de la journée
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(10), border: Border.all(color: AppColors.bord)),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                      const Text('RÉSUMÉ DE LA JOURNÉE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bleu, letterSpacing: 0.5)),
                      const SizedBox(height: 16),
                      _ZReportRow(label: 'Nombre de ventes', value: '${_register!['sales_count'] ?? 0}'),
                      _ZReportRow(label: 'CA espèces', value: _fmt(_register!['cash_sales'] ?? 0)),
                      _ZReportRow(label: 'CA Mobile Money', value: _fmt(_register!['mobile_money_sales'] ?? 0)),
                      _ZReportRow(label: 'CA virement', value: _fmt(_register!['bank_transfer_sales'] ?? 0)),
                      const Divider(height: 24, color: AppColors.bord),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('TOTAL CA DU JOUR', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                        Text(_fmt(_register!['total_sales'] ?? 0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                      ]),
                      const SizedBox(height: 8),
                      _ZReportRow(label: 'Dépenses du jour', value: '- ${_fmt(_register!['total_expenses'] ?? 0)}', valueColor: AppColors.rouge),
                      const Divider(height: 24, color: AppColors.bord),
                      Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                        const Text('SOLDE NET', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w900, color: AppColors.vert)),
                        Text(_fmt(_register!['net_balance'] ?? 0), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: AppColors.vert)),
                      ]),
                    ]),
                  ),
                ],
              ]))),
      ),
    ]);
  }
}

class _RegisterStatusCard extends StatelessWidget {
  final Map<String, dynamic>? register;
  final VoidCallback onOpen; final VoidCallback onClose; final bool loading;
  const _RegisterStatusCard({required this.register, required this.onOpen, required this.onClose, required this.loading});

  @override
  Widget build(BuildContext context) {
    final isOpen = register?['status'] == 'open';
    final isClosed = register?['status'] == 'closed';
    final noRegister = register == null;

    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: AppColors.blanc,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: isOpen ? AppColors.vert : AppColors.bord, width: isOpen ? 2 : 1),
      ),
      child: Column(children: [
        Icon(isOpen ? Icons.lock_open_rounded : Icons.lock_rounded, size: 48, color: isOpen ? AppColors.vert : AppColors.gris),
        const SizedBox(height: 12),
        Text(
          noRegister ? 'Aucune caisse ouverte' : isOpen ? 'Caisse ouverte' : 'Caisse clôturée',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: isOpen ? AppColors.vert : AppColors.gris),
        ),
        const SizedBox(height: 6),
        Text(
          noRegister ? 'Ouvrez la caisse pour démarrer la journée.' : isOpen ? 'La caisse est active. Clôturez en fin de journée.' : 'Journée terminée. Ouvrez demain pour reprendre.',
          textAlign: TextAlign.center, style: const TextStyle(fontSize: 12, color: AppColors.gris),
        ),
        const SizedBox(height: 20),
        if (noRegister || isClosed)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: loading ? null : onOpen,
            icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_open_rounded, size: 16),
            label: const Text('OUVRIR LA CAISSE', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.vert, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          ))
        else if (isOpen)
          SizedBox(width: double.infinity, child: ElevatedButton.icon(
            onPressed: loading ? null : onClose,
            icon: loading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : const Icon(Icons.lock_rounded, size: 16),
            label: const Text('CLÔTURER LA CAISSE', style: TextStyle(fontWeight: FontWeight.w900)),
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.rouge, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 14), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8))),
          )),
      ]),
    );
  }
}

class _ZReportRow extends StatelessWidget {
  final String label; final String value; final Color? valueColor;
  const _ZReportRow({required this.label, required this.value, this.valueColor});
  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.symmetric(vertical: 4),
    child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
      Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gris)),
      Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.texte)),
    ]),
  );
}

// ─── Widget local ─────────────────────────────────────────────────────────────

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


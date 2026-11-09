import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/network/api_client.dart';
import '../../../core/constants/api_endpoints.dart';

class UsersScreen extends StatefulWidget {
  const UsersScreen({super.key});
  @override State<UsersScreen> createState() => _UsersScreenState();
}

class _UsersScreenState extends State<UsersScreen> {
  List<Map<String, dynamic>> _users = [];
  bool _loading = true; String? _error;

  @override
  void initState() { super.initState(); _load(); }

  Future<void> _load() async {
    setState(() { _loading = true; _error = null; });
    try {
      final res = await ApiClient().get(ApiEndpoints.adminUsers);
      final List data = res['data'] ?? res['users'] ?? [];
      setState(() { _users = data.cast<Map<String, dynamic>>(); _loading = false; });
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  Future<void> _openCreate() async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => const _CreateUserDialog());
    if (ok == true) _load();
  }

  Future<void> _toggleActive(int id, bool currentlyActive) async {
    try {
      await ApiClient().patch('${ApiEndpoints.adminUsers}/$id/toggle-active');
      _load();
    } catch (e) {
      if (mounted) ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Erreur: $e'), backgroundColor: AppColors.rouge));
    }
  }

  String _roleLabel(String? role) {
    switch (role) { case 'admin': return 'Administrateur'; case 'secretary': return 'Secrétaire'; case 'accounting': return 'Comptable'; default: return role ?? '—'; }
  }

  Color _roleColor(String? role) {
    switch (role) { case 'admin': return AppColors.bleu; case 'secretary': return AppColors.orange; case 'accounting': return AppColors.vert; default: return AppColors.gris; }
  }

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      _ScreenHeader(title: 'Gestion des Utilisateurs', icon: Icons.manage_accounts_rounded, actionLabel: '+ Nouvel utilisateur', onAction: _openCreate),
      Expanded(
        child: _loading ? const Center(child: CircularProgressIndicator())
            : _error != null ? Center(child: Text(_error!, style: const TextStyle(color: AppColors.rouge)))
            : _users.isEmpty ? const Center(child: Text('Aucun utilisateur.', style: TextStyle(color: AppColors.gris)))
            : Padding(padding: const EdgeInsets.all(16), child: Container(
              decoration: BoxDecoration(color: AppColors.blanc, borderRadius: BorderRadius.circular(8), border: Border.all(color: AppColors.bord)),
              child: Column(children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  decoration: const BoxDecoration(color: Color(0xFFF8FAFC), border: Border(bottom: BorderSide(color: AppColors.bord)), borderRadius: BorderRadius.vertical(top: Radius.circular(8))),
                  child: const Row(children: [
                    Expanded(flex: 3, child: _ColHeader('NOM')),
                    Expanded(flex: 3, child: _ColHeader('EMAIL')),
                    Expanded(flex: 2, child: _ColHeader('RÔLE')),
                    Expanded(flex: 2, child: _ColHeader('STATUT')),
                    Expanded(flex: 2, child: _ColHeader('ACTION')),
                  ]),
                ),
                Expanded(child: ListView.separated(
                  itemCount: _users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                  itemBuilder: (ctx, i) {
                    final u = _users[i];
                    final isActive = u['is_active'] == true || u['active'] == true;
                    final role = u['role'] as String?;
                    return Padding(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10), child: Row(children: [
                      Expanded(flex: 3, child: Row(children: [
                        CircleAvatar(radius: 15, backgroundColor: _roleColor(role).withOpacity(0.1), child: Text((u['name'] ?? 'U').substring(0, 1).toUpperCase(), style: TextStyle(fontSize: 11, fontWeight: FontWeight.w900, color: _roleColor(role)))),
                        const SizedBox(width: 10),
                        Expanded(child: Text(u['name'] ?? '—', style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700), overflow: TextOverflow.ellipsis)),
                      ])),
                      Expanded(flex: 3, child: Text(u['email'] ?? '—', style: const TextStyle(fontSize: 11, color: AppColors.gris), overflow: TextOverflow.ellipsis)),
                      Expanded(flex: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: _roleColor(role).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: _roleColor(role).withOpacity(0.3))), child: Text(_roleLabel(role), style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: _roleColor(role))))),
                      Expanded(flex: 2, child: Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3), decoration: BoxDecoration(color: (isActive ? AppColors.vert : AppColors.rouge).withOpacity(0.1), borderRadius: BorderRadius.circular(10), border: Border.all(color: (isActive ? AppColors.vert : AppColors.rouge).withOpacity(0.3))), child: Text(isActive ? 'Actif' : 'Désactivé', style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: isActive ? AppColors.vert : AppColors.rouge)))),
                      Expanded(flex: 2, child: TextButton(
                        onPressed: () => _toggleActive(u['id'], isActive),
                        child: Text(isActive ? 'Désactiver' : 'Activer', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: isActive ? AppColors.rouge : AppColors.vert)),
                      )),
                    ]));
                  },
                )),
              ]),
            )),
      ),
    ]);
  }
}

class _CreateUserDialog extends StatefulWidget {
  const _CreateUserDialog();
  @override State<_CreateUserDialog> createState() => _CreateUserDialogState();
}

class _CreateUserDialogState extends State<_CreateUserDialog> {
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  String _role = 'secretary';
  bool _loading = false; String? _error;

  Future<void> _submit() async {
    if (_nameCtrl.text.trim().isEmpty || _emailCtrl.text.trim().isEmpty || _passCtrl.text.isEmpty) { setState(() => _error = 'Nom, email et mot de passe sont requis.'); return; }
    setState(() { _loading = true; _error = null; });
    try {
      await ApiClient().post(ApiEndpoints.adminUsers, { 'name': _nameCtrl.text.trim(), 'email': _emailCtrl.text.trim(), 'password': _passCtrl.text, 'role': _role });
      if (mounted) Navigator.pop(context, true);
    } catch (e) { setState(() { _error = e.toString(); _loading = false; }); }
  }

  @override
  Widget build(BuildContext context) => Dialog(
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
    child: SizedBox(width: 400, child: Column(mainAxisSize: MainAxisSize.min, children: [
      _DialogHeader(title: 'Nouvel Utilisateur', icon: Icons.person_add_rounded),
      Padding(padding: const EdgeInsets.all(20), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        if (_error != null) _ErrorBanner(_error!),
        const _FieldLabel('Nom complet *'), _Input(controller: _nameCtrl, hint: 'Prénom Nom'),
        const SizedBox(height: 14),
        const _FieldLabel('Email *'), _Input(controller: _emailCtrl, hint: 'email@africaprint.com'),
        const SizedBox(height: 14),
        const _FieldLabel('Mot de passe *'), _Input(controller: _passCtrl, hint: '••••••••'),
        const SizedBox(height: 14),
        const _FieldLabel('Rôle *'),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          decoration: BoxDecoration(border: Border.all(color: AppColors.bord), borderRadius: BorderRadius.circular(6)),
          child: DropdownButtonHideUnderline(child: DropdownButton<String>(
            value: _role, isExpanded: true,
            items: const [
              DropdownMenuItem(value: 'secretary', child: Text('Secrétaire', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'accounting', child: Text('Comptable', style: TextStyle(fontSize: 13))),
              DropdownMenuItem(value: 'admin', child: Text('Administrateur', style: TextStyle(fontSize: 13))),
            ],
            onChanged: (v) => setState(() => _role = v ?? 'secretary'),
          )),
        ),
      ])),
      _DialogActions(onConfirm: _loading ? null : _submit, isLoading: _loading),
    ])),
  );
}

// ─── Widgets locaux ──────────────────────────────────────────────────────────

class _ScreenHeader extends StatelessWidget {
  final String title; final IconData icon; final String? actionLabel; final VoidCallback? onAction; final Widget? child;
  const _ScreenHeader({required this.title, required this.icon, this.actionLabel, this.onAction, this.child});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 14), decoration: const BoxDecoration(color: AppColors.blanc, border: Border(bottom: BorderSide(color: AppColors.bord))), child: Row(children: [Container(width: 34, height: 34, decoration: BoxDecoration(color: AppColors.bleu.withOpacity(0.1), borderRadius: BorderRadius.circular(8)), child: Icon(icon, size: 18, color: AppColors.bleu)), const SizedBox(width: 12), Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w900, color: AppColors.bleu)), const SizedBox(width: 20), if (child != null) Expanded(child: child!) else const Spacer(), if (actionLabel != null && onAction != null) ElevatedButton(onPressed: onAction, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)), elevation: 0), child: Text(actionLabel!, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)))]));
}

class _ColHeader extends StatelessWidget {
  final String label; const _ColHeader(this.label);
  @override Widget build(BuildContext context) => Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w900, color: AppColors.gris, letterSpacing: 0.5));
}

class _DialogHeader extends StatelessWidget {
  final String title; final IconData icon;
  const _DialogHeader({required this.title, required this.icon});
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14), decoration: const BoxDecoration(color: AppColors.bleu, borderRadius: BorderRadius.vertical(top: Radius.circular(10))), child: Row(children: [Icon(icon, color: Colors.white, size: 18), const SizedBox(width: 10), Expanded(child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w900))), IconButton(icon: const Icon(Icons.close, color: Colors.white, size: 16), onPressed: () => Navigator.pop(context), padding: EdgeInsets.zero, constraints: const BoxConstraints())]));
}

class _ErrorBanner extends StatelessWidget {
  final String message; const _ErrorBanner(this.message);
  @override Widget build(BuildContext context) => Container(padding: const EdgeInsets.all(10), margin: const EdgeInsets.only(bottom: 14), decoration: BoxDecoration(color: AppColors.rouge.withOpacity(0.1), borderRadius: BorderRadius.circular(6), border: Border.all(color: AppColors.rouge.withOpacity(0.3))), child: Text(message, style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600)));
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

class _DialogActions extends StatelessWidget {
  final VoidCallback? onConfirm; final String confirmLabel; final bool isLoading;
  const _DialogActions({this.onConfirm, this.confirmLabel = 'Enregistrer', this.isLoading = false});
  @override Widget build(BuildContext context) => Padding(padding: const EdgeInsets.fromLTRB(20, 0, 20, 20), child: Row(children: [Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), style: OutlinedButton.styleFrom(foregroundColor: AppColors.gris, side: const BorderSide(color: AppColors.bord), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: const Text('Annuler'))), const SizedBox(width: 10), Expanded(flex: 2, child: ElevatedButton(onPressed: isLoading ? null : onConfirm, style: ElevatedButton.styleFrom(backgroundColor: AppColors.orange, foregroundColor: Colors.white, padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6))), child: isLoading ? const SizedBox(width: 16, height: 16, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white)) : Text(confirmLabel, style: const TextStyle(fontWeight: FontWeight.w700))))]));
}


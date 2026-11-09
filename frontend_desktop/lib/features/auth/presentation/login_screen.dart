import 'package:flutter/material.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/state/auth_state.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailCtrl = TextEditingController(text: 'secretaire@africaprint.com');
  final _passCtrl = TextEditingController(text: 'secretariat123');
  bool _isLoading = false;
  String? _errorMessage;

  Future<void> _submit() async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });

    try {
      final success = await AuthState().login(
        _emailCtrl.text.trim(),
        _passCtrl.text,
      );
      if (!success && mounted) {
        setState(() => _errorMessage = 'Identifiants incorrects.');
      }
    } catch (e) {
      if (mounted) {
        setState(() => _errorMessage = e.toString());
      }
    } finally {
      if (mounted) {
        setState(() => _isLoading = false);
      }
    }
  }

  void _fillPreset(String email, String pass) {
    _emailCtrl.text = email;
    _passCtrl.text = pass;
    setState(() => _errorMessage = null);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fond,
      body: Center(
        child: Container(
          width: 440,
          padding: const EdgeInsets.all(32),
          decoration: BoxDecoration(
            color: AppColors.blanc,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.bord),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.06),
                blurRadius: 20,
                offset: const Offset(0, 8),
              ),
            ],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Logo & Marque
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: AppColors.bleu,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Icon(Icons.print_rounded, color: AppColors.orange, size: 28),
                  ),
                  const SizedBox(width: 12),
                  RichText(
                    text: const TextSpan(
                      text: 'AFRICA',
                      style: TextStyle(
                        color: AppColors.bleu,
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                      children: [
                        TextSpan(
                          text: 'PRINT',
                          style: TextStyle(color: AppColors.orange),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              const Text(
                'Logiciel de Gestion d\'Imprimerie (AroNium Edition)',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 12, color: AppColors.gris, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 28),

              if (_errorMessage != null)
                Container(
                  padding: const EdgeInsets.all(10),
                  margin: const EdgeInsets.only(bottom: 16),
                  decoration: BoxDecoration(
                    color: AppColors.rouge.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.rouge.withOpacity(0.3)),
                  ),
                  child: Text(
                    _errorMessage!,
                    style: const TextStyle(color: AppColors.rouge, fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                ),

              // Champ Email
              const Text(
                'ADRESSE E-MAIL',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _emailCtrl,
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.email_outlined, size: 18, color: AppColors.gris),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.bord),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 16),

              // Champ Mot de passe
              const Text(
                'MOT DE PASSE',
                style: TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: AppColors.bleu),
              ),
              const SizedBox(height: 6),
              TextField(
                controller: _passCtrl,
                obscureText: true,
                onSubmitted: (_) => _submit(),
                decoration: InputDecoration(
                  prefixIcon: const Icon(Icons.lock_outline, size: 18, color: AppColors.gris),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(6),
                    borderSide: const BorderSide(color: AppColors.bord),
                  ),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                ),
              ),
              const SizedBox(height: 24),

              // Bouton Se connecter
              ElevatedButton(
                onPressed: _isLoading ? null : _submit,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.orange,
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                  elevation: 0,
                ),
                child: _isLoading
                    ? const SizedBox(width: 20, height: 20, child: CircularProgressIndicator(strokeWidth: 2, color: Colors.white))
                    : const Text('SE CONNECTER', style: TextStyle(fontWeight: FontWeight.w800, letterSpacing: 0.5)),
              ),
              const SizedBox(height: 24),

              // Raccourcis profils de test
              const Text(
                'Comptes de démonstration rapide :',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 11, color: AppColors.gris),
              ),
              const SizedBox(height: 8),
              Wrap(
                alignment: WrapAlignment.center,
                spacing: 6,
                runSpacing: 6,
                children: [
                  _PresetChip(label: 'Secrétaire', onTap: () => _fillPreset('secretaire@africaprint.com', 'secretariat123')),
                  _PresetChip(label: 'Comptable', onTap: () => _fillPreset('comptable@africaprint.com', 'compta123')),
                  _PresetChip(label: 'Directeur', onTap: () => _fillPreset('admin@africaprint.com', 'admin123')),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PresetChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;

  const _PresetChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.fond,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: AppColors.bord),
        ),
        child: Text(
          label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.bleu),
        ),
      ),
    );
  }
}


import 'package:flutter/material.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, required this.onLogin, required this.loading});

  final Future<void> Function(String, String) onLogin;
  final bool loading;

  @override
  State<LoginScreen> createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();
  bool _obscure = true;

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, bounds) {
          final wide = bounds.maxWidth >= 900;
          return Row(
            children: [
              if (wide) const Expanded(flex: 11, child: BrandPanel()),
              Expanded(
                flex: wide ? 9 : 1,
                child: ColoredBox(
                  color: ApcPalette.paper,
                  child: Center(
                    child: SingleChildScrollView(
                      padding: EdgeInsets.symmetric(
                        horizontal: wide ? 70 : 26,
                        vertical: 34,
                      ),
                      child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 430),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            if (!wide) ...[
                              Container(
                                height: 74,
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(6),
                                ),
                                child: Image.asset(
                                  'assets/brand/apc-logo.png',
                                  fit: BoxFit.contain,
                                  alignment: Alignment.centerLeft,
                                ),
                              ),
                              const SizedBox(height: 48),
                            ],
                            const Eyebrow('ESPACE ÉQUIPE · APC'),
                            const SizedBox(height: 14),
                            Text(
                              'Le travail bien\nimprimé commence ici.',
                              style: Theme.of(context).textTheme.headlineLarge,
                            ),
                            const SizedBox(height: 14),
                            const Text(
                              'Connecte-toi pour retrouver le catalogue, les clients et les demandes en cours.',
                            ),
                            const SizedBox(height: 34),
                            Form(
                              key: _formKey,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  TextFormField(
                                    controller: _email,
                                    keyboardType: TextInputType.emailAddress,
                                    autofillHints: const [
                                      AutofillHints.username,
                                      AutofillHints.email,
                                    ],
                                    decoration: const InputDecoration(
                                      labelText: 'Adresse email',
                                      prefixIcon: Icon(Icons.alternate_email),
                                    ),
                                    validator: (value) =>
                                        value == null || !value.contains('@')
                                        ? 'Saisis une adresse email valide.'
                                        : null,
                                  ),
                                  const SizedBox(height: 13),
                                  TextFormField(
                                    controller: _password,
                                    obscureText: _obscure,
                                    autofillHints: const [
                                      AutofillHints.password,
                                    ],
                                    onFieldSubmitted: (_) => _submit(),
                                    decoration: InputDecoration(
                                      labelText: 'Mot de passe',
                                      prefixIcon: const Icon(
                                        Icons.lock_outline,
                                      ),
                                      suffixIcon: IconButton(
                                        tooltip: _obscure
                                            ? 'Afficher le mot de passe'
                                            : 'Masquer le mot de passe',
                                        onPressed: () => setState(
                                          () => _obscure = !_obscure,
                                        ),
                                        icon: Icon(
                                          _obscure
                                              ? Icons.visibility_outlined
                                              : Icons.visibility_off_outlined,
                                        ),
                                      ),
                                    ),
                                    validator: (value) =>
                                        value == null || value.isEmpty
                                        ? 'Le mot de passe est obligatoire.'
                                        : null,
                                  ),
                                  const SizedBox(height: 22),
                                  SizedBox(
                                    height: 52,
                                    child: FilledButton.icon(
                                      onPressed: widget.loading
                                          ? null
                                          : _submit,
                                      icon: widget.loading
                                          ? const SizedBox.square(
                                              dimension: 17,
                                              child: CircularProgressIndicator(
                                                strokeWidth: 2,
                                              ),
                                            )
                                          : const Icon(
                                              Icons.arrow_forward_rounded,
                                            ),
                                      label: Text(
                                        widget.loading
                                            ? 'Connexion…'
                                            : 'Ouvrir mon espace',
                                      ),
                                      style: FilledButton.styleFrom(
                                        backgroundColor: ApcPalette.ink,
                                        foregroundColor: Colors.white,
                                        shape: RoundedRectangleBorder(
                                          borderRadius: BorderRadius.circular(
                                            6,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(height: 25),
                            const Row(
                              children: [
                                Icon(
                                  Icons.shield_outlined,
                                  size: 17,
                                  color: ApcPalette.muted,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Connexion sécurisée · Les accès suivent ton rôle.',
                                    style: TextStyle(
                                      color: ApcPalette.muted,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );
  }

  void _submit() {
    if (_formKey.currentState?.validate() ?? false) {
      widget.onLogin(_email.text.trim(), _password.text);
    }
  }
}

class BrandPanel extends StatelessWidget {
  const BrandPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final compact = constraints.maxHeight < 680;
        return Container(
          color: ApcPalette.ink,
          child: Stack(
            children: [
              Positioned(
                right: -80,
                top: -90,
                child: PrintDisc(
                  size: 350,
                  color: ApcPalette.blue.withValues(alpha: .42),
                ),
              ),
              Positioned(
                left: -120,
                bottom: -120,
                child: PrintDisc(
                  size: 390,
                  color: ApcPalette.orange.withValues(alpha: .95),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(compact ? 28 : 54),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Container(
                      width: compact ? 250 : 285,
                      height: compact ? 84 : 115,
                      padding: const EdgeInsets.symmetric(horizontal: 12),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(5),
                      ),
                      child: Image.asset(
                        'assets/brand/apc-logo.png',
                        fit: BoxFit.contain,
                      ),
                    ),
                    const Spacer(),
                    const Eyebrow(
                      'ATELIER · COMMUNICATION · IMPRESSION',
                      light: true,
                    ),
                    SizedBox(height: compact ? 10 : 20),
                    Text(
                      'Des idées\nqui prennent\nforme.',
                      style: TextStyle(
                        fontFamily: 'Georgia',
                        fontSize: compact ? 42 : 58,
                        height: 1.04,
                        color: Colors.white,
                      ),
                    ),
                    SizedBox(height: compact ? 12 : 22),
                    Container(width: 54, height: 5, color: ApcPalette.orange),
                    SizedBox(height: compact ? 12 : 20),
                    Text(
                      'Une seule équipe. Tous les ateliers. Chaque détail compte.',
                      style: TextStyle(
                        color: const Color(0xFFC4D0CF),
                        fontSize: compact ? 13 : 15,
                      ),
                    ),
                    const Spacer(),
                    const Text(
                      'AFRICA PRINT COMMUNICATION',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        letterSpacing: 1.2,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

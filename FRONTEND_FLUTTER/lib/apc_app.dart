import 'package:flutter/material.dart';

import 'data/apc_api.dart';

const _ink = Color(0xFF15343E);
const _blue = Color(0xFF0878B9);
const _orange = Color(0xFFF15A24);
const _paper = Color(0xFFF4F2EC);
const _line = Color(0xFFE2E0D9);
const _muted = Color(0xFF727D7E);

class ApcApp extends StatefulWidget {
  const ApcApp({super.key, this.api});

  final ApcApi? api;

  @override
  State<ApcApp> createState() => _ApcAppState();
}

class _ApcAppState extends State<ApcApp> {
  late final ApcApi _api = widget.api ?? ApcApi();
  Map<String, dynamic>? _user;
  List<Map<String, dynamic>> _catalog = [];
  List<Map<String, dynamic>> _customers = [];
  List<Map<String, dynamic>> _inquiries = [];
  Map<String, dynamic> _customerStats = {};
  String? _loadError;
  int _section = 0;
  bool _loading = false;

  Future<void> _signIn(String email, String password) async {
    setState(() => _loading = true);
    try {
      final user = await _api.login(email: email, password: password);
      if (!mounted) return;
      setState(() {
        _user = user;
        _section = 0;
        _loadError = null;
      });
      await _refresh();
    } on ApiException catch (error) {
      if (mounted) _showMessage(error.message, isError: true);
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _refresh() async {
    setState(() {
      _loading = true;
      _loadError = null;
    });
    final results = await Future.wait<dynamic>(
      [
        _api.catalog(),
        _api.customers(),
        _api.customerStats(),
        _api.inquiries(),
      ].map((future) async {
        try {
          return await future;
        } on ApiException catch (error) {
          return error;
        }
      }),
    );

    if (!mounted) return;
    setState(() {
      if (results[0] is List<Map<String, dynamic>>) {
        _catalog = results[0] as List<Map<String, dynamic>>;
      }
      if (results[1] is List<Map<String, dynamic>>) {
        _customers = results[1] as List<Map<String, dynamic>>;
      }
      if (results[2] is Map<String, dynamic>) {
        _customerStats = results[2] as Map<String, dynamic>;
      }
      if (results[3] is List<Map<String, dynamic>>) {
        _inquiries = results[3] as List<Map<String, dynamic>>;
      }
      final failures = results.whereType<ApiException>().toList();
      if (failures.isNotEmpty) _loadError = failures.first.message;
      _loading = false;
    });
  }

  Future<void> _createInquiry(Map<String, String> fields) async {
    await _api.createInquiry(
      subject: fields['subject']!,
      contactName: fields['contact_name']!,
      description: fields['description']!,
      source: fields['source']!,
      contactPhone: fields['contact_phone'],
    );
    await _refresh();
    _showMessage('Demande enregistrée.');
  }

  Future<void> _createCustomer(Map<String, String> fields) async {
    await _api.createCustomer(name: fields['name']!, type: fields['type']!);
    await _refresh();
    _showMessage('Client ajouté au répertoire.');
  }

  Future<void> _qualifyInquiry(int id) async {
    await _api.qualifyInquiry(id);
    await _refresh();
    _showMessage('Demande qualifiée.');
  }

  Future<void> _sendQuote(int id, double amount) async {
    await _api.sendInquiryQuote(id, amount);
    await _refresh();
    _showMessage('Devis marqué comme envoyé.');
  }

  Future<void> _refuseInquiry(int id) async {
    final reason = await _textDialog(
      title: 'Refuser la demande',
      label: 'Motif du refus',
      confirmLabel: 'Confirmer le refus',
    );
    if (reason == null || reason.trim().isEmpty) return;
    await _api.refuseInquiry(id, reason.trim());
    await _refresh();
    _showMessage('Demande refusée.');
  }

  Future<String?> _textDialog({
    required String title,
    required String label,
    required String confirmLabel,
  }) async {
    final controller = TextEditingController();
    return showDialog<String>(
      context: context,
      builder: (context) => _ApcDialog(
        title: title,
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text),
            child: Text(confirmLabel),
          ),
        ],
        child: TextField(
          controller: controller,
          autofocus: true,
          maxLines: 3,
          decoration: InputDecoration(labelText: label),
        ),
      ),
    );
  }

  Future<void> _logout() async {
    try {
      await _api.logout();
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
    if (mounted) setState(() => _user = null);
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? _orange : _ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  Future<void> _newInquiry() async {
    final fields = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _InquiryDialog(),
    );
    if (fields == null) return;
    try {
      await _createInquiry(fields);
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
  }

  Future<void> _newCustomer() async {
    final fields = await showDialog<Map<String, String>>(
      context: context,
      builder: (context) => const _CustomerDialog(),
    );
    if (fields == null) return;
    try {
      await _createCustomer(fields);
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'APC | Africa Print Communication',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: _paper,
        colorScheme: ColorScheme.fromSeed(
          seedColor: _blue,
          primary: _blue,
          secondary: _orange,
          surface: const Color(0xFFFFFEFB),
          error: _orange,
        ),
        fontFamily: 'Segoe UI',
        textTheme: const TextTheme(
          headlineLarge: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 38,
            height: 1.08,
            color: _ink,
          ),
          headlineMedium: TextStyle(
            fontFamily: 'Georgia',
            fontSize: 30,
            height: 1.12,
            color: _ink,
          ),
          titleLarge: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          titleMedium: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w700,
            color: _ink,
          ),
          bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: _ink),
          bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: _ink),
          labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: const Color(0xFFFFFEFB),
          contentPadding: const EdgeInsets.symmetric(
            horizontal: 15,
            vertical: 15,
          ),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _line),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _line),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(6),
            borderSide: const BorderSide(color: _blue, width: 1.5),
          ),
        ),
        cardTheme: CardThemeData(
          color: const Color(0xFFFFFEFB),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(6),
            side: const BorderSide(color: _line),
          ),
        ),
      ),
      home: _user == null
          ? _LoginScreen(onLogin: _signIn, loading: _loading)
          : _WorkspaceScreen(
              user: _user!,
              section: _section,
              loading: _loading,
              loadError: _loadError,
              catalog: _catalog,
              customers: _customers,
              inquiries: _inquiries,
              customerStats: _customerStats,
              onSelect: (section) => setState(() => _section = section),
              onRefresh: _refresh,
              onNewInquiry: _newInquiry,
              onNewCustomer: _newCustomer,
              onQualify: _qualifyInquiry,
              onSendQuote: _sendQuote,
              onRefuse: _refuseInquiry,
              onLogout: _logout,
              onError: (message) => _showMessage(message, isError: true),
            ),
    );
  }
}

class _LoginScreen extends StatefulWidget {
  const _LoginScreen({required this.onLogin, required this.loading});

  final Future<void> Function(String, String) onLogin;
  final bool loading;

  @override
  State<_LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<_LoginScreen> {
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
              if (wide) const Expanded(flex: 11, child: _BrandPanel()),
              Expanded(
                flex: wide ? 9 : 1,
                child: ColoredBox(
                  color: _paper,
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
                            const _Eyebrow('ESPACE ÉQUIPE · APC'),
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
                                        backgroundColor: _ink,
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
                                  color: _muted,
                                ),
                                SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Connexion sécurisée · Les accès suivent ton rôle.',
                                    style: TextStyle(
                                      color: _muted,
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

class _BrandPanel extends StatelessWidget {
  const _BrandPanel();

  @override
  Widget build(BuildContext context) {
    return Container(
      color: _ink,
      child: Stack(
        children: [
          Positioned(
            right: -80,
            top: -90,
            child: _PrintDisc(size: 350, color: _blue.withValues(alpha: .42)),
          ),
          Positioned(
            left: -120,
            bottom: -120,
            child: _PrintDisc(size: 390, color: _orange.withValues(alpha: .95)),
          ),
          Padding(
            padding: const EdgeInsets.all(54),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  width: 285,
                  height: 115,
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
                const _Eyebrow(
                  'ATELIER · COMMUNICATION · IMPRESSION',
                  light: true,
                ),
                const SizedBox(height: 20),
                const Text(
                  'Des idées\nqui prennent\nforme.',
                  style: TextStyle(
                    fontFamily: 'Georgia',
                    fontSize: 58,
                    height: 1.04,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 22),
                Container(width: 54, height: 5, color: _orange),
                const SizedBox(height: 20),
                const Text(
                  'Une seule équipe. Tous les ateliers. Chaque détail compte.',
                  style: TextStyle(color: Color(0xFFC4D0CF), fontSize: 15),
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
  }
}

class _PrintDisc extends StatelessWidget {
  const _PrintDisc({required this.size, required this.color});
  final double size;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      border: Border.all(color: color, width: 42),
    ),
  );
}

class _WorkspaceScreen extends StatelessWidget {
  const _WorkspaceScreen({
    required this.user,
    required this.section,
    required this.loading,
    required this.loadError,
    required this.catalog,
    required this.customers,
    required this.inquiries,
    required this.customerStats,
    required this.onSelect,
    required this.onRefresh,
    required this.onNewInquiry,
    required this.onNewCustomer,
    required this.onQualify,
    required this.onSendQuote,
    required this.onRefuse,
    required this.onLogout,
    required this.onError,
  });

  final Map<String, dynamic> user;
  final int section;
  final bool loading;
  final String? loadError;
  final List<Map<String, dynamic>> catalog;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> inquiries;
  final Map<String, dynamic> customerStats;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onNewInquiry;
  final Future<void> Function() onNewCustomer;
  final Future<void> Function(int) onQualify;
  final Future<void> Function(int, double) onSendQuote;
  final Future<void> Function(int) onRefuse;
  final Future<void> Function() onLogout;
  final ValueChanged<String> onError;

  static const _items = [
    (label: 'Vue d’ensemble', icon: Icons.grid_view_rounded),
    (label: 'Demandes', icon: Icons.markunread_mailbox_outlined),
    (label: 'Clients', icon: Icons.people_alt_outlined),
    (label: 'Catalogue', icon: Icons.color_lens_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, bounds) {
        final desktop = bounds.maxWidth >= 1020;
        final page = _page(context);
        return Scaffold(
          body: SafeArea(
            child: Row(
              children: [
                if (desktop)
                  _SideNavigation(
                    selected: section,
                    user: user,
                    onSelect: onSelect,
                    onLogout: onLogout,
                  ),
                Expanded(
                  child: Column(
                    children: [
                      _WorkspaceHeader(
                        user: user,
                        title: _items[section].label,
                        loading: loading,
                        onRefresh: onRefresh,
                        onLogout: onLogout,
                      ),
                      if (loadError != null)
                        MaterialBanner(
                          backgroundColor: const Color(0xFFFFE9DE),
                          content: Text(
                            '$loadError Certains panneaux peuvent rester vides jusqu’au rétablissement de l’API.',
                          ),
                          leading: const Icon(
                            Icons.warning_amber_rounded,
                            color: _orange,
                          ),
                          actions: [
                            TextButton(
                              onPressed: onRefresh,
                              child: const Text('Réessayer'),
                            ),
                          ],
                        ),
                      Expanded(child: page),
                    ],
                  ),
                ),
              ],
            ),
          ),
          bottomNavigationBar: desktop
              ? null
              : NavigationBar(
                  selectedIndex: section,
                  onDestinationSelected: onSelect,
                  backgroundColor: const Color(0xFFFFFEFB),
                  indicatorColor: const Color(0xFFD9EDF5),
                  destinations: _items
                      .map(
                        (item) => NavigationDestination(
                          icon: Icon(item.icon),
                          label: item.label == 'Vue d’ensemble'
                              ? 'Accueil'
                              : item.label,
                        ),
                      )
                      .toList(),
                ),
          floatingActionButton: section == 1 || section == 2
              ? FloatingActionButton.extended(
                  onPressed: () async {
                    try {
                      if (section == 1) {
                        await onNewInquiry();
                      } else {
                        await onNewCustomer();
                      }
                    } on ApiException catch (error) {
                      onError(error.message);
                    }
                  },
                  backgroundColor: _orange,
                  foregroundColor: Colors.white,
                  icon: const Icon(Icons.add_rounded),
                  label: Text(
                    section == 1 ? 'Nouvelle demande' : 'Nouveau client',
                  ),
                )
              : null,
        );
      },
    );
  }

  Widget _page(BuildContext context) {
    switch (section) {
      case 1:
        return _InquiryPage(
          inquiries: inquiries,
          user: user,
          onQualify: onQualify,
          onSendQuote: onSendQuote,
          onRefuse: onRefuse,
          onError: onError,
        );
      case 2:
        return _CustomerPage(customers: customers, stats: customerStats);
      case 3:
        return _CatalogPage(categories: catalog);
      default:
        return _OverviewPage(
          user: user,
          customers: customers,
          inquiries: inquiries,
          catalog: catalog,
          customerStats: customerStats,
          onSelect: onSelect,
          onNewInquiry: onNewInquiry,
        );
    }
  }
}

class _SideNavigation extends StatelessWidget {
  const _SideNavigation({
    required this.selected,
    required this.user,
    required this.onSelect,
    required this.onLogout,
  });

  final int selected;
  final Map<String, dynamic> user;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 246,
      color: _ink,
      padding: const EdgeInsets.fromLTRB(18, 22, 14, 18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            height: 72,
            padding: const EdgeInsets.all(7),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(5),
            ),
            child: Image.asset(
              'assets/brand/apc-logo.png',
              fit: BoxFit.contain,
            ),
          ),
          const SizedBox(height: 34),
          const _Eyebrow('BUREAU · SECRÉTARIAT', light: true),
          const SizedBox(height: 12),
          ...List.generate(_WorkspaceScreen._items.length, (index) {
            final item = _WorkspaceScreen._items[index];
            final active = index == selected;
            return Padding(
              padding: const EdgeInsets.only(bottom: 5),
              child: InkWell(
                borderRadius: BorderRadius.circular(6),
                onTap: () => onSelect(index),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 160),
                  height: 48,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  decoration: BoxDecoration(
                    color: active
                        ? const Color(0xFF274650)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(6),
                    border: Border(
                      left: BorderSide(
                        color: active ? _orange : Colors.transparent,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(
                        item.icon,
                        size: 19,
                        color: active ? Colors.white : const Color(0xFFA7B7B6),
                      ),
                      const SizedBox(width: 12),
                      Text(
                        item.label,
                        style: TextStyle(
                          color: active
                              ? Colors.white
                              : const Color(0xFFA7B7B6),
                          fontWeight: active
                              ? FontWeight.w700
                              : FontWeight.w500,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),
          const Spacer(),
          const Divider(color: Color(0xFF38545C)),
          Row(
            children: [
              CircleAvatar(
                radius: 18,
                backgroundColor: _orange,
                child: Text(
                  _initials(user['name']),
                  style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(user['name'], 'Membre APC'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    Text(
                      _text(
                        user['department'] is Map
                            ? (user['department'] as Map)['name']
                            : null,
                        'Équipe APC',
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        color: Color(0xFFA7B7B6),
                        fontSize: 11,
                      ),
                    ),
                  ],
                ),
              ),
              IconButton(
                tooltip: 'Déconnexion',
                onPressed: onLogout,
                icon: const Icon(
                  Icons.logout_rounded,
                  size: 18,
                  color: Color(0xFFA7B7B6),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _WorkspaceHeader extends StatelessWidget {
  const _WorkspaceHeader({
    required this.user,
    required this.title,
    required this.loading,
    required this.onRefresh,
    required this.onLogout,
  });

  final Map<String, dynamic> user;
  final String title;
  final bool loading;
  final Future<void> Function() onRefresh;
  final Future<void> Function() onLogout;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 76,
      padding: const EdgeInsets.symmetric(horizontal: 26),
      decoration: const BoxDecoration(
        color: Color(0xFFFFFEFB),
        border: Border(bottom: BorderSide(color: _line)),
      ),
      child: Row(
        children: [
          if (MediaQuery.sizeOf(context).width < 1020) ...[
            Container(
              width: 43,
              height: 43,
              padding: const EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.white,
                border: Border.all(color: _line),
                borderRadius: BorderRadius.circular(5),
              ),
              child: Image.asset(
                'assets/brand/apc-logo.png',
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(width: 12),
          ],
          Expanded(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title.toUpperCase(),
                  style: const TextStyle(
                    fontSize: 11,
                    letterSpacing: 1.1,
                    fontWeight: FontWeight.w800,
                    color: _muted,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  'ESPACE ÉQUIPE · APC',
                  style: TextStyle(
                    fontSize: MediaQuery.sizeOf(context).width < 600 ? 10 : 12,
                    color: _ink,
                    fontWeight: FontWeight.w700,
                  ),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: 'Actualiser les données',
            onPressed: loading ? null : onRefresh,
            icon: loading
                ? const SizedBox.square(
                    dimension: 18,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : const Icon(Icons.refresh_rounded),
          ),
          if (MediaQuery.sizeOf(context).width < 1020)
            IconButton(
              tooltip: 'Déconnexion',
              onPressed: onLogout,
              icon: const Icon(Icons.logout_rounded),
            ),
        ],
      ),
    );
  }
}

class _OverviewPage extends StatelessWidget {
  const _OverviewPage({
    required this.user,
    required this.customers,
    required this.inquiries,
    required this.catalog,
    required this.customerStats,
    required this.onSelect,
    required this.onNewInquiry,
  });

  final Map<String, dynamic> user;
  final List<Map<String, dynamic>> customers;
  final List<Map<String, dynamic>> inquiries;
  final List<Map<String, dynamic>> catalog;
  final Map<String, dynamic> customerStats;
  final ValueChanged<int> onSelect;
  final Future<void> Function() onNewInquiry;

  @override
  Widget build(BuildContext context) {
    final name = _text(user['name'], 'Équipe APC').split(' ').first;
    final stats = [
      _StatData(
        'Demandes ouvertes',
        '${inquiries.where((item) => !['refused', 'converted'].contains(item['status'])).length}',
        Icons.markunread_mailbox_outlined,
        _blue,
      ),
      _StatData(
        'Clients actifs',
        '${customerStats['active'] ?? customers.length}',
        Icons.people_alt_outlined,
        _orange,
      ),
      _StatData(
        'Prestations',
        '${catalog.fold<int>(0, (total, category) => total + ((category['services'] as List?)?.length ?? 0))}',
        Icons.print_outlined,
        _ink,
      ),
    ];

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(30, 28, 30, 34),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 1320),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(27, 25, 27, 25),
                decoration: BoxDecoration(
                  color: _blue,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: LayoutBuilder(
                  builder: (context, constraints) => Row(
                    children: [
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const _Eyebrow(
                              'ATELIER EN DIRECT · APC',
                              light: true,
                            ),
                            const SizedBox(height: 12),
                            Text(
                              'Bonjour $name.',
                              style: Theme.of(context).textTheme.headlineMedium
                                  ?.copyWith(color: Colors.white),
                            ),
                            const SizedBox(height: 8),
                            const Text(
                              'On donne forme aux idées, une demande à la fois.',
                              style: TextStyle(
                                color: Color(0xFFE1F1F6),
                                fontSize: 14,
                              ),
                            ),
                            const SizedBox(height: 19),
                            FilledButton.icon(
                              onPressed: onNewInquiry,
                              icon: const Icon(Icons.add_rounded, size: 18),
                              label: const Text('Saisir une demande'),
                              style: FilledButton.styleFrom(
                                backgroundColor: _orange,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(5),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (constraints.maxWidth > 560) ...[
                        const SizedBox(width: 22),
                        Container(
                          width: 142,
                          height: 142,
                          decoration: BoxDecoration(
                            color: const Color(0xFF07649D),
                            borderRadius: BorderRadius.circular(5),
                          ),
                          child: const Stack(
                            children: [
                              Positioned(
                                right: -21,
                                top: -20,
                                child: _PrintDisc(
                                  size: 118,
                                  color: Color(0xFF2E91C2),
                                ),
                              ),
                              Align(
                                alignment: Alignment.bottomLeft,
                                child: Padding(
                                  padding: EdgeInsets.all(15),
                                  child: Icon(
                                    Icons.auto_awesome_mosaic_outlined,
                                    color: Colors.white,
                                    size: 35,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 24),
              LayoutBuilder(
                builder: (context, constraints) {
                  final columns = constraints.maxWidth > 840
                      ? 3
                      : (constraints.maxWidth > 500 ? 3 : 1);
                  return GridView.builder(
                    shrinkWrap: true,
                    physics: const NeverScrollableScrollPhysics(),
                    itemCount: stats.length,
                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: columns,
                      mainAxisExtent: 112,
                      crossAxisSpacing: 12,
                      mainAxisSpacing: 12,
                    ),
                    itemBuilder: (context, index) =>
                        _StatTile(data: stats[index]),
                  );
                },
              ),
              const SizedBox(height: 31),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'À suivre',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onSelect(1),
                    child: const Text('Toutes les demandes  →'),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              if (inquiries.isEmpty)
                _EmptyState(
                  icon: Icons.inbox_outlined,
                  title: 'La file est calme',
                  detail: 'Les nouvelles demandes apparaîtront ici.',
                )
              else
                ...inquiries
                    .take(4)
                    .map((item) => _InquiryRow(item: item, compact: true)),
              const SizedBox(height: 28),
              Row(
                children: [
                  Expanded(
                    child: Text(
                      'Le catalogue du jour',
                      style: Theme.of(context).textTheme.titleLarge,
                    ),
                  ),
                  TextButton(
                    onPressed: () => onSelect(3),
                    child: const Text('Voir le catalogue  →'),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final category in catalog.take(8))
                    _CategoryTag(label: _text(category['name'], 'Prestation')),
                  if (catalog.isEmpty)
                    const _CategoryTag(label: 'Catalogue non chargé'),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _StatData {
  const _StatData(this.label, this.value, this.icon, this.color);
  final String label;
  final String value;
  final IconData icon;
  final Color color;
}

class _StatTile extends StatelessWidget {
  const _StatTile({required this.data});
  final _StatData data;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(17),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        Container(
          width: 42,
          height: 42,
          decoration: BoxDecoration(
            color: data.color.withValues(alpha: .1),
            borderRadius: BorderRadius.circular(5),
          ),
          child: Icon(data.icon, color: data.color, size: 21),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                data.value,
                style: const TextStyle(
                  fontSize: 26,
                  height: 1,
                  fontWeight: FontWeight.w800,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 7),
              Text(
                data.label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(color: _muted, fontSize: 12),
              ),
            ],
          ),
        ),
      ],
    ),
  );
}

class _InquiryPage extends StatefulWidget {
  const _InquiryPage({
    required this.inquiries,
    required this.user,
    required this.onQualify,
    required this.onSendQuote,
    required this.onRefuse,
    required this.onError,
  });
  final List<Map<String, dynamic>> inquiries;
  final Map<String, dynamic> user;
  final Future<void> Function(int) onQualify;
  final Future<void> Function(int, double) onSendQuote;
  final Future<void> Function(int) onRefuse;
  final ValueChanged<String> onError;

  @override
  State<_InquiryPage> createState() => _InquiryPageState();
}

class _InquiryPageState extends State<_InquiryPage> {
  final _search = TextEditingController();
  String _filter = 'Toutes';

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.inquiries.where((item) {
      final query = _search.text.toLowerCase();
      final matchesSearch =
          query.isEmpty ||
          '${item['subject']} ${item['contact_name']} ${item['contact_phone']}'
              .toLowerCase()
              .contains(query);
      final matchesFilter =
          _filter == 'Toutes' || item['status'] == _statusCode(_filter);
      return matchesSearch && matchesFilter;
    }).toList();

    return _PageFrame(
      eyebrow: 'ACCUEIL · DEVIS · SUIVI',
      title: 'Demandes entrantes',
      description: 'Chaque échange devient un dossier suivi, du premier contact au devis.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 270,
                child: TextField(
                  controller: _search,
                  onChanged: (_) => setState(() {}),
                  decoration: const InputDecoration(
                    hintText: 'Chercher une demande',
                    prefixIcon: Icon(Icons.search_rounded),
                    isDense: true,
                  ),
                ),
              ),
              for (final filter in [
                'Toutes',
                'Nouvelles',
                'Qualifiées',
                'Devis envoyés',
                'Refusées',
              ])
                _FilterButton(
                  label: filter,
                  selected: _filter == filter,
                  onTap: () => setState(() => _filter = filter),
                ),
            ],
          ),
          const SizedBox(height: 18),
          if (filtered.isEmpty)
            const _EmptyState(
              icon: Icons.markunread_mailbox_outlined,
              title: 'Aucune demande trouvée',
              detail: 'Essaie un autre filtre ou crée une nouvelle demande.',
            )
          else
            ...filtered.map(
              (item) => _InquiryRow(
                item: item,
                onQualify: _can('inquiries.edit') && item['status'] == 'new'
                    ? () => _run(() => widget.onQualify(_id(item['id'])))
                    : null,
                onSendQuote:
                    _can('inquiries.edit') && item['status'] == 'qualified'
                    ? () => _quote(item)
                    : null,
                onRefuse:
                    _can('inquiries.edit') &&
                        !['refused', 'converted'].contains(item['status'])
                    ? () => _run(() => widget.onRefuse(_id(item['id'])))
                    : null,
              ),
            ),
        ],
      ),
    );
  }

  bool _can(String permission) =>
      (widget.user['permissions'] as List? ?? const []).contains(permission);

  Future<void> _run(Future<void> Function() action) async {
    try {
      await action();
    } on ApiException catch (error) {
      widget.onError(error.message);
    }
  }

  Future<void> _quote(Map<String, dynamic> item) async {
    final amount = await _numberDialog();
    if (amount == null) return;
    await _run(() => widget.onSendQuote(_id(item['id']), amount));
  }

  Future<double?> _numberDialog() async {
    final controller = TextEditingController();
    return showDialog<double>(
      context: context,
      builder: (context) => _ApcDialog(
        title: 'Marquer le devis envoyé',
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(
              context,
              double.tryParse(controller.text.replaceAll(',', '.')),
            ),
            child: const Text('Enregistrer'),
          ),
        ],
        child: TextField(
          controller: controller,
          autofocus: true,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: const InputDecoration(
            labelText: 'Montant estimatif · FCFA',
          ),
        ),
      ),
    );
  }

  int _id(dynamic value) => value is int ? value : int.tryParse('$value') ?? 0;
}

class _InquiryRow extends StatelessWidget {
  const _InquiryRow({
    required this.item,
    this.compact = false,
    this.onQualify,
    this.onSendQuote,
    this.onRefuse,
  });
  final Map<String, dynamic> item;
  final bool compact;
  final VoidCallback? onQualify;
  final VoidCallback? onSendQuote;
  final VoidCallback? onRefuse;

  @override
  Widget build(BuildContext context) {
    final status = _text(item['status'], 'new');
    final statusColor = switch (status) {
      'new' => _blue,
      'qualified' => const Color(0xFF667A35),
      'quote_sent' => _orange,
      'refused' => const Color(0xFF866156),
      _ => _muted,
    };
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: EdgeInsets.symmetric(
        horizontal: 15,
        vertical: compact ? 12 : 14,
      ),
      decoration: BoxDecoration(
        color: const Color(0xFFFFFEFB),
        border: Border.all(color: _line),
        borderRadius: BorderRadius.circular(6),
      ),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final narrow = constraints.maxWidth < 620;
          final main = Row(
            children: [
              Container(width: 4, height: 39, color: statusColor),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      _text(item['subject'], 'Nouvelle demande'),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontWeight: FontWeight.w700,
                        color: _ink,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      '${_text(item['contact_name'], 'Contact')}  ·  ${_text(item['source'], 'autre')}',
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontSize: 12, color: _muted),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 10),
              _StatusTag(label: _statusLabel(status), color: statusColor),
            ],
          );
          if (compact) return main;
          final actions = Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (onQualify != null)
                IconButton(
                  tooltip: 'Qualifier',
                  onPressed: onQualify,
                  icon: const Icon(Icons.task_alt_rounded, color: _blue),
                ),
              if (onSendQuote != null)
                IconButton(
                  tooltip: 'Saisir l’envoi du devis',
                  onPressed: onSendQuote,
                  icon: const Icon(Icons.send_outlined, color: _orange),
                ),
              if (onRefuse != null)
                IconButton(
                  tooltip: 'Refuser la demande',
                  onPressed: onRefuse,
                  icon: const Icon(Icons.block_outlined, color: _muted),
                ),
            ],
          );
          return narrow
              ? Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    main,
                    if (actions.children.isNotEmpty)
                      Align(alignment: Alignment.centerRight, child: actions),
                  ],
                )
              : Row(
                  children: [
                    Expanded(child: main),
                    actions,
                  ],
                );
        },
      ),
    );
  }
}

class _CustomerPage extends StatefulWidget {
  const _CustomerPage({required this.customers, required this.stats});
  final List<Map<String, dynamic>> customers;
  final Map<String, dynamic> stats;

  @override
  State<_CustomerPage> createState() => _CustomerPageState();
}

class _CustomerPageState extends State<_CustomerPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final filtered = widget.customers
        .where(
          (item) =>
              '${item['name']} ${item['trade_name']} ${item['phone']} ${item['email']}'
                  .toLowerCase()
                  .contains(_search.text.toLowerCase()),
        )
        .toList();
    return _PageFrame(
      eyebrow: 'RÉPERTOIRE · HISTORIQUE · CONTACTS',
      title: 'Clients',
      description:
          '${widget.stats['total'] ?? widget.customers.length} fiches dans le répertoire chargé.',
      child: Column(
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Nom, téléphone ou email',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 14),
          if (filtered.isEmpty)
            const _EmptyState(
              icon: Icons.people_alt_outlined,
              title: 'Aucun client trouvé',
              detail: 'Modifie la recherche ou ajoute une fiche client.',
            )
          else
            ...filtered.map((customer) => _CustomerRow(customer: customer)),
        ],
      ),
    );
  }
}

class _CustomerRow extends StatelessWidget {
  const _CustomerRow({required this.customer});
  final Map<String, dynamic> customer;

  @override
  Widget build(BuildContext context) => Container(
    margin: const EdgeInsets.only(bottom: 8),
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Row(
      children: [
        CircleAvatar(
          radius: 21,
          backgroundColor: customer['type'] == 'company'
              ? const Color(0xFFD9EDF5)
              : const Color(0xFFFFE8DB),
          child: Icon(
            customer['type'] == 'company'
                ? Icons.storefront_outlined
                : Icons.person_outline_rounded,
            color: customer['type'] == 'company' ? _blue : _orange,
          ),
        ),
        const SizedBox(width: 13),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                _text(
                  customer['display_name'],
                  _text(customer['name'], 'Client'),
                ),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
              const SizedBox(height: 4),
              Text(
                [customer['phone'], customer['email']]
                    .where((value) => value != null && '$value'.isNotEmpty)
                    .join('  ·  '),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(fontSize: 12, color: _muted),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        _StatusTag(
          label: _text(customer['segment'], 'nouveau'),
          color: customer['is_active'] == false ? _muted : _blue,
        ),
      ],
    ),
  );
}

class _CatalogPage extends StatefulWidget {
  const _CatalogPage({required this.categories});
  final List<Map<String, dynamic>> categories;

  @override
  State<_CatalogPage> createState() => _CatalogPageState();
}

class _CatalogPageState extends State<_CatalogPage> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final categories = widget.categories
        .map((category) {
          final services = (category['services'] as List? ?? const [])
              .whereType<Map>()
              .map((item) => Map<String, dynamic>.from(item))
              .where(
                (item) => '${item['name']} ${item['code']}'
                    .toLowerCase()
                    .contains(_search.text.toLowerCase()),
              )
              .toList();
          return (category: category, services: services);
        })
        .where((item) => item.services.isNotEmpty || _search.text.isEmpty)
        .toList();
    return _PageFrame(
      eyebrow: 'PRESTATIONS · UNITÉS · TARIFS',
      title: 'Catalogue',
      description: 'Les prestations actives et leurs tarifs enregistrés.',
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          TextField(
            controller: _search,
            onChanged: (_) => setState(() {}),
            decoration: const InputDecoration(
              hintText: 'Chercher une prestation',
              prefixIcon: Icon(Icons.search_rounded),
              isDense: true,
            ),
          ),
          const SizedBox(height: 24),
          if (widget.categories.isEmpty)
            const _EmptyState(
              icon: Icons.print_outlined,
              title: 'Catalogue indisponible',
              detail:
                  'Vérifie la connexion à l’API puis actualise les données.',
            )
          else
            ...categories.map(
              (entry) => Padding(
                padding: const EdgeInsets.only(bottom: 25),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(width: 5, height: 24, color: _orange),
                        const SizedBox(width: 9),
                        Expanded(
                          child: Text(
                            _text(entry.category['name'], 'Prestations'),
                            style: Theme.of(context).textTheme.titleLarge,
                          ),
                        ),
                        Text(
                          '${entry.services.length} références',
                          style: const TextStyle(color: _muted, fontSize: 12),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    LayoutBuilder(
                      builder: (context, bounds) {
                        final columns = bounds.maxWidth > 1000
                            ? 3
                            : (bounds.maxWidth > 620 ? 2 : 1);
                        return GridView.builder(
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          itemCount: entry.services.length,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                crossAxisCount: columns,
                                mainAxisExtent: 119,
                                crossAxisSpacing: 10,
                                mainAxisSpacing: 10,
                              ),
                          itemBuilder: (context, index) =>
                              _ServiceTile(service: entry.services[index]),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class _ServiceTile extends StatelessWidget {
  const _ServiceTile({required this.service});
  final Map<String, dynamic> service;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.all(14),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Expanded(
              child: Text(
                _text(service['name'], 'Prestation'),
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.w700,
                  color: _ink,
                ),
              ),
            ),
            const Icon(Icons.arrow_outward_rounded, size: 16, color: _blue),
          ],
        ),
        const Spacer(),
        Text(
          _text(service['code'], 'APC'),
          style: const TextStyle(color: _muted, fontSize: 11),
        ),
        const SizedBox(height: 5),
        Row(
          children: [
            Text(
              '${_money(service['unit_price'])} FCFA',
              style: const TextStyle(
                fontWeight: FontWeight.w800,
                fontSize: 16,
                color: _blue,
              ),
            ),
            const SizedBox(width: 5),
            Text(
              '/ ${_text(service['unit'] is Map ? (service['unit'] as Map)['symbol'] : null, 'unité')}',
              style: const TextStyle(color: _muted, fontSize: 11),
            ),
          ],
        ),
      ],
    ),
  );
}

class _PageFrame extends StatelessWidget {
  const _PageFrame({
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.child,
  });
  final String eyebrow;
  final String title;
  final String description;
  final Widget child;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(30, 28, 30, 38),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1240),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _Eyebrow(eyebrow),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 7),
            Text(description, style: const TextStyle(color: _muted)),
            const SizedBox(height: 23),
            child,
          ],
        ),
      ),
    ),
  );
}

class _InquiryDialog extends StatefulWidget {
  const _InquiryDialog();

  @override
  State<_InquiryDialog> createState() => _InquiryDialogState();
}

class _InquiryDialogState extends State<_InquiryDialog> {
  final _form = GlobalKey<FormState>();
  final _subject = TextEditingController();
  final _contact = TextEditingController();
  final _phone = TextEditingController();
  final _description = TextEditingController();
  String _source = 'walk_in';

  @override
  void dispose() {
    _subject.dispose();
    _contact.dispose();
    _phone.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ApcDialog(
    title: 'Nouvelle demande',
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton.icon(
        onPressed: _submit,
        icon: const Icon(Icons.add_rounded),
        label: const Text('Enregistrer'),
      ),
    ],
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          TextFormField(
            controller: _subject,
            decoration: const InputDecoration(labelText: 'Objet du travail'),
            validator: _required,
          ),
          const SizedBox(height: 10),
          Row(
            children: [
              Expanded(
                child: TextFormField(
                  controller: _contact,
                  decoration: const InputDecoration(
                    labelText: 'Nom du contact',
                  ),
                  validator: _required,
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: TextFormField(
                  controller: _phone,
                  decoration: const InputDecoration(
                    labelText: 'Téléphone (facultatif)',
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 10),
          DropdownButtonFormField<String>(
            initialValue: _source,
            decoration: const InputDecoration(labelText: 'Canal d’arrivée'),
            items: const [
              DropdownMenuItem(value: 'walk_in', child: Text('Guichet')),
              DropdownMenuItem(value: 'whatsapp', child: Text('WhatsApp')),
              DropdownMenuItem(value: 'phone', child: Text('Téléphone')),
              DropdownMenuItem(value: 'email', child: Text('Email')),
              DropdownMenuItem(
                value: 'referral',
                child: Text('Recommandation'),
              ),
              DropdownMenuItem(
                value: 'social_media',
                child: Text('Réseaux sociaux'),
              ),
              DropdownMenuItem(value: 'other', child: Text('Autre')),
            ],
            onChanged: (value) => setState(() => _source = value ?? 'walk_in'),
          ),
          const SizedBox(height: 10),
          TextFormField(
            controller: _description,
            minLines: 2,
            maxLines: 4,
            decoration: const InputDecoration(
              labelText: 'Description du besoin',
            ),
            validator: _required,
          ),
        ],
      ),
    ),
  );

  void _submit() {
    if (!(_form.currentState?.validate() ?? false)) return;
    Navigator.pop(context, <String, String>{
      'subject': _subject.text.trim(),
      'contact_name': _contact.text.trim(),
      'contact_phone': _phone.text.trim(),
      'description': _description.text.trim(),
      'source': _source,
    });
  }
}

class _CustomerDialog extends StatefulWidget {
  const _CustomerDialog();

  @override
  State<_CustomerDialog> createState() => _CustomerDialogState();
}

class _CustomerDialogState extends State<_CustomerDialog> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  String _type = 'individual';

  @override
  void dispose() {
    _name.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => _ApcDialog(
    title: 'Ajouter un client',
    actions: [
      TextButton(
        onPressed: () => Navigator.pop(context),
        child: const Text('Annuler'),
      ),
      FilledButton(
        onPressed: () {
          if (!(_form.currentState?.validate() ?? false)) return;
          Navigator.pop(context, {'name': _name.text.trim(), 'type': _type});
        },
        child: const Text('Créer la fiche'),
      ),
    ],
    child: Form(
      key: _form,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          SegmentedButton<String>(
            segments: const [
              ButtonSegment(
                value: 'individual',
                label: Text('Particulier'),
                icon: Icon(Icons.person_outline),
              ),
              ButtonSegment(
                value: 'company',
                label: Text('Entreprise'),
                icon: Icon(Icons.storefront_outlined),
              ),
            ],
            selected: {_type},
            onSelectionChanged: (selection) =>
                setState(() => _type = selection.first),
          ),
          const SizedBox(height: 14),
          TextFormField(
            controller: _name,
            autofocus: true,
            decoration: InputDecoration(
              labelText: _type == 'company' ? 'Raison sociale' : 'Nom complet',
            ),
            validator: _required,
          ),
        ],
      ),
    ),
  );
}

class _ApcDialog extends StatelessWidget {
  const _ApcDialog({
    required this.title,
    required this.child,
    required this.actions,
  });
  final String title;
  final Widget child;
  final List<Widget> actions;

  @override
  Widget build(BuildContext context) => Dialog(
    backgroundColor: const Color(0xFFFFFEFB),
    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(7)),
    child: ConstrainedBox(
      constraints: const BoxConstraints(maxWidth: 520),
      child: Padding(
        padding: const EdgeInsets.fromLTRB(23, 22, 23, 15),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Expanded(
                  child: Text(
                    title,
                    style: Theme.of(context).textTheme.titleLarge,
                  ),
                ),
                IconButton(
                  tooltip: 'Fermer',
                  onPressed: () => Navigator.pop(context),
                  icon: const Icon(Icons.close_rounded),
                ),
              ],
            ),
            const SizedBox(height: 12),
            child,
            const SizedBox(height: 20),
            Align(
              alignment: Alignment.centerRight,
              child: Wrap(spacing: 8, children: actions),
            ),
          ],
        ),
      ),
    ),
  );
}

class _EmptyState extends StatelessWidget {
  const _EmptyState({
    required this.icon,
    required this.title,
    required this.detail,
  });
  final IconData icon;
  final String title;
  final String detail;

  @override
  Widget build(BuildContext context) => Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 32, horizontal: 18),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      children: [
        Icon(icon, size: 31, color: _blue),
        const SizedBox(height: 11),
        Text(
          title,
          style: const TextStyle(fontWeight: FontWeight.w700, color: _ink),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: _muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class _FilterButton extends StatelessWidget {
  const _FilterButton({
    required this.label,
    required this.selected,
    required this.onTap,
  });
  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => OutlinedButton(
    onPressed: onTap,
    style: OutlinedButton.styleFrom(
      backgroundColor: selected ? _ink : const Color(0xFFFFFEFB),
      foregroundColor: selected ? Colors.white : _ink,
      side: BorderSide(color: selected ? _ink : _line),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12)),
  );
}

class _StatusTag extends StatelessWidget {
  const _StatusTag({required this.label, required this.color});
  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
    decoration: BoxDecoration(
      color: color.withValues(alpha: .1),
      borderRadius: BorderRadius.circular(4),
    ),
    child: Text(
      label,
      style: TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: color),
    ),
  );
}

class _CategoryTag extends StatelessWidget {
  const _CategoryTag({required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: _line),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: _ink,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class _Eyebrow extends StatelessWidget {
  const _Eyebrow(this.label, {this.light = false});
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w800,
      color: light ? const Color(0xFFD4E5E8) : _blue,
    ),
  );
}

String _text(dynamic value, String fallback) =>
    value == null || '$value'.trim().isEmpty ? fallback : '$value';
String _initials(dynamic value) {
  final parts = _text(value, 'APC').trim().split(RegExp(r'\s+'));
  return parts
      .take(2)
      .map((part) => part.isEmpty ? '' : part[0].toUpperCase())
      .join();
}

String _money(dynamic value) {
  final amount = value is num ? value : num.tryParse('$value') ?? 0;
  return amount.round().toString().replaceAllMapped(
    RegExp(r'\B(?=(\d{3})+(?!\d))'),
    (_) => ' ',
  );
}

String _statusLabel(String status) => switch (status) {
  'new' => 'NOUVELLE',
  'qualified' => 'QUALIFIÉE',
  'quote_sent' => 'DEVIS ENVOYÉ',
  'refused' => 'REFUSÉE',
  'converted' => 'CONVERTIE',
  _ => status.toUpperCase(),
};

String? _statusCode(String label) => switch (label) {
  'Nouvelles' => 'new',
  'Qualifiées' => 'qualified',
  'Devis envoyés' => 'quote_sent',
  'Refusées' => 'refused',
  _ => null,
};

String? _required(String? value) =>
    value == null || value.trim().isEmpty ? 'Ce champ est requis.' : null;

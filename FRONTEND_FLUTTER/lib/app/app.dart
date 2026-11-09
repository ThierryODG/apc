import 'package:flutter/material.dart';

import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/data/apc_api.dart';
import 'package:apc_frontend/features/auth/application/auth_controller.dart';
import 'package:apc_frontend/features/auth/data/auth_repository.dart';
import 'package:apc_frontend/features/auth/presentation/login_screen.dart';
import 'package:apc_frontend/features/secretariat/application/secretariat_controller.dart';
import 'package:apc_frontend/features/secretariat/data/secretariat_repository.dart';
import 'package:apc_frontend/features/production/application/production_controller.dart';
import 'package:apc_frontend/features/production/data/production_repository.dart';
import 'package:apc_frontend/features/workspace/presentation/workspace_screen.dart';

class ApcApp extends StatefulWidget {
  const ApcApp({super.key, this.api});

  final ApcApi? api;

  @override
  State<ApcApp> createState() => _ApcAppState();
}

class _ApcAppState extends State<ApcApp> {
  late final AuthController _authController;
  late final SecretariatController _secretariatController;
  late final ProductionController _productionController;
  int _section = 0;

  @override
  void initState() {
    super.initState();
    final api = widget.api ?? ApcApi();
    _authController = AuthController(AuthRepository(api));
    _secretariatController = SecretariatController(SecretariatRepository(api));
    _productionController = ProductionController(ProductionRepository(api));
  }

  @override
  void dispose() {
    _authController.dispose();
    _secretariatController.dispose();
    _productionController.dispose();
    super.dispose();
  }

  Future<void> _signIn(String email, String password) async {
    try {
      await _authController.signIn(email, password);
      final user = _authController.user;
      if (user == null) return;
      final permissions = (user['permissions'] as List? ?? const []).toSet();
      final opensProduction =
          permissions.contains('production.view_queue') &&
          !permissions.contains('customers.view');
      setState(() => _section = opensProduction ? 1 : 0);
      await Future.wait([
        _secretariatController.refresh(user),
        _productionController.refresh(user),
      ]);
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
  }

  Future<void> _refresh() async {
    final user = _authController.user;
    if (user != null) {
      await Future.wait([
        _secretariatController.refresh(user),
        _productionController.refresh(user),
      ]);
    }
  }

  Future<void> _logout() async {
    try {
      await _authController.signOut();
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
    _secretariatController.clear();
    _productionController.clear();
    if (mounted) setState(() => _section = 0);
  }

  Future<void> _runAction(
    Future<void> Function() action,
    String successMessage,
  ) async {
    try {
      await action();
      _showMessage(successMessage);
    } on ApiException catch (error) {
      _showMessage(error.message, isError: true);
    }
  }

  void _showMessage(String message, {bool isError = false}) {
    if (!mounted) return;
    ScaffoldMessenger.of(context)
      ..hideCurrentSnackBar()
      ..showSnackBar(
        SnackBar(
          content: Text(message),
          backgroundColor: isError ? ApcPalette.orange : ApcPalette.ink,
          behavior: SnackBarBehavior.floating,
        ),
      );
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _authController,
      builder: (context, _) => MaterialApp(
        title: 'APC | Africa Print Communication',
        debugShowCheckedModeBanner: false,
        theme: _theme(),
        home: _authController.user == null
            ? LoginScreen(onLogin: _signIn, loading: _authController.loading)
            : AnimatedBuilder(
                animation: _secretariatController,
                builder: (context, _) => AnimatedBuilder(
                  animation: _productionController,
                  builder: (context, _) => WorkspaceScreen(
                    user: _authController.user!,
                    section: _section,
                    loading: _secretariatController.loading,
                    loadError: _secretariatController.loadError,
                    catalog: _secretariatController.catalog,
                    customers: _secretariatController.customers,
                    inquiries: _secretariatController.inquiries,
                    customerStats: _secretariatController.customerStats,
                    workOrders: _productionController.workOrders,
                    productionLoading: _productionController.loading,
                    productionError: _productionController.error,
                    onSelect: (section) => setState(() => _section = section),
                    onRefresh: _refresh,
                    onCreateInquiry: (fields) => _runAction(
                      () => _secretariatController.createInquiry(fields),
                      'Demande enregistrée.',
                    ),
                    onCreateCustomer: (fields) => _runAction(
                      () => _secretariatController.createCustomer(fields),
                      'Client ajouté au répertoire.',
                    ),
                    onQualify: (id) => _runAction(
                      () => _secretariatController.qualifyInquiry(id),
                      'Demande qualifiée.',
                    ),
                    onSendQuote: (id, amount) => _runAction(
                      () => _secretariatController.sendQuote(id, amount),
                      'Devis marqué comme envoyé.',
                    ),
                    onRefuse: (id, reason) => _runAction(
                      () => _secretariatController.refuseInquiry(id, reason),
                      'Demande refusée.',
                    ),
                    onUpdateWorkOrderStatus: (id, status) => _runAction(
                      () => _productionController.updateStatus(
                        id,
                        status,
                        _authController.user!,
                      ),
                      'Avancement enregistré.',
                    ),
                    onLogout: _logout,
                    onError: (message) => _showMessage(message, isError: true),
                  ),
                ),
              ),
      ),
    );
  }

  ThemeData _theme() => ThemeData(
    useMaterial3: true,
    scaffoldBackgroundColor: ApcPalette.paper,
    colorScheme: ColorScheme.fromSeed(
      seedColor: ApcPalette.blue,
      primary: ApcPalette.blue,
      secondary: ApcPalette.orange,
      surface: const Color(0xFFFFFEFB),
      error: ApcPalette.orange,
    ),
    fontFamily: 'Segoe UI',
    textTheme: const TextTheme(
      headlineLarge: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 38,
        height: 1.08,
        color: ApcPalette.ink,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Georgia',
        fontSize: 30,
        height: 1.12,
        color: ApcPalette.ink,
      ),
      titleLarge: TextStyle(
        fontSize: 18,
        fontWeight: FontWeight.w700,
        color: ApcPalette.ink,
      ),
      titleMedium: TextStyle(
        fontSize: 14,
        fontWeight: FontWeight.w700,
        color: ApcPalette.ink,
      ),
      bodyLarge: TextStyle(fontSize: 15, height: 1.45, color: ApcPalette.ink),
      bodyMedium: TextStyle(fontSize: 13, height: 1.4, color: ApcPalette.ink),
      labelLarge: TextStyle(fontSize: 13, fontWeight: FontWeight.w700),
    ),
    inputDecorationTheme: InputDecorationTheme(
      filled: true,
      fillColor: const Color(0xFFFFFEFB),
      contentPadding: const EdgeInsets.symmetric(horizontal: 15, vertical: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ApcPalette.line),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ApcPalette.line),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(6),
        borderSide: const BorderSide(color: ApcPalette.blue, width: 1.5),
      ),
    ),
    cardTheme: CardThemeData(
      color: const Color(0xFFFFFEFB),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(6),
        side: const BorderSide(color: ApcPalette.line),
      ),
    ),
  );
}

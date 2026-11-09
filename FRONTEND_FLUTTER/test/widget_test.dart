// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';

import 'package:apc_frontend/main.dart';
import 'package:apc_frontend/data/apc_api.dart';

void main() {
  testWidgets('login workspace renders on a narrow viewport', (tester) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApcApp());
    await tester.pumpAndSettle();

    expect(find.text('ESPACE ÉQUIPE · APC'), findsOneWidget);
    expect(find.text('Ouvrir mon espace'), findsOneWidget);
    expect(find.byType(TextFormField), findsNWidgets(2));
  });

  testWidgets('wide login shows the APC brand panel', (tester) async {
    tester.view.physicalSize = const Size(1440, 900);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApcApp());
    await tester.pumpAndSettle();

    expect(find.text('Des idées\nqui prennent\nforme.'), findsOneWidget);
    expect(find.text('Ouvrir mon espace'), findsOneWidget);
  });

  testWidgets('wide login fits a short desktop window', (tester) async {
    tester.view.physicalSize = const Size(1440, 540);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    await tester.pumpWidget(const ApcApp());
    await tester.pumpAndSettle();

    expect(tester.takeException(), isNull);
    expect(find.text('Ouvrir mon espace'), findsOneWidget);
  });

  testWidgets('staff login loads the connected APC workspace', (tester) async {
    final api = ApcApi(
      client: MockClient((request) async {
        final path = request.url.path;
        final payload = switch (path) {
          '/api/v1/auth/login' => {
            'success': true,
            'data': {
              'token': 'test-token',
              'user': {
                'id': 1,
                'name': 'Thierry APC',
                'email': 'admin@africaprint.com',
                'department': {'name': 'Direction Générale'},
                'roles': ['Secretaire'],
                'permissions': [
                  'catalog.view',
                  'customers.view',
                  'inquiries.view',
                  'inquiries.create',
                ],
              },
            },
          },
          '/api/v1/catalog' => {'success': true, 'data': []},
          '/api/v1/customers' => {
            'success': true,
            'data': {'data': []},
          },
          '/api/v1/customers/stats' => {
            'success': true,
            'data': {'total': 0, 'active': 0},
          },
          '/api/v1/inquiries' => {
            'success': true,
            'data': {'data': []},
          },
          _ => {'success': true, 'data': null},
        };
        return http.Response(
          jsonEncode(payload),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await tester.pumpWidget(ApcApp(api: api));
    await tester.pumpAndSettle();
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'admin@africaprint.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
    await tester.ensureVisible(find.text('Ouvrir mon espace'));
    await tester.tap(find.text('Ouvrir mon espace'));
    await tester.pumpAndSettle();

    expect(find.text('Bonjour Thierry.'), findsOneWidget);
    expect(find.text('Saisir une demande'), findsOneWidget);
  });

  testWidgets('machinist workspace hides and skips commercial data', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(390, 844);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);

    final requestedPaths = <String>[];
    final api = ApcApi(
      client: MockClient((request) async {
        requestedPaths.add(request.url.path);
        final payload = request.url.path == '/api/v1/auth/login'
            ? {
                'success': true,
                'data': {
                  'token': 'test-token',
                  'user': {
                    'id': 8,
                    'name': 'Opérateur APC',
                    'email': 'machiniste@africaprint.com',
                    'roles': ['Machiniste'],
                    'department': {'name': 'Atelier Numérique'},
                    'permissions': [
                      'orders.view',
                      'production.view_queue',
                      'hr.record_attendance',
                    ],
                  },
                },
              }
            : {'success': true, 'data': null};
        return http.Response(
          jsonEncode(payload),
          200,
          headers: {'content-type': 'application/json'},
        );
      }),
    );

    await tester.pumpWidget(ApcApp(api: api));
    await tester.enterText(
      find.byType(TextFormField).at(0),
      'machiniste@africaprint.com',
    );
    await tester.enterText(find.byType(TextFormField).at(1), 'test-password');
    await tester.tap(find.text('Ouvrir mon espace'));
    await tester.pumpAndSettle();

    expect(find.text('Aucun travail affecté'), findsOneWidget);
    expect(find.text('Demandes'), findsNothing);
    expect(find.text('Clients'), findsNothing);
    expect(find.text('Catalogue'), findsNothing);
    expect(requestedPaths, [
      '/api/v1/auth/login',
      '/api/v1/work-orders',
    ]);
  });
}

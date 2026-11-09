import 'package:flutter/material.dart';

import 'package:apc_frontend/core/theme/apc_palette.dart';
import 'package:apc_frontend/shared/presentation/apc_widgets.dart';

class ModuleHomeScreen extends StatelessWidget {
  const ModuleHomeScreen({
    super.key,
    required this.icon,
    required this.eyebrow,
    required this.title,
    required this.description,
    required this.modules,
  });

  final IconData icon;
  final String eyebrow;
  final String title;
  final String description;
  final List<String> modules;

  @override
  Widget build(BuildContext context) => SingleChildScrollView(
    padding: const EdgeInsets.fromLTRB(24, 28, 24, 36),
    child: Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 1050),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Eyebrow(eyebrow),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 8),
            Text(description, style: const TextStyle(color: ApcPalette.muted)),
            const SizedBox(height: 22),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(21),
              decoration: BoxDecoration(
                color: const Color(0xFFFFFEFB),
                border: Border.all(color: ApcPalette.line),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(icon, color: ApcPalette.blue, size: 25),
                  const SizedBox(width: 14),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Espace en préparation',
                          style: TextStyle(
                            color: ApcPalette.ink,
                            fontWeight: FontWeight.w800,
                          ),
                        ),
                        SizedBox(height: 5),
                        Text(
                          'Les données métier et les actions apparaîtront ici lorsque leur module sera connecté à l’API.',
                          style: TextStyle(color: ApcPalette.muted),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 25),
            Text(
              'Modules prévus',
              style: Theme.of(context).textTheme.titleLarge,
            ),
            const SizedBox(height: 11),
            for (final module in modules)
              Container(
                width: double.infinity,
                margin: const EdgeInsets.only(bottom: 7),
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 13,
                ),
                decoration: BoxDecoration(
                  border: Border(bottom: BorderSide(color: ApcPalette.line)),
                ),
                child: Row(
                  children: [
                    const Icon(
                      Icons.radio_button_unchecked,
                      size: 17,
                      color: ApcPalette.muted,
                    ),
                    const SizedBox(width: 11),
                    Expanded(child: Text(module)),
                    const Text(
                      'À FAIRE',
                      style: TextStyle(
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        color: ApcPalette.muted,
                      ),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
    ),
  );
}

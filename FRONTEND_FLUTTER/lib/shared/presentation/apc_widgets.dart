import 'package:flutter/material.dart';
import 'package:apc_frontend/core/theme/apc_palette.dart';

class PrintDisc extends StatelessWidget {
  const PrintDisc({super.key, required this.size, required this.color});
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

class PageFrame extends StatelessWidget {
  const PageFrame({
    super.key,
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
            Eyebrow(eyebrow),
            const SizedBox(height: 8),
            Text(title, style: Theme.of(context).textTheme.headlineMedium),
            const SizedBox(height: 7),
            Text(description, style: const TextStyle(color: ApcPalette.muted)),
            const SizedBox(height: 23),
            child,
          ],
        ),
      ),
    ),
  );
}

class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
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
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(6),
    ),
    child: Column(
      children: [
        Icon(icon, size: 31, color: ApcPalette.blue),
        const SizedBox(height: 11),
        Text(
          title,
          style: const TextStyle(
            fontWeight: FontWeight.w700,
            color: ApcPalette.ink,
          ),
        ),
        const SizedBox(height: 5),
        Text(
          detail,
          textAlign: TextAlign.center,
          style: const TextStyle(color: ApcPalette.muted, fontSize: 12),
        ),
      ],
    ),
  );
}

class FilterButton extends StatelessWidget {
  const FilterButton({
    super.key,
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
      backgroundColor: selected ? ApcPalette.ink : const Color(0xFFFFFEFB),
      foregroundColor: selected ? Colors.white : ApcPalette.ink,
      side: BorderSide(color: selected ? ApcPalette.ink : ApcPalette.line),
      padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 11),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(5)),
    ),
    child: Text(label, style: const TextStyle(fontSize: 12)),
  );
}

class StatusTag extends StatelessWidget {
  const StatusTag({super.key, required this.label, required this.color});
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

class CategoryTag extends StatelessWidget {
  const CategoryTag({super.key, required this.label});
  final String label;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 13, vertical: 10),
    decoration: BoxDecoration(
      color: const Color(0xFFFFFEFB),
      border: Border.all(color: ApcPalette.line),
      borderRadius: BorderRadius.circular(5),
    ),
    child: Text(
      label,
      style: const TextStyle(
        color: ApcPalette.ink,
        fontSize: 12,
        fontWeight: FontWeight.w600,
      ),
    ),
  );
}

class Eyebrow extends StatelessWidget {
  const Eyebrow(this.label, {super.key, this.light = false});
  final String label;
  final bool light;

  @override
  Widget build(BuildContext context) => Text(
    label,
    style: TextStyle(
      fontSize: 10,
      letterSpacing: 1.2,
      fontWeight: FontWeight.w800,
      color: light ? const Color(0xFFD4E5E8) : ApcPalette.blue,
    ),
  );
}

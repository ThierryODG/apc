import 'package:flutter/material.dart';

class ProductIconHelper {
  static IconData getIcon(String? name, String? unit) {
    final n = (name ?? '').toLowerCase();
    final u = (unit ?? '').toLowerCase();

    if (u.contains('m²') || u.contains('m2') || n.contains('bâche') || n.contains('banderole')) {
      return Icons.aspect_ratio_rounded;
    }
    if (n.contains('roll') || n.contains('kakemono')) {
      return Icons.view_carousel_rounded;
    }
    if (n.contains('carte') || n.contains('visite')) {
      return Icons.badge_outlined;
    }
    if (n.contains('flyer') || n.contains('dépliant') || n.contains('prospectus')) {
      return Icons.newspaper_rounded;
    }
    if (n.contains('affiche') || n.contains('poster') || n.contains('tableau')) {
      return Icons.image_outlined;
    }
    if (n.contains('mug') || n.contains('tasse') || n.contains('gadget')) {
      return Icons.coffee_rounded;
    }
    if (n.contains('stylo') || n.contains('crayon')) {
      return Icons.edit_rounded;
    }
    if (n.contains('t-shirt') || n.contains('polo') || n.contains('casquette') || n.contains('textile')) {
      return Icons.checkroom_rounded;
    }
    if (n.contains('tampon') || n.contains('cachet')) {
      return Icons.approval_rounded;
    }
    if (n.contains('vinyle') || n.contains('autocollant') || n.contains('sticker')) {
      return Icons.label_important_outline_rounded;
    }
    if (n.contains('livre') || n.contains('registre') || n.contains('carnet') || n.contains('reliure')) {
      return Icons.menu_book_rounded;
    }
    return Icons.inventory_2_outlined;
  }
}

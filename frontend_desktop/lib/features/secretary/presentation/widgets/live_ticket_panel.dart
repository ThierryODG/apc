import 'package:flutter/material.dart';

import '../../../../core/constants/app_colors.dart';
import '../../../../models/customer.dart';

/// Panier / Ticket en cours — colonne droite du POS (380px), style Aronium pro
class LiveTicketPanel extends StatefulWidget {
  final List<TicketLine> lines;
  final Customer? selectedCustomer;
  final double discountAmount;
  final bool isPercentageDiscount;
  final VoidCallback onCancel;
  final VoidCallback onHold;
  final VoidCallback onCheckout;
  final VoidCallback onSelectCustomer;
  final Function(int index) onRemoveLine;
  final Function(int index, double quantity) onUpdateQuantity;
  final Function(
    int index, {
    required double quantity,
    double? length,
    double? width,
  })
  onUpdateLine;
  final Function(double amount, bool isPercent) onDiscountChanged;

  const LiveTicketPanel({
    super.key,
    required this.lines,
    required this.selectedCustomer,
    required this.discountAmount,
    required this.isPercentageDiscount,
    required this.onCancel,
    required this.onHold,
    required this.onCheckout,
    required this.onSelectCustomer,
    required this.onRemoveLine,
    required this.onUpdateQuantity,
    required this.onUpdateLine,
    required this.onDiscountChanged,
  });

  @override
  State<LiveTicketPanel> createState() => _LiveTicketPanelState();
}

class _LiveTicketPanelState extends State<LiveTicketPanel> {
  double get _subTotal => widget.lines.fold(0, (s, l) => s + l.lineTotal);

  double get _discountCalculated {
    if (widget.isPercentageDiscount) {
      return _subTotal * (widget.discountAmount / 100);
    }
    return widget.discountAmount > _subTotal
        ? _subTotal
        : widget.discountAmount;
  }

  double get _total => (_subTotal - _discountCalculated) < 0
      ? 0
      : (_subTotal - _discountCalculated);

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000000) {
      final millions = n ~/ 1000000;
      final remainder = n % 1000000;
      final thousands = remainder ~/ 1000;
      final units = remainder % 1000;
      return '$millions ${thousands.toString().padLeft(3, '0')} ${units.toString().padLeft(3, '0')} F';
    }
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return '$thousands ${remainder.toString().padLeft(3, '0')} F';
    }
    return '$n F';
  }

  void _openCustomDiscountDialog() {
    final ctrl = TextEditingController(
      text: widget.discountAmount > 0
          ? (widget.discountAmount == widget.discountAmount.toInt()
                ? widget.discountAmount.toInt().toString()
                : widget.discountAmount.toString())
          : '',
    );
    bool isPercent = widget.isPercentageDiscount;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (context, setDlgState) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(10),
          ),
          title: const Row(
            children: [
              Icon(Icons.discount_outlined, color: AppColors.orange, size: 20),
              SizedBox(width: 8),
              Text(
                'Remise personnalisée',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800),
              ),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Montant fixe (FCFA)'),
                      selected: !isPercent,
                      onSelected: (_) => setDlgState(() => isPercent = false),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: ChoiceChip(
                      label: const Text('Pourcentage (%)'),
                      selected: isPercent,
                      onSelected: (_) => setDlgState(() => isPercent = true),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextField(
                controller: ctrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                decoration: InputDecoration(
                  labelText: isPercent
                      ? 'Pourcentage de remise (%)'
                      : 'Montant de remise (FCFA)',
                  suffixText: isPercent ? '%' : 'FCFA',
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () {
                widget.onDiscountChanged(0, false);
                Navigator.pop(ctx);
              },
              child: const Text(
                'Supprimer remise',
                style: TextStyle(color: AppColors.rouge),
              ),
            ),
            ElevatedButton(
              onPressed: () {
                final val =
                    double.tryParse(ctrl.text.replaceAll(',', '.').trim()) ??
                    0.0;
                widget.onDiscountChanged(val, isPercent);
                Navigator.pop(ctx);
              },
              child: const Text('Appliquer'),
            ),
          ],
        ),
      ),
    );
  }

  void _openQuantityOrDimensionDialog(int index) {
    final line = widget.lines[index];
    final isArea = line.isDimensionLine;
    final areaCtrl = TextEditingController(
      text: line.quantity == line.quantity.toInt()
          ? line.quantity.toInt().toString()
          : line.quantity.toString(),
    );
    final lengthCtrl = TextEditingController(
      text: line.length > 0 ? line.length.toString() : '',
    );
    final widthCtrl = TextEditingController(
      text: line.width > 0 ? line.width.toString() : '',
    );

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        title: Row(
          children: [
            Icon(
              isArea ? Icons.aspect_ratio_rounded : Icons.edit_note_rounded,
              color: AppColors.bleu,
              size: 20,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                isArea
                    ? 'Dimension / Surface (${line.productName})'
                    : 'Quantité (${line.productName})',
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w800,
                ),
                overflow: TextOverflow.ellipsis,
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              isArea
                  ? 'Saisissez la dimension de la prestation (longueur / largeur) :'
                  : 'Saisissez la quantité exacte (${line.unit}) :',
              style: const TextStyle(fontSize: 12, color: AppColors.gris),
            ),
            const SizedBox(height: 12),
            if (isArea) ...[
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: lengthCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      autofocus: true,
                      decoration: const InputDecoration(
                        labelText: 'Longueur (m)',
                        hintText: 'Ex: 2.5',
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: TextField(
                      controller: widthCtrl,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: const InputDecoration(
                        labelText: 'Largeur (m)',
                        hintText: 'Ex: 1.2',
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: AppColors.orange.withOpacity(0.08),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.orange.withOpacity(0.3)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'Surface calculée',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.orange2,
                      ),
                    ),
                    Builder(
                      builder: (_) {
                        final length =
                            double.tryParse(
                              lengthCtrl.text.replaceAll(',', '.'),
                            ) ??
                            0.0;
                        final width =
                            double.tryParse(
                              widthCtrl.text.replaceAll(',', '.'),
                            ) ??
                            0.0;
                        final calc = length > 0 && width > 0
                            ? length * width
                            : 0.0;
                        return Text(
                          '${calc.toStringAsFixed(2)} m²',
                          style: const TextStyle(
                            fontSize: 13,
                            fontWeight: FontWeight.w900,
                            color: AppColors.orange2,
                          ),
                        );
                      },
                    ),
                  ],
                ),
              ),
            ] else
              TextField(
                controller: areaCtrl,
                keyboardType: const TextInputType.numberWithOptions(
                  decimal: true,
                ),
                autofocus: true,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                ),
                decoration: InputDecoration(
                  suffixText: line.unit,
                  hintText: 'Ex: 10',
                ),
              ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Annuler'),
          ),
          ElevatedButton(
            onPressed: () {
              if (isArea) {
                final length =
                    double.tryParse(
                      lengthCtrl.text.replaceAll(',', '.').trim(),
                    ) ??
                    0.0;
                final width =
                    double.tryParse(
                      widthCtrl.text.replaceAll(',', '.').trim(),
                    ) ??
                    0.0;
                final area = length > 0 && width > 0 ? length * width : 0.0;
                if (area > 0) {
                  widget.onUpdateLine(
                    index,
                    quantity: area,
                    length: length,
                    width: width,
                  );
                }
              } else {
                final val =
                    double.tryParse(
                      areaCtrl.text.replaceAll(',', '.').trim(),
                    ) ??
                    1.0;
                if (val > 0) {
                  widget.onUpdateQuantity(index, val);
                }
              }
              Navigator.pop(ctx);
            },
            child: const Text('Valider'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 380,
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        border: Border(left: BorderSide(color: AppColors.bord)),
      ),
      child: Column(
        children: [
          // ── En-tête ticket ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: const BoxDecoration(
              color: AppColors.bleu,
              border: Border(bottom: BorderSide(color: Color(0x22FFFFFF))),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.receipt_long_rounded,
                  color: Colors.white,
                  size: 18,
                ),
                const SizedBox(width: 8),
                const Text(
                  'TICKET EN COURS',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 13,
                    fontWeight: FontWeight.w900,
                    letterSpacing: 0.5,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    '${widget.lines.length} art.',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Sélection client ────────────────────────────────
          InkWell(
            onTap: widget.onSelectCustomer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: AppColors.bord)),
              ),
              child: Row(
                children: [
                  Container(
                    width: 28,
                    height: 28,
                    decoration: BoxDecoration(
                      color:
                          (widget.selectedCustomer != null
                                  ? AppColors.vert
                                  : AppColors.gris)
                              .withOpacity(0.12),
                      shape: BoxShape.circle,
                    ),
                    child: Icon(
                      Icons.person_rounded,
                      size: 16,
                      color: widget.selectedCustomer != null
                          ? AppColors.vert
                          : AppColors.gris,
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          widget.selectedCustomer?.name ??
                              'Client Comptoir (Par défaut)',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w700,
                            color: widget.selectedCustomer != null
                                ? AppColors.bleu
                                : AppColors.texte,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        if (widget.selectedCustomer?.phone != null)
                          Text(
                            widget.selectedCustomer!.phone!,
                            style: const TextStyle(
                              fontSize: 10,
                              color: AppColors.gris,
                            ),
                          ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.fond,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(color: AppColors.bord),
                    ),
                    child: const Text(
                      'Changer',
                      style: TextStyle(
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.bleu,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),

          // ── Liste des lignes du ticket ──────────────────────
          Expanded(
            child: widget.lines.isEmpty
                ? Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: const BoxDecoration(
                            color: AppColors.fond,
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(
                            Icons.shopping_bag_outlined,
                            size: 28,
                            color: AppColors.gris,
                          ),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Le panier est vide',
                          style: TextStyle(
                            color: AppColors.texte,
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                        const SizedBox(height: 4),
                        const Text(
                          'Cliquez sur une prestation à gauche\npour l\'ajouter au ticket.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.gris, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    itemCount: widget.lines.length,
                    separatorBuilder: (_, __) =>
                        const Divider(height: 1, color: AppColors.bord),
                    itemBuilder: (context, i) => _TicketLineRow(
                      line: widget.lines[i],
                      onRemove: () => widget.onRemoveLine(i),
                      onEditQuantity: () => _openQuantityOrDimensionDialog(i),
                      onQuickStep: (delta) {
                        final newQty = widget.lines[i].quantity + delta;
                        if (newQty > 0) {
                          widget.onUpdateLine(
                            i,
                            quantity: newQty,
                            length: widget.lines[i].length,
                            width: widget.lines[i].width,
                          );
                        } else {
                          widget.onRemoveLine(i);
                        }
                      },
                    ),
                  ),
          ),

          // ── Zone Remise Pro ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.bord)),
              color: Color(0xFFFBFDFF),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.sell_outlined,
                  size: 14,
                  color: AppColors.gris,
                ),
                const SizedBox(width: 6),
                const Text(
                  'Remise :',
                  style: TextStyle(
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    color: AppColors.gris,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: InkWell(
                    onTap: _openCustomDiscountDialog,
                    borderRadius: BorderRadius.circular(4),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: widget.discountAmount > 0
                            ? AppColors.orange.withOpacity(0.1)
                            : AppColors.fond,
                        borderRadius: BorderRadius.circular(4),
                        border: Border.all(
                          color: widget.discountAmount > 0
                              ? AppColors.orange
                              : AppColors.bord,
                        ),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            widget.discountAmount > 0
                                ? (widget.isPercentageDiscount
                                      ? '${widget.discountAmount}% (- ${_fmt(_discountCalculated)})'
                                      : '- ${_fmt(widget.discountAmount)}')
                                : 'Aucune remise (cliquer pour définir)',
                            style: TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: widget.discountAmount > 0
                                  ? AppColors.orange
                                  : AppColors.gris,
                            ),
                          ),
                          const Icon(
                            Icons.edit_outlined,
                            size: 13,
                            color: AppColors.gris,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // ── Totaux ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
            decoration: const BoxDecoration(
              color: Color(0xFFF8FAFC),
              border: Border(top: BorderSide(color: AppColors.bord)),
            ),
            child: Column(
              children: [
                _TotalRow(label: 'Sous-total brut', value: _fmt(_subTotal)),
                if (_discountCalculated > 0)
                  _TotalRow(
                    label: widget.isPercentageDiscount
                        ? 'Remise accordée (${widget.discountAmount}%)'
                        : 'Remise accordée',
                    value: '- ${_fmt(_discountCalculated)}',
                    valueColor: AppColors.rouge,
                  ),
                const Divider(height: 12, color: AppColors.bord),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'TOTAL À PAYER',
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bleu,
                      ),
                    ),
                    Text(
                      _fmt(_total),
                      style: const TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.w900,
                        color: AppColors.bleu,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Boutons d'action F4 ─────────────────────────────
          Container(
            padding: const EdgeInsets.all(12),
            decoration: const BoxDecoration(
              color: AppColors.blanc,
              border: Border(top: BorderSide(color: AppColors.bord)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.lines.isEmpty
                            ? null
                            : widget.onCancel,
                        icon: const Icon(Icons.delete_sweep_outlined, size: 16),
                        label: const Text(
                          'Vider le ticket',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rouge,
                          side: const BorderSide(color: AppColors.rouge),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: widget.lines.isEmpty ? null : widget.onHold,
                        icon: const Icon(
                          Icons.pause_circle_outline_rounded,
                          size: 16,
                        ),
                        label: const Text(
                          'Mettre en attente',
                          style: TextStyle(fontSize: 11),
                        ),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.texte,
                          side: const BorderSide(color: AppColors.bord),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(6),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 10),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: widget.lines.isEmpty ? null : widget.onCheckout,
                    icon: const Icon(Icons.payments_rounded, size: 18),
                    label: const Text(
                      'ENCAISSER (F4)',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 0.5,
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.orange,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                      ),
                      elevation: 0,
                    ),
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

class _TicketLineRow extends StatelessWidget {
  final TicketLine line;
  final VoidCallback onRemove;
  final VoidCallback onEditQuantity;
  final Function(double delta) onQuickStep;

  const _TicketLineRow({
    required this.line,
    required this.onRemove,
    required this.onEditQuantity,
    required this.onQuickStep,
  });

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000) {
      final t = n ~/ 1000;
      final r = n % 1000;
      return '$t ${r.toString().padLeft(3, '0')}';
    }
    return n.toString();
  }

  String _formatQuantity(double q) {
    if (q == q.toInt()) return q.toInt().toString();
    return q.toStringAsFixed(2);
  }

  @override
  Widget build(BuildContext context) {
    final isArea =
        line.unit.toLowerCase().contains('m²') ||
        line.unit.toLowerCase().contains('m2');

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: const TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.texte,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  '${_fmt(line.unitPrice)} F / ${line.unit}',
                  style: const TextStyle(fontSize: 10, color: AppColors.gris),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),

          // Contrôleur de quantité / dimension avec bouton pour modifier la valeur exacte (ex: 16.75 m²)
          InkWell(
            onTap: onEditQuantity,
            borderRadius: BorderRadius.circular(4),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: isArea
                    ? AppColors.orange.withOpacity(0.08)
                    : AppColors.fond,
                borderRadius: BorderRadius.circular(4),
                border: Border.all(
                  color: isArea
                      ? AppColors.orange.withOpacity(0.5)
                      : AppColors.bord,
                ),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '${_formatQuantity(line.quantity)} ${line.unit}',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w800,
                      color: isArea ? AppColors.orange2 : AppColors.bleu,
                    ),
                  ),
                  const SizedBox(width: 4),
                  const Icon(Icons.edit, size: 11, color: AppColors.gris),
                ],
              ),
            ),
          ),

          const SizedBox(width: 8),

          // Total de ligne
          SizedBox(
            width: 76,
            child: Text(
              '${_fmt(line.lineTotal)} F',
              textAlign: TextAlign.right,
              style: const TextStyle(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                color: AppColors.bleu,
              ),
            ),
          ),

          const SizedBox(width: 4),
          IconButton(
            icon: const Icon(
              Icons.close_rounded,
              size: 16,
              color: AppColors.rouge,
            ),
            onPressed: onRemove,
            tooltip: 'Supprimer',
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
        ],
      ),
    );
  }
}

class _TotalRow extends StatelessWidget {
  final String label;
  final String value;
  final Color? valueColor;
  const _TotalRow({required this.label, required this.value, this.valueColor});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: const TextStyle(fontSize: 11, color: AppColors.gris),
          ),
          Text(
            value,
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: valueColor ?? AppColors.texte,
            ),
          ),
        ],
      ),
    );
  }
}

/// Modèle d'une ligne de ticket avec support des décimales pour les dimensions (m²)
class TicketLine {
  final int productId;
  final String productName;
  final String unit;
  final double unitPrice;
  double quantity;
  double length;
  double width;

  TicketLine({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.unitPrice,
    this.quantity = 1.0,
    this.length = 0,
    this.width = 0,
  });

  bool get isDimensionLine =>
      unit.toLowerCase().contains('m²') || unit.toLowerCase().contains('m2');

  double get lineTotal => unitPrice * quantity;
}

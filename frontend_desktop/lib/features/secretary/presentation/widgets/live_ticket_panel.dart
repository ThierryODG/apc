import 'package:flutter/material.dart';
import '../../../../core/constants/app_colors.dart';
import '../../../../models/customer.dart';

/// Panier / Ticket en cours — colonne droite du POS (350px), style Aronium
class LiveTicketPanel extends StatelessWidget {
  final List<TicketLine> lines;
  final Customer? selectedCustomer;
  final double discountPercent;
  final VoidCallback onCancel;
  final VoidCallback onHold;
  final VoidCallback onCheckout;
  final VoidCallback onSelectCustomer;
  final Function(int index) onRemoveLine;
  final Function(int index, int qty) onUpdateQty;
  final Function(double percent) onDiscountChanged;

  const LiveTicketPanel({
    super.key,
    required this.lines,
    required this.selectedCustomer,
    required this.discountPercent,
    required this.onCancel,
    required this.onHold,
    required this.onCheckout,
    required this.onSelectCustomer,
    required this.onRemoveLine,
    required this.onUpdateQty,
    required this.onDiscountChanged,
  });

  double get _subTotal => lines.fold(0, (s, l) => s + l.lineTotal);
  double get _discount => _subTotal * discountPercent / 100;
  double get _total => _subTotal - _discount;

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000000) return '${(n ~/ 1000000)} ${((n % 1000000) ~/ 1000).toString().padLeft(3, '0')} ${(n % 1000).toString().padLeft(3, '0')} F';
    if (n >= 1000) {
      final thousands = n ~/ 1000;
      final remainder = n % 1000;
      return '$thousands ${remainder.toString().padLeft(3, '0')} F';
    }
    return '$n F';
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 350,
      decoration: const BoxDecoration(
        color: AppColors.blanc,
        border: Border(left: BorderSide(color: AppColors.bord)),
      ),
      child: Column(
        children: [
          // ── En-tête ticket ──────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
            color: AppColors.bleu,
            child: Row(
              children: [
                const Icon(Icons.receipt_long_rounded, color: Colors.white, size: 16),
                const SizedBox(width: 8),
                const Text(
                  'TICKET EN COURS',
                  style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                ),
                const Spacer(),
                Text(
                  '#${DateTime.now().millisecondsSinceEpoch % 100000}',
                  style: const TextStyle(color: AppColors.orange, fontSize: 11, fontWeight: FontWeight.w700),
                ),
              ],
            ),
          ),

          // ── Sélection client ────────────────────────────────
          InkWell(
            onTap: onSelectCustomer,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              decoration: const BoxDecoration(
                color: Color(0xFFF8FAFC),
                border: Border(bottom: BorderSide(color: AppColors.bord)),
              ),
              child: Row(
                children: [
                  const Icon(Icons.person_outline_rounded, size: 15, color: AppColors.gris),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      selectedCustomer?.name ?? 'Client Comptoir (aucun)',
                      style: TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        color: selectedCustomer != null ? AppColors.texte : AppColors.gris,
                      ),
                    ),
                  ),
                  const Icon(Icons.edit_rounded, size: 13, color: AppColors.gris),
                ],
              ),
            ),
          ),

          // ── Liste des lignes ────────────────────────────────
          Expanded(
            child: lines.isEmpty
                ? const Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.shopping_cart_outlined, size: 36, color: AppColors.bord),
                        SizedBox(height: 8),
                        Text('Aucun article', style: TextStyle(color: AppColors.gris, fontSize: 13)),
                        SizedBox(height: 4),
                        Text(
                          'Cliquez sur un produit pour l\'ajouter',
                          style: TextStyle(color: AppColors.gris, fontSize: 11),
                        ),
                      ],
                    ),
                  )
                : ListView.separated(
                    padding: const EdgeInsets.symmetric(vertical: 6),
                    itemCount: lines.length,
                    separatorBuilder: (_, __) => const Divider(height: 1, color: AppColors.bord),
                    itemBuilder: (context, i) => _TicketLineRow(
                      line: lines[i],
                      onRemove: () => onRemoveLine(i),
                      onQtyChanged: (qty) => onUpdateQty(i, qty),
                    ),
                  ),
          ),

          // ── Zone remise ─────────────────────────────────────
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.bord)),
              color: Color(0xFFF8FAFC),
            ),
            child: Row(
              children: [
                const Text('Remise :', style: TextStyle(fontSize: 12, color: AppColors.gris)),
                const SizedBox(width: 8),
                _DiscountButton(label: '0%', active: discountPercent == 0, onTap: () => onDiscountChanged(0)),
                _DiscountButton(label: '5%', active: discountPercent == 5, onTap: () => onDiscountChanged(5)),
                _DiscountButton(label: '10%', active: discountPercent == 10, onTap: () => onDiscountChanged(10)),
                _DiscountButton(label: '15%', active: discountPercent == 15, onTap: () => onDiscountChanged(15)),
              ],
            ),
          ),

          // ── Totaux ──────────────────────────────────────────
          Container(
            padding: const EdgeInsets.fromLTRB(14, 10, 14, 10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.bord)),
            ),
            child: Column(
              children: [
                _TotalRow(label: 'Sous-total', value: _fmt(_subTotal)),
                if (discountPercent > 0)
                  _TotalRow(label: 'Remise ($discountPercent%)', value: '- ${_fmt(_discount)}', valueColor: AppColors.rouge),
                const SizedBox(height: 6),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('TOTAL', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w900, color: AppColors.bleu)),
                    Text(
                      _fmt(_total),
                      style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w900, color: AppColors.bleu),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // ── Boutons d'action ────────────────────────────────
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.bord)),
            ),
            child: Column(
              children: [
                Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: lines.isEmpty ? null : onCancel,
                        icon: const Icon(Icons.close_rounded, size: 15),
                        label: const Text('Annuler', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.rouge,
                          side: const BorderSide(color: AppColors.rouge),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: lines.isEmpty ? null : onHold,
                        icon: const Icon(Icons.pause_circle_outline_rounded, size: 15),
                        label: const Text('En attente', style: TextStyle(fontSize: 12)),
                        style: OutlinedButton.styleFrom(
                          foregroundColor: AppColors.gris,
                          side: const BorderSide(color: AppColors.bord),
                          padding: const EdgeInsets.symmetric(vertical: 10),
                          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton.icon(
                    onPressed: lines.isEmpty ? null : onCheckout,
                    icon: const Icon(Icons.credit_card_rounded, size: 16),
                    label: const Text(
                      'ENCAISSER  F4',
                      style: TextStyle(fontSize: 13, fontWeight: FontWeight.w900, letterSpacing: 0.5),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.bleu,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 14),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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
  final Function(int qty) onQtyChanged;

  const _TicketLineRow({required this.line, required this.onRemove, required this.onQtyChanged});

  String _fmt(double v) {
    final n = v.toInt();
    if (n >= 1000) return '${n ~/ 1000} ${(n % 1000).toString().padLeft(3, '0')}';
    return n.toString();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  line.productName,
                  style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.texte),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${_fmt(line.unitPrice)} F / ${line.unit}',
                  style: const TextStyle(fontSize: 10, color: AppColors.gris),
                ),
              ],
            ),
          ),
          // Contrôle quantité
          Row(
            children: [
              _QtyBtn(icon: Icons.remove, onTap: () {
                if (line.qty > 1) onQtyChanged(line.qty - 1);
                else onRemove();
              }),
              Container(
                width: 32,
                alignment: Alignment.center,
                child: Text(
                  '${line.qty}',
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w900, color: AppColors.bleu),
                ),
              ),
              _QtyBtn(icon: Icons.add, onTap: () => onQtyChanged(line.qty + 1)),
            ],
          ),
          const SizedBox(width: 10),
          SizedBox(
            width: 68,
            child: Text(
              '${_fmt(line.lineTotal)} F',
              textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w900, color: AppColors.bleu),
            ),
          ),
          const SizedBox(width: 4),
          GestureDetector(
            onTap: onRemove,
            child: const Icon(Icons.delete_outline_rounded, size: 16, color: AppColors.rouge),
          ),
        ],
      ),
    );
  }
}

class _QtyBtn extends StatelessWidget {
  final IconData icon;
  final VoidCallback onTap;
  const _QtyBtn({required this.icon, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 22,
        height: 22,
        decoration: BoxDecoration(
          color: AppColors.fond,
          borderRadius: BorderRadius.circular(4),
          border: Border.all(color: AppColors.bord),
        ),
        child: Icon(icon, size: 13, color: AppColors.bleu),
      ),
    );
  }
}

class _DiscountButton extends StatelessWidget {
  final String label;
  final bool active;
  final VoidCallback onTap;
  const _DiscountButton({required this.label, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 4),
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
          decoration: BoxDecoration(
            color: active ? AppColors.orange : AppColors.fond,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: active ? AppColors.orange : AppColors.bord),
          ),
          child: Text(
            label,
            style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: active ? Colors.white : AppColors.gris),
          ),
        ),
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
          Text(label, style: const TextStyle(fontSize: 12, color: AppColors.gris)),
          Text(value, style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: valueColor ?? AppColors.texte)),
        ],
      ),
    );
  }
}

/// Modèle d'une ligne de ticket
class TicketLine {
  final int productId;
  final String productName;
  final String unit;
  final double unitPrice;
  int qty;

  TicketLine({
    required this.productId,
    required this.productName,
    required this.unit,
    required this.unitPrice,
    this.qty = 1,
  });

  double get lineTotal => unitPrice * qty;
}


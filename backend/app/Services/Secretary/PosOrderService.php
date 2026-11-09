<?php

namespace App\Services\Secretary;

use App\Models\CashFlow;
use App\Models\Customer;
use App\Models\FiscalYear;
use App\Models\Order;
use App\Models\OrderItem;
use App\Models\Payment;
use App\Models\Product;
use App\Models\User;
use Carbon\Carbon;
use Illuminate\Support\Facades\DB;

class PosOrderService
{
    /**
     * Crée une commande / ticket de caisse style Aronium.
     */
    public function createOrder(array $data, User $user, FiscalYear $fiscalYear): Order
    {
        return DB::transaction(function () use ($data, $user, $fiscalYear) {
            // Génération du numéro séquentiel annuel de ticket/commande
            $yearCode = $fiscalYear->code;
            $count = Order::where('fiscal_year_id', $fiscalYear->id)->count() + 1;
            $orderNumber = sprintf('TKT-%s-%05d', str_replace(['/', ' '], '-', $yearCode), $count);

            $order = Order::create([
                'fiscal_year_id' => $fiscalYear->id,
                'order_number' => $orderNumber,
                'customer_id' => $data['customer_id'] ?? null,
                'user_id' => $user->id,
                'order_date' => $data['order_date'] ?? Carbon::now(),
                'status' => 'confirmed',
                'subtotal' => 0,
                'tax_amount' => 0,
                'discount_amount' => 0,
                'total_amount' => 0,
                'paid_amount' => 0,
                'due_amount' => 0,
                'payment_status' => 'unpaid',
                'notes' => $data['notes'] ?? null,
            ]);

            $subtotalSum = 0;
            $taxSum = 0;
            $discountSum = 0;

            foreach ($data['items'] as $itemData) {
                $qty = (float) $itemData['quantity'];
                $unitPrice = (float) $itemData['unit_price'];
                $discount = (float) ($itemData['discount_amount'] ?? 0);
                $taxRate = (float) ($itemData['tax_rate'] ?? 0);

                $lineSubtotal = max(0, ($qty * $unitPrice) - $discount);
                $lineTax = $lineSubtotal * ($taxRate / 100);
                $lineTotal = $lineSubtotal + $lineTax;

                OrderItem::create([
                    'order_id' => $order->id,
                    'product_id' => $itemData['product_id'] ?? null,
                    'designation' => $itemData['designation'],
                    'unit' => $itemData['unit'] ?? 'unité',
                    'quantity' => $qty,
                    'unit_price' => $unitPrice,
                    'tax_rate' => $taxRate,
                    'discount_amount' => $discount,
                    'subtotal' => $lineSubtotal,
                    'total' => $lineTotal,
                    'notes' => $itemData['notes'] ?? null,
                ]);

                $subtotalSum += $lineSubtotal;
                $taxSum += $lineTax;
                $discountSum += $discount;
            }

            $totalAmount = $subtotalSum + $taxSum;

            $order->update([
                'subtotal' => $subtotalSum,
                'tax_amount' => $taxSum,
                'discount_amount' => $discountSum,
                'total_amount' => $totalAmount,
                'due_amount' => $totalAmount,
            ]);

            // Traitement de l'encaissement immédiat au guichet (si renseigné)
            if (! empty($data['payment']) && (float) $data['payment']['amount'] > 0) {
                $payAmount = (float) $data['payment']['amount'];
                $received = isset($data['payment']['amount_received']) ? (float) $data['payment']['amount_received'] : $payAmount;
                $change = max(0, $received - $payAmount);

                $payCount = Payment::where('fiscal_year_id', $fiscalYear->id)->count() + 1;
                $receiptNumber = sprintf('REC-%s-%05d', str_replace(['/', ' '], '-', $yearCode), $payCount);

                $payment = Payment::create([
                    'fiscal_year_id' => $fiscalYear->id,
                    'order_id' => $order->id,
                    'user_id' => $user->id,
                    'receipt_number' => $receiptNumber,
                    'payment_method' => $data['payment']['method'] ?? 'cash',
                    'amount' => $payAmount,
                    'amount_received' => $received,
                    'change_returned' => $change,
                    'payment_date' => Carbon::now(),
                    'reference_note' => $data['payment']['reference_note'] ?? null,
                ]);

                // Enregistrement automatique du flux de trésorerie (CashFlow)
                CashFlow::create([
                    'fiscal_year_id' => $fiscalYear->id,
                    'user_id' => $user->id,
                    'flow_type' => 'in',
                    'category' => 'vente_comptoir',
                    'amount' => $payAmount,
                    'payment_method' => $payment->payment_method,
                    'reference_type' => 'order',
                    'reference_id' => $order->id,
                    'description' => "Règlement ticket {$order->order_number} ({$payment->receipt_number})",
                    'flow_date' => Carbon::now(),
                ]);

                $order->refreshPaymentStatus();
            }

            return $order->load(['customer', 'items', 'payments']);
        });
    }

    /**
     * Ajoute un versement sur une commande existante.
     */
    public function recordPayment(Order $order, array $data, User $user, FiscalYear $fiscalYear): Payment
    {
        return DB::transaction(function () use ($order, $data, $user, $fiscalYear) {
            $payAmount = (float) $data['amount'];
            $received = isset($data['amount_received']) ? (float) $data['amount_received'] : $payAmount;
            $change = max(0, $received - $payAmount);

            $yearCode = $fiscalYear->code;
            $payCount = Payment::where('fiscal_year_id', $fiscalYear->id)->count() + 1;
            $receiptNumber = sprintf('REC-%s-%05d', str_replace(['/', ' '], '-', $yearCode), $payCount);

            $payment = Payment::create([
                'fiscal_year_id' => $fiscalYear->id,
                'order_id' => $order->id,
                'user_id' => $user->id,
                'receipt_number' => $receiptNumber,
                'payment_method' => $data['payment_method'],
                'amount' => $payAmount,
                'amount_received' => $received,
                'change_returned' => $change,
                'payment_date' => Carbon::now(),
                'reference_note' => $data['reference_note'] ?? null,
                'notes' => $data['notes'] ?? null,
            ]);

            CashFlow::create([
                'fiscal_year_id' => $fiscalYear->id,
                'user_id' => $user->id,
                'flow_type' => 'in',
                'category' => 'reglement_client',
                'amount' => $payAmount,
                'payment_method' => $data['payment_method'],
                'reference_type' => 'order',
                'reference_id' => $order->id,
                'description' => "Versement sur ticket {$order->order_number} ({$payment->receipt_number})",
                'flow_date' => Carbon::now(),
            ]);

            $order->refreshPaymentStatus();

            return $payment;
        });
    }
}


<?php

namespace App\Services\Secretary;

use App\Models\Company;
use App\Models\Order;

class ReceiptPrintService
{
    /**
     * Génère les données structurées prêtes pour l'impression de ticket / reçu.
     */
    public function formatReceipt(Order $order): array
    {
        $order->loadMissing(['customer', 'user', 'items', 'payments', 'fiscalYear']);
        $company = Company::current();

        $items = $order->items->map(function ($item) {
            return [
                'designation' => $item->designation,
                'unit' => $item->unit,
                'quantity' => (float) $item->quantity,
                'unit_price' => (float) $item->unit_price,
                'discount' => (float) $item->discount_amount,
                'total' => (float) $item->total,
            ];
        });

        $payments = $order->payments->map(function ($payment) {
            return [
                'receipt_number' => $payment->receipt_number,
                'method' => $payment->payment_method,
                'amount' => (float) $payment->amount,
                'amount_received' => (float) ($payment->amount_received ?? $payment->amount),
                'change_returned' => (float) $payment->change_returned,
                'date' => $payment->payment_date->format('d/m/Y H:i'),
            ];
        });

        return [
            'header' => [
                'company_name' => $company->name,
                'legal_form' => $company->legal_form,
                'ifu_number' => $company->ifu_number,
                'rccm_number' => $company->rccm_number,
                'address' => $company->address,
                'city' => $company->city,
                'phones' => array_filter([$company->phone_primary, $company->phone_secondary]),
                'email' => $company->email,
                'logo_url' => $company->logo_path,
                'custom_header' => $company->receipt_header,
            ],
            'ticket' => [
                'order_number' => $order->order_number,
                'date' => $order->order_date->format('d/m/Y H:i'),
                'cashier' => $order->user?->name ?? 'Secrétariat',
                'fiscal_year' => $order->fiscalYear?->name,
                'status' => $order->status,
                'payment_status' => $order->payment_status,
            ],
            'customer' => $order->customer ? [
                'code' => $order->customer->code,
                'name' => $order->customer->name,
                'phone' => $order->customer->phone,
                'ifu_number' => $order->customer->ifu_number,
            ] : [
                'name' => 'Client Comptoir (Passager)',
            ],
            'items' => $items,
            'totals' => [
                'subtotal' => (float) $order->subtotal,
                'discount' => (float) $order->discount_amount,
                'tax' => (float) $order->tax_amount,
                'total_amount' => (float) $order->total_amount,
                'paid_amount' => (float) $order->paid_amount,
                'due_amount' => (float) $order->due_amount,
                'currency' => $company->currency,
            ],
            'payments' => $payments,
            'footer' => [
                'message' => $company->receipt_footer,
                'printed_at' => now()->format('d/m/Y H:i:s'),
            ],
        ];
    }
}

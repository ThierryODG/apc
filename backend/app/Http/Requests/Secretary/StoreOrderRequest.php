<?php

namespace App\Http\Requests\Secretary;

use Illuminate\Foundation\Http\FormRequest;

class StoreOrderRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'customer_id' => ['nullable', 'exists:customers,id'],
            'order_date' => ['nullable', 'date'],
            'notes' => ['nullable', 'string'],
            'items' => ['required', 'array', 'min:1'],
            'items.*.product_id' => ['nullable', 'exists:products,id'],
            'items.*.designation' => ['required', 'string', 'max:200'],
            'items.*.unit' => ['nullable', 'string', 'max:30'],
            'items.*.quantity' => ['required', 'numeric', 'min:0.01'],
            'items.*.unit_price' => ['required', 'numeric', 'min:0'],
            'items.*.tax_rate' => ['nullable', 'numeric', 'min:0', 'max:100'],
            'items.*.discount_amount' => ['nullable', 'numeric', 'min:0'],
            'items.*.notes' => ['nullable', 'string'],

            // Règlement immédiat au guichet (optionnel comme dans Aronium)
            'payment' => ['nullable', 'array'],
            'payment.method' => ['required_with:payment', 'string', 'in:cash,mobile_money,bank_transfer,check,credit'],
            'payment.amount' => ['required_with:payment', 'numeric', 'min:0'],
            'payment.amount_received' => ['nullable', 'numeric', 'min:0'],
            'payment.reference_note' => ['nullable', 'string', 'max:100'],
        ];
    }
}


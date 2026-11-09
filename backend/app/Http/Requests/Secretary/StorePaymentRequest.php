<?php

namespace App\Http\Requests\Secretary;

use Illuminate\Foundation\Http\FormRequest;

class StorePaymentRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'payment_method' => ['required', 'string', 'in:cash,mobile_money,bank_transfer,check,credit'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'amount_received' => ['nullable', 'numeric', 'min:0'],
            'reference_note' => ['nullable', 'string', 'max:100'],
            'notes' => ['nullable', 'string'],
        ];
    }
}


<?php

namespace App\Http\Requests\Accounting;

use Illuminate\Foundation\Http\FormRequest;

class StoreCashFlowRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAccounting() || $this->user()?->isAdmin();
    }

    public function rules(): array
    {
        return [
            'flow_type' => ['required', 'string', 'in:in,out'],
            'category' => ['required', 'string', 'max:50'],
            'amount' => ['required', 'numeric', 'min:0.01'],
            'payment_method' => ['required', 'string', 'in:cash,mobile_money,bank_transfer,check'],
            'description' => ['required', 'string', 'max:255'],
            'flow_date' => ['nullable', 'date'],
        ];
    }
}


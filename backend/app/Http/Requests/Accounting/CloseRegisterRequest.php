<?php

namespace App\Http\Requests\Accounting;

use Illuminate\Foundation\Http\FormRequest;

class CloseRegisterRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->isAccounting() || $this->user()?->isAdmin();
    }

    public function rules(): array
    {
        return [
            'actual_closing_balance' => ['required', 'numeric', 'min:0'],
            'notes' => ['nullable', 'string'],
        ];
    }
}


<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class UpdatePriceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()?->can('catalog.edit') ?? false;
    }

    public function rules(): array
    {
        return [
            'unit_price' => ['required', 'numeric', 'min:0'],
            'reason' => ['nullable', 'string', 'max:255'],
        ];
    }

    public function messages(): array
    {
        return [
            'unit_price.required' => 'Le nouveau prix unitaire est obligatoire.',
            'unit_price.min' => 'Le prix unitaire ne peut pas être négatif.',
        ];
    }
}

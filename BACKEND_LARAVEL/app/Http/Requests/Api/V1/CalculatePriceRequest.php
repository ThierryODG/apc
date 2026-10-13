<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class CalculatePriceRequest extends FormRequest
{
    public function authorize(): bool
    {
        return true;
    }

    public function rules(): array
    {
        return [
            'service_id' => ['required', 'integer', 'exists:print_services,id'],
            'quantity' => ['nullable', 'numeric', 'min:0.01'],
            'width_cm' => ['nullable', 'numeric', 'min:0.1'],
            'height_cm' => ['nullable', 'numeric', 'min:0.1'],
            'option_ids' => ['nullable', 'array'],
            'option_ids.*' => ['integer', 'exists:service_options,id'],
        ];
    }

    public function messages(): array
    {
        return [
            'service_id.required' => 'La prestation d\'impression est obligatoire.',
            'service_id.exists' => 'La prestation spécifiée est introuvable.',
            'quantity.min' => 'La quantité doit être supérieure à zéro.',
            'width_cm.min' => 'La largeur en centimètres doit être positive.',
            'height_cm.min' => 'La hauteur en centimètres doit être positive.',
        ];
    }
}

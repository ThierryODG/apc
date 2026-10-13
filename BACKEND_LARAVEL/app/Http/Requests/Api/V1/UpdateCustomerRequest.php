<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;
use Illuminate\Validation\Rule;

class UpdateCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('customers.edit');
    }

    public function rules(): array
    {
        $customerId = $this->route('customer')?->id;

        return [
            'type'                => 'sometimes|in:individual,company',
            'name'                => 'sometimes|string|max:150',
            'trade_name'          => 'nullable|string|max:150',
            'email'               => [
                'nullable', 'email', 'max:150',
                Rule::unique('customers', 'email')->ignore($customerId),
            ],
            'phone'               => 'nullable|string|max:30',
            'phone_2'             => 'nullable|string|max:30',
            'rccm'                => 'nullable|string|max:80',
            'nif'                 => 'nullable|string|max:80',
            'website'             => 'nullable|url|max:200',
            'industry'            => 'nullable|string|max:100',
            'segment'             => 'nullable|in:vip,regular,occasional,new',
            'credit_limit'        => 'nullable|numeric|min:0',
            'payment_days'        => 'nullable|integer|min:0|max:90',
            'acquisition_channel' => 'nullable|in:walk_in,whatsapp,phone,referral,social_media,other',
            'is_active'           => 'nullable|boolean',
            'notes'               => 'nullable|string|max:1000',
        ];
    }
}

<?php

namespace App\Http\Requests\Api\V1;

use Illuminate\Foundation\Http\FormRequest;

class StoreCustomerRequest extends FormRequest
{
    public function authorize(): bool
    {
        return $this->user()->can('customers.create');
    }

    public function rules(): array
    {
        return [
            // Informations principales
            'type'                => 'required|in:individual,company',
            'name'                => 'required|string|max:150',
            'trade_name'          => 'nullable|string|max:150',
            'email'               => 'nullable|email|max:150|unique:customers,email',
            'phone'               => 'nullable|string|max:30',
            'phone_2'             => 'nullable|string|max:30',

            // Informations entreprise
            'rccm'                => 'nullable|string|max:80',
            'nif'                 => 'nullable|string|max:80',
            'website'             => 'nullable|url|max:200',
            'industry'            => 'nullable|string|max:100',

            // Segmentation
            'segment'             => 'nullable|in:vip,regular,occasional,new',
            'credit_limit'        => 'nullable|numeric|min:0',
            'payment_days'        => 'nullable|integer|min:0|max:90',
            'acquisition_channel' => 'nullable|in:walk_in,whatsapp,phone,referral,social_media,other',

            // Notes
            'notes'               => 'nullable|string|max:1000',

            // Adresse initiale (optionnelle)
            'address'                   => 'nullable|array',
            'address.address_line_1'    => 'required_with:address|string|max:200',
            'address.address_line_2'    => 'nullable|string|max:200',
            'address.district'          => 'nullable|string|max:100',
            'address.city'              => 'nullable|string|max:100',
            'address.delivery_notes'    => 'nullable|string|max:500',

            // Contact principal (optionnel, surtout pour entreprise)
            'contact'                   => 'nullable|array',
            'contact.first_name'        => 'required_with:contact|string|max:80',
            'contact.last_name'         => 'nullable|string|max:80',
            'contact.position'          => 'nullable|string|max:100',
            'contact.email'             => 'nullable|email|max:150',
            'contact.phone'             => 'nullable|string|max:30',
            'contact.receives_invoices' => 'nullable|boolean',
            'contact.receives_quotes'   => 'nullable|boolean',
        ];
    }

    public function messages(): array
    {
        return [
            'type.required'              => 'Le type de client est obligatoire.',
            'type.in'                    => 'Le type doit être "individual" ou "company".',
            'name.required'              => 'Le nom du client est obligatoire.',
            'email.unique'               => 'Cette adresse email est déjà utilisée par un autre client.',
            'email.email'                => 'L\'adresse email n\'est pas valide.',
            'credit_limit.min'           => 'Le plafond de crédit ne peut pas être négatif.',
            'payment_days.max'           => 'Le délai de paiement ne peut pas dépasser 90 jours.',
            'address.address_line_1.required_with' => 'L\'adresse principale est requise si un bloc adresse est fourni.',
            'contact.first_name.required_with'     => 'Le prénom du contact est requis si un bloc contact est fourni.',
        ];
    }
}

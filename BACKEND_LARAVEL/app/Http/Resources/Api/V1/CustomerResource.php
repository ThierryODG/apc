<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'                  => $this->id,
            'type'                => $this->type,
            'is_company'          => $this->is_company,
            'name'                => $this->name,
            'display_name'        => $this->display_name,
            'trade_name'          => $this->trade_name,
            'email'               => $this->email,
            'phone'               => $this->phone,
            'phone_2'             => $this->phone_2,

            // Infos entreprise (conditionnelles)
            $this->mergeWhen($this->type === 'company', [
                'rccm'     => $this->rccm,
                'nif'      => $this->nif,
                'website'  => $this->website,
                'industry' => $this->industry,
            ]),

            // Segmentation & crédit
            'segment'             => $this->segment,
            'credit_limit'        => (float) $this->credit_limit,
            'payment_days'        => $this->payment_days,
            'acquisition_channel' => $this->acquisition_channel,

            // Statut
            'is_active'           => $this->is_active,
            'notes'               => $this->when($request->user()?->can('customers.view_notes'), $this->notes),

            // Import Aronium (visible seulement pour les admins)
            'aronium_id'          => $this->when($request->user()?->hasRole('super_admin'), $this->aronium_id),

            // Relations (chargées à la demande)
            'contacts'            => CustomerContactResource::collection($this->whenLoaded('contacts')),
            'addresses'           => CustomerAddressResource::collection($this->whenLoaded('addresses')),
            'contacts_count'      => $this->whenCounted('contacts'),

            // Audit
            'created_by'          => $this->whenLoaded('createdBy', fn() => [
                'id'   => $this->createdBy->id,
                'name' => $this->createdBy->name,
            ]),
            'created_at'          => $this->created_at?->toISOString(),
            'updated_at'          => $this->updated_at?->toISOString(),
        ];
    }
}

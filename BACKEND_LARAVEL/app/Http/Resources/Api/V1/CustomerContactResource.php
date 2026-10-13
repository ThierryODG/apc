<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerContactResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'               => $this->id,
            'full_name'        => $this->full_name,
            'first_name'       => $this->first_name,
            'last_name'        => $this->last_name,
            'position'         => $this->position,
            'email'            => $this->email,
            'phone'            => $this->phone,
            'phone_2'          => $this->phone_2,
            'is_primary'       => $this->is_primary,
            'receives_invoices' => $this->receives_invoices,
            'receives_quotes'   => $this->receives_quotes,
            'notes'            => $this->notes,
        ];
    }
}

<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class CustomerAddressResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id'             => $this->id,
            'type'           => $this->type,
            'label'          => $this->label,
            'address_line_1' => $this->address_line_1,
            'address_line_2' => $this->address_line_2,
            'district'       => $this->district,
            'city'           => $this->city,
            'region'         => $this->region,
            'country'        => $this->country,
            'full_address'   => $this->full_address,
            'coordinates'    => ($this->latitude && $this->longitude)
                ? ['lat' => $this->latitude, 'lng' => $this->longitude]
                : null,
            'is_default'     => $this->is_default,
            'delivery_notes' => $this->delivery_notes,
        ];
    }
}

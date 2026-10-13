<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class PrintServiceResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'name' => $this->name,
            'code' => $this->code,
            'description' => $this->description,
            'pricing_type' => $this->pricing_type,
            'unit_price' => (float) $this->unit_price,
            'min_surface' => (float) $this->min_surface,
            'min_price' => (float) $this->min_price,
            'requires_dimensions' => $this->requires_dimensions,
            'requires_file' => $this->requires_file,
            'default_lead_time_hours' => $this->default_lead_time_hours,
            'is_active' => $this->is_active,
            'unit' => new UnitResource($this->whenLoaded('unit')),
            'department' => $this->whenLoaded('department', function () {
                return [
                    'id' => $this->department->id,
                    'name' => $this->department->name,
                    'code' => $this->department->code,
                ];
            }),
            'options' => $this->whenLoaded('options', function () {
                return $this->options->map(function ($opt) {
                    return [
                        'id' => $opt->id,
                        'name' => $opt->name,
                        'code' => $opt->code,
                        'price_type' => $opt->price_type,
                        'unit_price' => (float) $opt->unit_price,
                    ];
                });
            }),
        ];
    }
}

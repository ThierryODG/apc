<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class InquiryResource extends JsonResource
{
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'customer' => $this->whenLoaded('customer', fn () => $this->customer ? [
                'id' => $this->customer->id,
                'name' => $this->customer->name,
                'trade_name' => $this->customer->trade_name,
            ] : null),
            'source' => $this->source,
            'contact_name' => $this->contact_name,
            'contact_phone' => $this->contact_phone,
            'contact_email' => $this->contact_email,
            'subject' => $this->subject,
            'description' => $this->description,
            'status' => $this->status,
            'quote_amount' => $this->quote_amount === null ? null : (float) $this->quote_amount,
            'refusal_reason' => $this->refusal_reason,
            'qualified_at' => $this->qualified_at?->toISOString(),
            'quote_sent_at' => $this->quote_sent_at?->toISOString(),
            'refused_at' => $this->refused_at?->toISOString(),
            'created_by' => $this->whenLoaded('creator', fn () => $this->creator ? [
                'id' => $this->creator->id,
                'name' => $this->creator->name,
            ] : null),
            'created_at' => $this->created_at?->toISOString(),
            'updated_at' => $this->updated_at?->toISOString(),
        ];
    }
}

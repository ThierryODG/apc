<?php

namespace App\Http\Resources\Api\V1;

use Illuminate\Http\Request;
use Illuminate\Http\Resources\Json\JsonResource;

class OrderResource extends JsonResource
{
    /**
     * Transform the resource into an array.
     *
     * @return array<string, mixed>
     */
    public function toArray(Request $request): array
    {
        return [
            'id' => $this->id,
            'order_number' => $this->order_number,
            'customer' => $this->whenLoaded('customer', fn () => $this->customer ? [
                'id' => $this->customer->id,
                'name' => $this->customer->display_name,
            ] : null),
            'inquiry_id' => $this->inquiry_id,
            'source' => $this->source,
            'contact_name' => $this->contact_name,
            'contact_phone' => $this->contact_phone,
            'contact_email' => $this->contact_email,
            'subject' => $this->subject,
            'description' => $this->description,
            'quoted_total' => (float) $this->quoted_total,
            'status' => $this->status,
            'ordered_at' => $this->ordered_at?->toISOString(),
            'work_orders' => WorkOrderResource::collection($this->whenLoaded('workOrders')),
        ];
    }
}

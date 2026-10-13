<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Builder;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerAddress extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'type',
        'label',
        'address_line_1',
        'address_line_2',
        'district',
        'city',
        'region',
        'country',
        'latitude',
        'longitude',
        'is_default',
        'delivery_notes',
    ];

    protected $casts = [
        'latitude'   => 'float',
        'longitude'  => 'float',
        'is_default' => 'boolean',
    ];

    // ─── Relations ───────────────────────────────────────────────────────────

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    // ─── Scopes ──────────────────────────────────────────────────────────────

    public function scopeDelivery(Builder $query): Builder
    {
        return $query->whereIn('type', ['delivery', 'both']);
    }

    public function scopeBilling(Builder $query): Builder
    {
        return $query->whereIn('type', ['billing', 'both']);
    }

    // ─── Accessors ───────────────────────────────────────────────────────────

    /**
     * Adresse complète formatée sur une ligne.
     */
    public function getFullAddressAttribute(): string
    {
        $parts = array_filter([
            $this->address_line_1,
            $this->address_line_2,
            $this->district,
            $this->city,
            $this->region,
            $this->country,
        ]);

        return implode(', ', $parts);
    }
}

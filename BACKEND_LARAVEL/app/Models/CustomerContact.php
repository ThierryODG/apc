<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class CustomerContact extends Model
{
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'first_name',
        'last_name',
        'position',
        'email',
        'phone',
        'phone_2',
        'is_primary',
        'receives_invoices',
        'receives_quotes',
        'notes',
    ];

    protected $casts = [
        'is_primary'       => 'boolean',
        'receives_invoices' => 'boolean',
        'receives_quotes'   => 'boolean',
    ];

    // ─── Relations ───────────────────────────────────────────────────────────

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    // ─── Accessors ───────────────────────────────────────────────────────────

    public function getFullNameAttribute(): string
    {
        return trim("{$this->first_name} {$this->last_name}");
    }
}

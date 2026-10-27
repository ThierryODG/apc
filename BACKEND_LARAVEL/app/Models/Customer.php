<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;
use Illuminate\Database\Eloquent\SoftDeletes;

class Customer extends Model
{
    use HasFactory, SoftDeletes;

    protected $fillable = [
        'type',
        'name',
        'trade_name',
        'email',
        'phone',
        'phone_2',
        'rccm',
        'nif',
        'website',
        'industry',
        'segment',
        'credit_limit',
        'payment_days',
        'acquisition_channel',
        'aronium_id',
        'is_active',
        'notes',
        'created_by',
    ];

    protected $casts = [
        'credit_limit' => 'decimal:2',
        'payment_days' => 'integer',
        'is_active' => 'boolean',
    ];

    // ─── Relations ───────────────────────────────────────────────────────────

    public function contacts(): HasMany
    {
        return $this->hasMany(CustomerContact::class);
    }

    public function primaryContact(): HasMany
    {
        return $this->hasMany(CustomerContact::class)->where('is_primary', true);
    }

    public function addresses(): HasMany
    {
        return $this->hasMany(CustomerAddress::class);
    }

    public function inquiries(): HasMany
    {
        return $this->hasMany(Inquiry::class);
    }

    public function defaultDeliveryAddress(): HasMany
    {
        return $this->hasMany(CustomerAddress::class)
            ->whereIn('type', ['delivery', 'both'])
            ->where('is_default', true);
    }

    public function createdBy(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    // ─── Scopes ──────────────────────────────────────────────────────────────

    public function scopeActive($query)
    {
        return $query->where('is_active', true);
    }

    public function scopeCompanies($query)
    {
        return $query->where('type', 'company');
    }

    public function scopeIndividuals($query)
    {
        return $query->where('type', 'individual');
    }

    public function scopeVip($query)
    {
        return $query->where('segment', 'vip');
    }

    /**
     * Recherche plein texte sur nom, email, téléphone.
     */
    public function scopeSearch($query, string $term)
    {
        return $query->where(function ($q) use ($term) {
            $q->where('name', 'ilike', "%{$term}%")
                ->orWhere('trade_name', 'ilike', "%{$term}%")
                ->orWhere('email', 'ilike', "%{$term}%")
                ->orWhere('phone', 'like', "%{$term}%")
                ->orWhere('phone_2', 'like', "%{$term}%")
                ->orWhere('aronium_id', 'like', "%{$term}%");
        });
    }

    // ─── Accessors ───────────────────────────────────────────────────────────

    public function getDisplayNameAttribute(): string
    {
        return $this->trade_name ?? $this->name;
    }

    public function getIsCompanyAttribute(): bool
    {
        return $this->type === 'company';
    }
}

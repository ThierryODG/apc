<?php

namespace App\Models;

use Database\Factories\InquiryFactory;
use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\HasMany;

class Inquiry extends Model
{
    /** @use HasFactory<InquiryFactory> */
    use HasFactory;

    protected $fillable = [
        'customer_id',
        'created_by',
        'qualified_by',
        'quote_sent_by',
        'refused_by',
        'source',
        'contact_name',
        'contact_phone',
        'contact_email',
        'subject',
        'description',
        'status',
        'quote_amount',
        'refusal_reason',
        'qualified_at',
        'quote_sent_at',
        'refused_at',
    ];

    protected function casts(): array
    {
        return [
            'quote_amount' => 'decimal:2',
            'qualified_at' => 'datetime',
            'quote_sent_at' => 'datetime',
            'refused_at' => 'datetime',
        ];
    }

    public function customer(): BelongsTo
    {
        return $this->belongsTo(Customer::class);
    }

    public function creator(): BelongsTo
    {
        return $this->belongsTo(User::class, 'created_by');
    }

    public function files(): HasMany
    {
        return $this->hasMany(InquiryFile::class);
    }
}

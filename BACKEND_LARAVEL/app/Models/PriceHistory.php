<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;

class PriceHistory extends Model
{
    use HasFactory;

    protected $fillable = [
        'print_service_id',
        'user_id',
        'old_price',
        'new_price',
        'reason',
    ];

    protected function casts(): array
    {
        return [
            'old_price' => 'decimal:2',
            'new_price' => 'decimal:2',
        ];
    }

    public function printService(): BelongsTo
    {
        return $this->belongsTo(PrintService::class);
    }

    public function user(): BelongsTo
    {
        return $this->belongsTo(User::class);
    }
}

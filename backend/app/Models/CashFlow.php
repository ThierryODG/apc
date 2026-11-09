<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class CashFlow extends Model
{
    use HasFactory;

    protected $fillable = [
        'fiscal_year_id',
        'user_id',
        'flow_type', // 'in', 'out'
        'category',
        'amount',
        'payment_method',
        'reference_type',
        'reference_id',
        'description',
        'flow_date',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'flow_date' => 'datetime',
        ];
    }

    public function fiscalYear()
    {
        return $this->belongsTo(FiscalYear::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}

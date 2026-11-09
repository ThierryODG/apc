<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Payment extends Model
{
    use HasFactory;

    protected $fillable = [
        'fiscal_year_id',
        'order_id',
        'user_id',
        'receipt_number',
        'payment_method', // cash, mobile_money, bank_transfer, check, credit
        'amount',
        'amount_received',
        'change_returned',
        'payment_date',
        'reference_note',
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'amount' => 'decimal:2',
            'amount_received' => 'decimal:2',
            'change_returned' => 'decimal:2',
            'payment_date' => 'datetime',
        ];
    }

    public function fiscalYear()
    {
        return $this->belongsTo(FiscalYear::class);
    }

    public function order()
    {
        return $this->belongsTo(Order::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }
}


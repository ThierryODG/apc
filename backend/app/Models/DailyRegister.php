<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class DailyRegister extends Model
{
    use HasFactory;

    protected $fillable = [
        'fiscal_year_id',
        'user_id',
        'register_date',
        'opened_at',
        'closed_at',
        'opening_balance',
        'cash_sales_total',
        'cash_in_total',
        'cash_out_total',
        'expected_closing_balance',
        'actual_closing_balance',
        'discrepancy',
        'status', // 'open', 'closed'
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'register_date' => 'date',
            'opened_at' => 'datetime',
            'closed_at' => 'datetime',
            'opening_balance' => 'decimal:2',
            'cash_sales_total' => 'decimal:2',
            'cash_in_total' => 'decimal:2',
            'cash_out_total' => 'decimal:2',
            'expected_closing_balance' => 'decimal:2',
            'actual_closing_balance' => 'decimal:2',
            'discrepancy' => 'decimal:2',
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

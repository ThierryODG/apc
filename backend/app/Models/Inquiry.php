<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Inquiry extends Model
{
    use HasFactory;

    protected $fillable = [
        'fiscal_year_id',
        'customer_id',
        'user_id',
        'quote_number',
        'title',
        'description',
        'estimated_amount',
        'status', // pending, sent, accepted, rejected, converted
        'converted_order_id',
        'valid_until',
    ];

    protected function casts(): array
    {
        return [
            'estimated_amount' => 'decimal:2',
            'valid_until' => 'date',
        ];
    }

    public function fiscalYear()
    {
        return $this->belongsTo(FiscalYear::class);
    }

    public function customer()
    {
        return $this->belongsTo(Customer::class);
    }

    public function user()
    {
        return $this->belongsTo(User::class);
    }

    public function convertedOrder()
    {
        return $this->belongsTo(Order::class, 'converted_order_id');
    }
}

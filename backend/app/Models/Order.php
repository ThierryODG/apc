<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Order extends Model
{
    use HasFactory;

    protected $fillable = [
        'fiscal_year_id',
        'order_number',
        'customer_id',
        'user_id',
        'order_date',
        'status', // draft, confirmed, in_production, ready, delivered, cancelled
        'subtotal',
        'tax_amount',
        'discount_amount',
        'total_amount',
        'paid_amount',
        'due_amount',
        'payment_status', // unpaid, partial, paid
        'notes',
    ];

    protected function casts(): array
    {
        return [
            'order_date' => 'datetime',
            'subtotal' => 'decimal:2',
            'tax_amount' => 'decimal:2',
            'discount_amount' => 'decimal:2',
            'total_amount' => 'decimal:2',
            'paid_amount' => 'decimal:2',
            'due_amount' => 'decimal:2',
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

    public function items()
    {
        return $this->hasMany(OrderItem::class);
    }

    public function payments()
    {
        return $this->hasMany(Payment::class);
    }

    /**
     * Recalcule les totaux et le statut de paiement suite à un versement.
     */
    public function refreshPaymentStatus(): void
    {
        $totalPaid = (float) $this->payments()->sum('amount');
        $total = (float) $this->total_amount;
        $due = max(0, $total - $totalPaid);

        $status = 'unpaid';
        if ($totalPaid >= $total && $total > 0) {
            $status = 'paid';
        } elseif ($totalPaid > 0) {
            $status = 'partial';
        }

        $this->update([
            'paid_amount' => $totalPaid,
            'due_amount' => $due,
            'payment_status' => $status,
        ]);
    }
}


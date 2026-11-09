<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Product extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'code',
        'name',
        'description',
        'unit',
        'unit_price',
        'tax_rate',
        'is_active',
        'allow_dimensions',
        'length_field',
        'width_field',
        'length_label',
        'width_label',
        'default_length',
        'default_width',
    ];

    protected function casts(): array
    {
        return [
            'unit_price' => 'decimal:2',
            'tax_rate' => 'decimal:2',
            'is_active' => 'boolean',
            'allow_dimensions' => 'boolean',
            'length_field' => 'boolean',
            'width_field' => 'boolean',
            'default_length' => 'decimal:2',
            'default_width' => 'decimal:2',
        ];
    }

    public function category()
    {
        return $this->belongsTo(ProductCategory::class, 'category_id');
    }

    public function orderItems()
    {
        return $this->hasMany(OrderItem::class);
    }
}


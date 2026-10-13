<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;
use Illuminate\Database\Eloquent\Relations\BelongsTo;
use Illuminate\Database\Eloquent\Relations\BelongsToMany;
use Illuminate\Database\Eloquent\Relations\HasMany;

class PrintService extends Model
{
    use HasFactory;

    protected $fillable = [
        'category_id',
        'department_id',
        'unit_id',
        'name',
        'code',
        'description',
        'pricing_type',
        'unit_price',
        'min_surface',
        'min_price',
        'requires_dimensions',
        'requires_file',
        'default_lead_time_hours',
        'is_active',
    ];

    protected function casts(): array
    {
        return [
            'unit_price' => 'decimal:2',
            'min_surface' => 'decimal:2',
            'min_price' => 'decimal:2',
            'requires_dimensions' => 'boolean',
            'requires_file' => 'boolean',
            'default_lead_time_hours' => 'integer',
            'is_active' => 'boolean',
        ];
    }

    public function category(): BelongsTo
    {
        return $this->belongsTo(ServiceCategory::class, 'category_id');
    }

    public function department(): BelongsTo
    {
        return $this->belongsTo(Department::class);
    }

    public function unit(): BelongsTo
    {
        return $this->belongsTo(Unit::class);
    }

    public function options(): BelongsToMany
    {
        return $this->belongsToMany(ServiceOption::class, 'print_service_service_option');
    }

    public function priceHistories(): HasMany
    {
        return $this->hasMany(PriceHistory::class)->orderByDesc('created_at');
    }
}

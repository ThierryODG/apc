<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Factories\HasFactory;
use Illuminate\Database\Eloquent\Model;

class Company extends Model
{
    use HasFactory;

    protected $fillable = [
        'name',
        'legal_form',
        'ifu_number',
        'rccm_number',
        'phone_primary',
        'phone_secondary',
        'email',
        'address',
        'city',
        'currency',
        'logo_path',
        'receipt_header',
        'receipt_footer',
    ];

    /**
     * Singleton helper pour obtenir les informations de l'entreprise.
     */
    public static function current(): self
    {
        return static::firstOrCreate([], [
            'name' => 'Africa Print Communication',
            'legal_form' => 'SARL',
            'ifu_number' => '0202011234567',
            'phone_primary' => '+225 07 00 00 00 00',
            'email' => 'contact@africaprint.com',
            'address' => 'Siège Commercial',
            'city' => 'Abidjan',
            'currency' => 'FCFA',
            'receipt_footer' => 'Merci de votre confiance ! Les impressions vérifiées ne sont ni reprises ni échangées.',
        ]);
    }
}


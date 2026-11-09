<?php

namespace Database\Seeders;

use App\Models\Product;
use App\Models\ProductCategory;
use Illuminate\Database\Seeder;

class ProductCatalogSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Catégorie : Impression Numérique & Documents
        $catNumerique = ProductCategory::updateOrCreate(
            ['code' => 'CAT-NUM'],
            ['name' => 'Impression Numérique & Bureautique', 'description' => 'Tirages de documents, mémoires, rapports']
        );

        Product::updateOrCreate(
            ['code' => 'IMP-A4-NB'],
            [
                'category_id' => $catNumerique->id,
                'name' => 'Photocopie & Impression A4 Noir et Blanc',
                'unit' => 'page',
                'unit_price' => 50,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'IMP-A4-COL'],
            [
                'category_id' => $catNumerique->id,
                'name' => 'Impression A4 Couleur Haute Qualité',
                'unit' => 'page',
                'unit_price' => 200,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'IMP-A3-COL'],
            [
                'category_id' => $catNumerique->id,
                'name' => 'Impression A3 Couleur',
                'unit' => 'page',
                'unit_price' => 400,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'FIN-RELIURE-SPIRALE'],
            [
                'category_id' => $catNumerique->id,
                'name' => 'Reliure Spirale Plastique + Transparent',
                'unit' => 'exemplaire',
                'unit_price' => 1000,
                'tax_rate' => 0,
            ]
        );

        // 2. Catégorie : Publicité & Grand Format
        $catGrandFormat = ProductCategory::updateOrCreate(
            ['code' => 'CAT-GF'],
            ['name' => 'Grand Format & Signalétique', 'description' => 'Bâches, vinyles, roll-up, enseignes']
        );

        Product::updateOrCreate(
            ['code' => 'BACHE-EXT-M2'],
            [
                'category_id' => $catGrandFormat->id,
                'name' => 'Impression Bâche Frontlit avec œillets',
                'unit' => 'm2',
                'unit_price' => 6500,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'ROLLUP-ALU'],
            [
                'category_id' => $catGrandFormat->id,
                'name' => 'Roll-Up Standard 85 x 200 cm (Structure + Visuel)',
                'unit' => 'pièce',
                'unit_price' => 25000,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'VINYLE-AUTO'],
            [
                'category_id' => $catGrandFormat->id,
                'name' => 'Autocollant / Vinyle Adhésif Brillant',
                'unit' => 'm2',
                'unit_price' => 7500,
                'tax_rate' => 0,
            ]
        );

        // 3. Catégorie : Cartes & Papeterie Commerciale
        $catCartes = ProductCategory::updateOrCreate(
            ['code' => 'CAT-PAP'],
            ['name' => 'Cartes & Papeterie Commerciale', 'description' => 'Cartes de visite, flyers, dépliants']
        );

        Product::updateOrCreate(
            ['code' => 'CARTE-VISITE-100'],
            [
                'category_id' => $catCartes->id,
                'name' => 'Cartes de Visite 350g Recto/Verso Pelliculé (Lot de 100)',
                'unit' => 'lot',
                'unit_price' => 10000,
                'tax_rate' => 0,
            ]
        );

        Product::updateOrCreate(
            ['code' => 'FLYER-A5-1000'],
            [
                'category_id' => $catCartes->id,
                'name' => 'Flyers A5 135g Couleur R/V (Pack de 1000)',
                'unit' => 'pack',
                'unit_price' => 45000,
                'tax_rate' => 0,
            ]
        );
    }
}


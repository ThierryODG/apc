<?php

namespace Database\Seeders;

use App\Models\Department;
use App\Models\PrintService;
use App\Models\ServiceCategory;
use App\Models\ServiceOption;
use App\Models\Unit;
use Illuminate\Database\Seeder;

class CatalogSeeder extends Seeder
{
    public function run(): void
    {
        // 1. Récupération des départements nécessaires
        $numDept = Department::where('code', 'NUMERIQUE')->first();
        $seriDept = Department::where('code', 'SERIGRAPHIE')->first();
        $paoDept = Department::where('code', 'PAO')->first();
        $finiDept = Department::where('code', 'FINITION')->first();

        // 2. Unités de mesure
        $m2 = Unit::firstOrCreate(['code' => 'M2'], [
            'name' => 'Mètre carré',
            'symbol' => 'm²',
            'type' => 'surface',
            'is_active' => true,
        ]);

        $piece = Unit::firstOrCreate(['code' => 'PIECE'], [
            'name' => 'Pièce / Unité',
            'symbol' => 'u',
            'type' => 'quantity',
            'is_active' => true,
        ]);

        $ml = Unit::firstOrCreate(['code' => 'ML'], [
            'name' => 'Mètre linéaire',
            'symbol' => 'ml',
            'type' => 'length',
            'is_active' => true,
        ]);

        $forfait = Unit::firstOrCreate(['code' => 'FORFAIT'], [
            'name' => 'Forfait création',
            'symbol' => 'ft',
            'type' => 'flat',
            'is_active' => true,
        ]);

        // 3. Catégories de prestations
        $catGrandFormat = ServiceCategory::firstOrCreate(['code' => 'GRAND_FORMAT'], [
            'name' => 'Impression Grand Format',
            'department_id' => $numDept?->id,
            'description' => 'Bâches PVC, vinyles adhésifs, micro-perforés et toiles.',
            'display_order' => 1,
            'is_active' => true,
        ]);

        $catTextile = ServiceCategory::firstOrCreate(['code' => 'TEXTILE_OBJETS'], [
            'name' => 'Marquage Textile & Objets',
            'department_id' => $seriDept?->id,
            'description' => 'Impression DTF, sublimation, tee-shirts, casquettes et goodies.',
            'display_order' => 2,
            'is_active' => true,
        ]);

        $catPlv = ServiceCategory::firstOrCreate(['code' => 'SIGNALETIQUE_PLV'], [
            'name' => 'Signalétique & PLV',
            'department_id' => $numDept?->id,
            'description' => 'Roll-ups, kakémonos, panneaux et présentoirs.',
            'display_order' => 3,
            'is_active' => true,
        ]);

        $catPao = ServiceCategory::firstOrCreate(['code' => 'CONCEPTION_PAO'], [
            'name' => 'Conception Graphique',
            'department_id' => $paoDept?->id,
            'description' => 'Création de maquettes, retouches graphiques et vectorisation.',
            'display_order' => 4,
            'is_active' => true,
        ]);

        // 4. Options & Finitions
        $optOeillets = ServiceOption::firstOrCreate(['code' => 'OEILLETS'], [
            'name' => 'Pose d\'œillets sur le pourtour',
            'department_id' => $finiDept?->id,
            'description' => 'Pose d\'œillets métalliques tous les 50cm.',
            'price_type' => 'per_meter',
            'unit_price' => 250.00,
            'is_active' => true,
        ]);

        $optOurlet = ServiceOption::firstOrCreate(['code' => 'OURLET_RENFORT'], [
            'name' => 'Ourlet de renfort thermosoudé',
            'department_id' => $finiDept?->id,
            'description' => 'Renfort soudé pour bâches extérieures soumises au vent.',
            'price_type' => 'per_meter',
            'unit_price' => 300.00,
            'is_active' => true,
        ]);

        $optPellicMat = ServiceOption::firstOrCreate(['code' => 'PELLICULAGE_MAT'], [
            'name' => 'Pelliculage mat protecteur',
            'department_id' => $finiDept?->id,
            'description' => 'Film anti-UV mat pour vinyle.',
            'price_type' => 'per_sqm',
            'unit_price' => 500.00,
            'is_active' => true,
        ]);

        $optDecoupeForme = ServiceOption::firstOrCreate(['code' => 'DECOUPE_FORME'], [
            'name' => 'Découpe numérique mi-chair',
            'department_id' => $finiDept?->id,
            'description' => 'Découpe d\'autocollants et étiquettes selon tracé vectoriel.',
            'price_type' => 'per_sqm',
            'unit_price' => 750.00,
            'is_active' => true,
        ]);

        // 5. Prestations réelles
        // Bâche 440g
        $bache = PrintService::firstOrCreate(['code' => 'IMP-BACHE-440'], [
            'category_id' => $catGrandFormat->id,
            'department_id' => $numDept?->id,
            'unit_id' => $m2->id,
            'name' => 'Impression Bâche Standard 440g',
            'description' => 'Impression haute définition pour banderoles et affichages extérieurs.',
            'pricing_type' => 'surface',
            'unit_price' => 2000.00,
            'min_surface' => 0.5,
            'min_price' => 1000.00,
            'requires_dimensions' => true,
            'requires_file' => true,
            'default_lead_time_hours' => 24,
            'is_active' => true,
        ]);
        $bache->options()->syncWithoutDetaching([$optOeillets->id, $optOurlet->id]);

        // Vinyle blanc
        $vinyle = PrintService::firstOrCreate(['code' => 'IMP-VINYLE-BLANC'], [
            'category_id' => $catGrandFormat->id,
            'department_id' => $numDept?->id,
            'unit_id' => $m2->id,
            'name' => 'Impression Vinyle Adhésif Blanc',
            'description' => 'Vinyle brillant ou mat pour vitrines, véhicules et panneaux.',
            'pricing_type' => 'surface',
            'unit_price' => 2500.00,
            'min_surface' => 0.25,
            'min_price' => 1000.00,
            'requires_dimensions' => true,
            'requires_file' => true,
            'default_lead_time_hours' => 24,
            'is_active' => true,
        ]);
        $vinyle->options()->syncWithoutDetaching([$optPellicMat->id, $optDecoupeForme->id]);

        // Micro-perforé One Way
        PrintService::firstOrCreate(['code' => 'IMP-ONE-WAY'], [
            'category_id' => $catGrandFormat->id,
            'department_id' => $numDept?->id,
            'unit_id' => $m2->id,
            'name' => 'Impression Micro-perforé (One Way)',
            'description' => 'Adhésif micro-perforé pour vitrines de boutiques et lunettes arrières.',
            'pricing_type' => 'surface',
            'unit_price' => 4000.00,
            'min_surface' => 0.5,
            'min_price' => 2000.00,
            'requires_dimensions' => true,
            'requires_file' => true,
            'default_lead_time_hours' => 48,
            'is_active' => true,
        ]);

        // DTF A3
        PrintService::firstOrCreate(['code' => 'DTF-A3'], [
            'category_id' => $catTextile->id,
            'department_id' => $seriDept?->id,
            'unit_id' => $piece->id,
            'name' => 'Impression DTF Format A3',
            'description' => 'Feuille de transfert DTF textile prête à poser au format A3.',
            'pricing_type' => 'fixed_unit',
            'unit_price' => 1000.00,
            'min_surface' => 0,
            'min_price' => 1000.00,
            'requires_dimensions' => false,
            'requires_file' => true,
            'default_lead_time_hours' => 12,
            'is_active' => true,
        ]);

        // Roll-Up
        PrintService::firstOrCreate(['code' => 'ROLLUP-85X200'], [
            'category_id' => $catPlv->id,
            'department_id' => $numDept?->id,
            'unit_id' => $piece->id,
            'name' => 'Roll-Up Dérouleur Complet 85x200cm',
            'description' => 'Structure aluminium avec impression bâche anti-curling et housse de transport.',
            'pricing_type' => 'fixed_unit',
            'unit_price' => 40000.00,
            'min_surface' => 0,
            'min_price' => 40000.00,
            'requires_dimensions' => false,
            'requires_file' => true,
            'default_lead_time_hours' => 24,
            'is_active' => true,
        ]);

        // Maquette Graphique
        PrintService::firstOrCreate(['code' => 'MAQUETTE-CREA'], [
            'category_id' => $catPao->id,
            'department_id' => $paoDept?->id,
            'unit_id' => $forfait->id,
            'name' => 'Conception de Maquette Graphique',
            'description' => 'Création graphique personnalisée par un infographiste PAO.',
            'pricing_type' => 'flat_fee',
            'unit_price' => 5000.00,
            'min_surface' => 0,
            'min_price' => 5000.00,
            'requires_dimensions' => false,
            'requires_file' => false,
            'default_lead_time_hours' => 24,
            'is_active' => true,
        ]);
    }
}

<?php

namespace App\Domain\Catalog\Actions;

use App\Domain\Catalog\DTO\PriceCalculationDTO;
use App\Models\PrintService;
use App\Models\ServiceOption;
use InvalidArgumentException;

class CalculatePrintPriceAction
{
    /**
     * Calcule le devis détaillé pour une prestation d'impression et ses options.
     *
     * @return array<string, mixed>
     */
    public function execute(PriceCalculationDTO $dto): array
    {
        $service = PrintService::with(['unit', 'options'])->findOrFail($dto->serviceId);

        $quantity = max(1.0, $dto->quantity);
        $unitSurfaceSqm = 0.0;
        $totalSurfaceSqm = 0.0;
        $perimeterMeters = 0.0;

        if ($service->requires_dimensions) {
            if (!$dto->widthCm || !$dto->heightCm || $dto->widthCm <= 0 || $dto->heightCm <= 0) {
                throw new InvalidArgumentException(
                    "La prestation '{$service->name}' exige des dimensions valides (largeur et hauteur en cm)."
                );
            }

            // Calcul surface en mètres carrés (largeur_cm * hauteur_cm / 10 000)
            $calcSurface = ($dto->widthCm * $dto->heightCm) / 10000.0;
            // Respect de la surface minimale facturable
            $unitSurfaceSqm = max($calcSurface, (float) $service->min_surface);
            $totalSurfaceSqm = round($unitSurfaceSqm * $quantity, 4);

            // Périmètre en mètres pour finitions type œillets / renforts : 2 * (largeur + hauteur) / 100
            $perimeterMeters = (2 * ($dto->widthCm + $dto->heightCm)) / 100.0;
        }

        // Calcul du prix de base
        $basePrice = match ($service->pricing_type) {
            'surface' => (float) $service->unit_price * $totalSurfaceSqm,
            'fixed_unit' => (float) $service->unit_price * $quantity,
            'flat_fee' => (float) $service->unit_price,
            default => (float) $service->unit_price * $quantity,
        };

        // Application du minimum de commande éventuel
        if ($service->min_price > 0 && $basePrice < (float) $service->min_price) {
            $basePrice = (float) $service->min_price;
        }

        $basePrice = round($basePrice, 2);

        // Calcul des finitions et options
        $optionsDetails = [];
        $optionsTotal = 0.0;

        if (!empty($dto->optionIds)) {
            $selectedOptions = ServiceOption::whereIn('id', $dto->optionIds)
                ->where('is_active', true)
                ->get();

            foreach ($selectedOptions as $option) {
                $optionCost = match ($option->price_type) {
                    'fixed' => (float) $option->unit_price,
                    'per_unit' => (float) $option->unit_price * $quantity,
                    'per_sqm' => (float) $option->unit_price * $totalSurfaceSqm,
                    'per_meter' => (float) $option->unit_price * ($perimeterMeters * $quantity),
                    default => (float) $option->unit_price * $quantity,
                };

                $optionCost = round($optionCost, 2);
                $optionsTotal += $optionCost;

                $optionsDetails[] = [
                    'id' => $option->id,
                    'name' => $option->name,
                    'code' => $option->code,
                    'price_type' => $option->price_type,
                    'unit_price' => (float) $option->unit_price,
                    'calculated_price' => $optionCost,
                ];
            }
        }

        $totalPrice = round($basePrice + $optionsTotal, 2);

        return [
            'service' => [
                'id' => $service->id,
                'name' => $service->name,
                'code' => $service->code,
                'pricing_type' => $service->pricing_type,
                'unit' => $service->unit ? [
                    'id' => $service->unit->id,
                    'name' => $service->unit->name,
                    'code' => $service->unit->code,
                    'symbol' => $service->unit->symbol,
                ] : null,
                'unit_price' => (float) $service->unit_price,
            ],
            'dimensions' => $service->requires_dimensions ? [
                'width_cm' => $dto->widthCm,
                'height_cm' => $dto->heightCm,
                'unit_surface_sqm' => $unitSurfaceSqm,
                'total_surface_sqm' => $totalSurfaceSqm,
                'perimeter_meters' => $perimeterMeters,
            ] : null,
            'quantity' => $quantity,
            'base_price' => $basePrice,
            'options' => $optionsDetails,
            'options_total' => $optionsTotal,
            'total_price' => $totalPrice,
            'currency' => 'XOF', // Franc CFA (Afrique de l'Ouest)
        ];
    }
}

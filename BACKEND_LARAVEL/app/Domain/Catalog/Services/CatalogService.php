<?php

namespace App\Domain\Catalog\Services;

use App\Domain\Catalog\Actions\CalculatePrintPriceAction;
use App\Domain\Catalog\Actions\UpdateServicePriceAction;
use App\Domain\Catalog\DTO\PriceCalculationDTO;
use App\Models\PrintService;
use App\Models\ServiceCategory;
use App\Models\User;
use Illuminate\Database\Eloquent\Collection;

class CatalogService
{
    public function __construct(
        protected CalculatePrintPriceAction $calculatePriceAction,
        protected UpdateServicePriceAction $updatePriceAction,
    ) {}

    /**
     * Récupère l'ensemble des catégories actives avec leurs prestations et unités.
     */
    public function getActiveCatalog(): Collection
    {
        return ServiceCategory::with([
            'department',
            'printServices' => function ($query) {
                $query->where('is_active', true)
                    ->with(['unit', 'department', 'options' => function ($optQuery) {
                        $optQuery->where('is_active', true);
                    }]);
            }
        ])
        ->where('is_active', true)
        ->orderBy('display_order')
        ->orderBy('name')
        ->get();
    }

    /**
     * Calcule le prix estimatif pour une demande d'impression.
     */
    public function calculatePrice(PriceCalculationDTO $dto): array
    {
        return $this->calculatePriceAction->execute($dto);
    }

    /**
     * Met à jour le tarif d'une prestation avec traçabilité.
     */
    public function updatePrice(PrintService $service, float $newPrice, ?User $user = null, ?string $reason = null): PrintService
    {
        return $this->updatePriceAction->execute($service, $newPrice, $user, $reason);
    }
}

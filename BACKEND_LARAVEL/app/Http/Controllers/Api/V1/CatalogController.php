<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Catalog\DTO\PriceCalculationDTO;
use App\Domain\Catalog\Services\CatalogService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\CalculatePriceRequest;
use App\Http\Requests\Api\V1\UpdatePriceRequest;
use App\Http\Resources\Api\V1\PrintServiceResource;
use App\Http\Resources\Api\V1\ServiceCategoryResource;
use App\Models\PrintService;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CatalogController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected CatalogService $catalogService,
    ) {}

    /**
     * Liste complète des prestations par catégorie.
     */
    public function index(Request $request): JsonResponse
    {
        $categories = $this->catalogService->getActiveCatalog();

        return $this->successResponse(
            ServiceCategoryResource::collection($categories),
            'Catalogue des prestations récupéré avec succès.'
        );
    }

    /**
     * Détail d'une prestation d'impression spécifique.
     */
    public function show(PrintService $service): JsonResponse
    {
        $service->load(['category', 'department', 'unit', 'options', 'priceHistories.user']);

        return $this->successResponse(
            new PrintServiceResource($service),
            'Détail de la prestation récupéré avec succès.'
        );
    }

    /**
     * Calcule le prix estimatif et les finitions pour un travail d'impression.
     */
    public function calculate(CalculatePriceRequest $request): JsonResponse
    {
        $dto = PriceCalculationDTO::fromArray($request->validated());

        try {
            $calculation = $this->catalogService->calculatePrice($dto);

            return $this->successResponse(
                $calculation,
                'Calcul du prix effectué avec succès.'
            );
        } catch (\InvalidArgumentException $e) {
            return $this->errorResponse($e->getMessage(), 422);
        }
    }

    /**
     * Met à jour le tarif d'une prestation avec traçabilité d'audit.
     */
    public function updatePrice(UpdatePriceRequest $request, PrintService $service): JsonResponse
    {
        $validated = $request->validated();
        $updatedService = $this->catalogService->updatePrice(
            $service,
            (float) $validated['unit_price'],
            $request->user(),
            $validated['reason'] ?? null
        );

        $updatedService->load(['unit', 'category', 'department', 'priceHistories.user']);

        return $this->successResponse(
            new PrintServiceResource($updatedService),
            'Tarif mis à jour avec succès et enregistré dans l\'historique.'
        );
    }
}

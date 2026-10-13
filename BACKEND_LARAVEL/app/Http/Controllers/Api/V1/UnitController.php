<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Resources\Api\V1\UnitResource;
use App\Models\Unit;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;

class UnitController extends Controller
{
    use ApiResponse;

    /**
     * Liste des unités de mesure actives.
     */
    public function index(): JsonResponse
    {
        $units = Unit::where('is_active', true)->orderBy('name')->get();

        return $this->successResponse(
            UnitResource::collection($units),
            'Liste des unités récupérée avec succès.'
        );
    }
}

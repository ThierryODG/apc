<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreFiscalYearRequest;
use App\Models\FiscalYear;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class FiscalYearController extends Controller
{
    public function index(): JsonResponse
    {
        $years = FiscalYear::withCount(['orders', 'payments', 'expenses'])
            ->orderByDesc('start_date')
            ->get();

        return response()->json([
            'success' => true,
            'fiscal_years' => $years,
        ]);
    }

    public function store(StoreFiscalYearRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['created_by'] = $request->user()->id;

        // Si la nouvelle année est marquée comme active, désactiver les autres
        if (! empty($data['is_active'])) {
            FiscalYear::where('is_active', true)->update(['is_active' => false]);
        }

        $year = FiscalYear::create($data);

        return response()->json([
            'success' => true,
            'message' => "L'exercice {$year->name} a été créé avec succès.",
            'fiscal_year' => $year,
        ], 201);
    }

    public function activate(FiscalYear $fiscalYear): JsonResponse
    {
        if ($fiscalYear->status === 'closed') {
            return response()->json([
                'success' => false,
                'message' => "Impossible d'activer un exercice clôturé. Veuillez d'abord le réouvrir.",
            ], 422);
        }

        FiscalYear::where('id', '!=', $fiscalYear->id)->update(['is_active' => false]);
        $fiscalYear->update(['is_active' => true]);

        return response()->json([
            'success' => true,
            'message' => "L'exercice {$fiscalYear->name} ({$fiscalYear->code}) est désormais l'exercice de travail actif.",
            'fiscal_year' => $fiscalYear,
        ]);
    }

    public function close(FiscalYear $fiscalYear): JsonResponse
    {
        $fiscalYear->update([
            'status' => 'closed',
            'is_active' => false,
        ]);

        return response()->json([
            'success' => true,
            'message' => "L'exercice {$fiscalYear->name} a été clôturé avec succès.",
            'fiscal_year' => $fiscalYear,
        ]);
    }
}

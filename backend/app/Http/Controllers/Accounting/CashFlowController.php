<?php

namespace App\Http\Controllers\Accounting;

use App\Http\Controllers\Controller;
use App\Http\Requests\Accounting\StoreCashFlowRequest;
use App\Models\CashFlow;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CashFlowController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $query = CashFlow::where('fiscal_year_id', $fiscalYear->id)
            ->with('user:id,name')
            ->orderByDesc('flow_date');

        if ($type = $request->input('flow_type')) {
            $query->where('flow_type', $type);
        }

        if ($method = $request->input('payment_method')) {
            $query->where('payment_method', $method);
        }

        if ($dateFrom = $request->input('date_from')) {
            $query->whereDate('flow_date', '>=', $dateFrom);
        }

        if ($dateTo = $request->input('date_to')) {
            $query->whereDate('flow_date', '<=', $dateTo);
        }

        $flows = $query->paginate($request->input('per_page', 25));

        return response()->json([
            'success' => true,
            'cash_flows' => $flows,
        ]);
    }

    public function store(StoreCashFlowRequest $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        $data = $request->validated();
        $data['fiscal_year_id'] = $fiscalYear->id;
        $data['user_id'] = $user->id;
        $data['flow_date'] = $data['flow_date'] ?? Carbon::now();

        $flow = CashFlow::create($data);

        return response()->json([
            'success' => true,
            'message' => 'Écriture de trésorerie enregistrée avec succès.',
            'cash_flow' => $flow,
        ], 201);
    }
}

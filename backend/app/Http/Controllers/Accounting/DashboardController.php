<?php

namespace App\Http\Controllers\Accounting;

use App\Http\Controllers\Controller;
use App\Models\CashFlow;
use App\Models\Expense;
use App\Models\FiscalYear;
use App\Models\Order;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Support\Facades\DB;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $activeYear = FiscalYear::active();
        $yearId = $activeYear?->id;

        $cashFlowQuery = CashFlow::query()->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId));
        $expenseQuery = Expense::query()->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId));
        $ordersQuery = Order::query()->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId));

        $totalIn = (float) (clone $cashFlowQuery)->where('flow_type', 'in')->sum('amount');
        $totalOut = (float) (clone $cashFlowQuery)->where('flow_type', 'out')->sum('amount');
        $netCashBalance = $totalIn - $totalOut;

        $totalReceivables = (float) (clone $ordersQuery)->where('status', '!=', 'cancelled')->sum('due_amount');
        $totalExpenses = (float) (clone $expenseQuery)->sum('amount');

        // Répartition des dépenses par catégorie pour graphiques circulaires
        $expensesByCategory = (clone $expenseQuery)
            ->select('category', DB::raw('SUM(amount) as total'))
            ->groupBy('category')
            ->get();

        // Évolution des flux sur les 7 derniers jours (pour graphiques)
        $sevenDaysAgo = Carbon::today()->subDays(6);
        $dailyTrends = (clone $cashFlowQuery)
            ->whereDate('flow_date', '>=', $sevenDaysAgo)
            ->select(
                DB::raw('DATE(flow_date) as date'),
                DB::raw("SUM(CASE WHEN flow_type = 'in' THEN amount ELSE 0 END) as total_in"),
                DB::raw("SUM(CASE WHEN flow_type = 'out' THEN amount ELSE 0 END) as total_out")
            )
            ->groupBy(DB::raw('DATE(flow_date)'))
            ->orderBy('date')
            ->get();

        return response()->json([
            'success' => true,
            'scope' => 'accounting',
            'fiscal_year' => $activeYear?->name,
            'treasury_summary' => [
                'total_cash_in' => $totalIn,
                'total_cash_out' => $totalOut,
                'net_cash_balance' => $netCashBalance,
                'total_receivables' => $totalReceivables,
                'total_expenses' => $totalExpenses,
            ],
            'expenses_by_category' => $expensesByCategory,
            'daily_trends' => $dailyTrends,
        ]);
    }
}


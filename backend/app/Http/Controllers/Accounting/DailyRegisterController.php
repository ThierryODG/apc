<?php

namespace App\Http\Controllers\Accounting;

use App\Http\Controllers\Controller;
use App\Http\Requests\Accounting\CloseRegisterRequest;
use App\Models\CashFlow;
use App\Models\DailyRegister;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class DailyRegisterController extends Controller
{
    public function current(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $today = Carbon::today();

        $register = DailyRegister::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('register_date', $today)
            ->first();

        // Calcul dynamique en temps réel des encaissements espèces du jour
        $cashSales = (float) Payment::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('payment_date', $today)
            ->where('payment_method', 'cash')
            ->sum('amount');

        $otherCashIn = (float) CashFlow::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('flow_date', $today)
            ->where('flow_type', 'in')
            ->where('payment_method', 'cash')
            ->where('category', '!=', 'vente_comptoir')
            ->sum('amount');

        $cashOut = (float) CashFlow::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('flow_date', $today)
            ->where('flow_type', 'out')
            ->where('payment_method', 'cash')
            ->sum('amount');

        $opening = $register ? (float) $register->opening_balance : 0.0;
        $theoreticalBalance = $opening + $cashSales + $otherCashIn - $cashOut;

        return response()->json([
            'success' => true,
            'is_open' => $register ? $register->status === 'open' : false,
            'register' => $register,
            'live_calculation' => [
                'opening_balance' => $opening,
                'cash_sales_today' => $cashSales,
                'other_cash_in' => $otherCashIn,
                'cash_out_today' => $cashOut,
                'theoretical_closing_balance' => $theoreticalBalance,
            ],
        ]);
    }

    public function open(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();
        $today = Carbon::today();

        $existing = DailyRegister::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('register_date', $today)
            ->first();

        if ($existing) {
            return response()->json([
                'success' => false,
                'message' => 'Une session de caisse existe déjà pour aujourd\'hui.',
                'register' => $existing,
            ], 422);
        }

        $request->validate([
            'opening_balance' => ['required', 'numeric', 'min:0'],
        ]);

        $register = DailyRegister::create([
            'fiscal_year_id' => $fiscalYear->id,
            'user_id' => $user->id,
            'register_date' => $today,
            'opened_at' => Carbon::now(),
            'opening_balance' => (float) $request->input('opening_balance', 0),
            'status' => 'open',
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Caisse ouverte avec succès pour la journée.',
            'register' => $register,
        ], 201);
    }

    public function close(CloseRegisterRequest $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $today = Carbon::today();

        $register = DailyRegister::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('register_date', $today)
            ->first();

        if (! $register || $register->status === 'closed') {
            return response()->json([
                'success' => false,
                'message' => 'Aucune session de caisse ouverte à clôturer pour cette date.',
            ], 422);
        }

        $cashSales = (float) Payment::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('payment_date', $today)
            ->where('payment_method', 'cash')
            ->sum('amount');

        $otherCashIn = (float) CashFlow::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('flow_date', $today)
            ->where('flow_type', 'in')
            ->where('payment_method', 'cash')
            ->where('category', '!=', 'vente_comptoir')
            ->sum('amount');

        $cashOut = (float) CashFlow::where('fiscal_year_id', $fiscalYear->id)
            ->whereDate('flow_date', $today)
            ->where('flow_type', 'out')
            ->where('payment_method', 'cash')
            ->sum('amount');

        $expected = (float) $register->opening_balance + $cashSales + $otherCashIn - $cashOut;
        $actual = (float) $request->input('actual_closing_balance');
        $discrepancy = $actual - $expected;

        $register->update([
            'closed_at' => Carbon::now(),
            'cash_sales_total' => $cashSales,
            'cash_in_total' => $otherCashIn,
            'cash_out_total' => $cashOut,
            'expected_closing_balance' => $expected,
            'actual_closing_balance' => $actual,
            'discrepancy' => $discrepancy,
            'status' => 'closed',
            'notes' => $request->input('notes'),
        ]);

        return response()->json([
            'success' => true,
            'message' => 'Clôture de caisse (Z-Report) effectuée avec succès.',
            'z_report' => $register,
        ]);
    }
}


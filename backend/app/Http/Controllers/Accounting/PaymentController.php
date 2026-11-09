<?php

namespace App\Http\Controllers\Accounting;

use App\Http\Controllers\Controller;
use App\Models\Customer;
use App\Models\Order;
use App\Models\Payment;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class PaymentController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $query = Payment::where('fiscal_year_id', $fiscalYear->id)
            ->with(['order.customer:id,name,phone', 'user:id,name'])
            ->orderByDesc('payment_date');

        if ($method = $request->input('payment_method')) {
            $query->where('payment_method', $method);
        }

        $payments = $query->paginate($request->input('per_page', 25));

        return response()->json([
            'success' => true,
            'payments' => $payments,
        ]);
    }

    public function receivables(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $unpaidOrders = Order::where('fiscal_year_id', $fiscalYear->id)
            ->whereIn('payment_status', ['unpaid', 'partial'])
            ->where('status', '!=', 'cancelled')
            ->with('customer:id,code,name,phone,email')
            ->orderByDesc('due_amount')
            ->paginate($request->input('per_page', 25));

        $totalDue = Order::where('fiscal_year_id', $fiscalYear->id)
            ->whereIn('payment_status', ['unpaid', 'partial'])
            ->where('status', '!=', 'cancelled')
            ->sum('due_amount');

        return response()->json([
            'success' => true,
            'total_receivables' => (float) $totalDue,
            'unpaid_orders' => $unpaidOrders,
        ]);
    }
}


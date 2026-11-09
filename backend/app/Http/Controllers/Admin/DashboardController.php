<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Models\CashFlow;
use App\Models\Customer;
use App\Models\Expense;
use App\Models\FiscalYear;
use App\Models\Order;
use App\Models\User;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $activeYear = FiscalYear::active();
        $yearId = $activeYear?->id;

        $ordersQuery = Order::query()->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId));
        $expensesQuery = Expense::query()->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId));

        $totalTurnover = (float) (clone $ordersQuery)->where('status', '!=', 'cancelled')->sum('total_amount');
        $totalCollected = (float) (clone $ordersQuery)->where('status', '!=', 'cancelled')->sum('paid_amount');
        $totalDue = (float) (clone $ordersQuery)->where('status', '!=', 'cancelled')->sum('due_amount');
        $totalExpenses = (float) (clone $expensesQuery)->sum('amount');
        $netResult = $totalCollected - $totalExpenses;

        $totalCustomers = Customer::where('is_active', true)->count();
        $totalOrders = (clone $ordersQuery)->count();
        $ordersPending = (clone $ordersQuery)->whereIn('status', ['confirmed', 'in_production'])->count();

        // Répartition des utilisateurs par profil
        $usersCount = [
            'total' => User::count(),
            'admins' => User::where('role', 'admin')->count(),
            'secretaries' => User::where('role', 'secretary')->count(),
            'accountants' => User::where('role', 'accounting')->count(),
        ];

        return response()->json([
            'success' => true,
            'scope' => 'admin',
            'fiscal_year' => $activeYear ? [
                'id' => $activeYear->id,
                'name' => $activeYear->name,
                'code' => $activeYear->code,
                'start_date' => $activeYear->start_date->format('Y-m-d'),
                'end_date' => $activeYear->end_date->format('Y-m-d'),
            ] : null,
            'metrics' => [
                'total_turnover' => $totalTurnover,
                'total_collected' => $totalCollected,
                'total_due' => $totalDue,
                'total_expenses' => $totalExpenses,
                'net_result' => $netResult,
                'total_customers' => $totalCustomers,
                'total_orders' => $totalOrders,
                'orders_in_progress' => $ordersPending,
            ],
            'users_distribution' => $usersCount,
        ]);
    }
}


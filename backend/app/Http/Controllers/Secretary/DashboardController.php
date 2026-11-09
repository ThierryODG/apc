<?php

namespace App\Http\Controllers\Secretary;

use App\Http\Controllers\Controller;
use App\Models\FiscalYear;
use App\Models\Inquiry;
use App\Models\Order;
use App\Models\Payment;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;

class DashboardController extends Controller
{
    public function index(): JsonResponse
    {
        $activeYear = FiscalYear::active();
        $yearId = $activeYear?->id;
        $today = Carbon::today();

        $todayOrders = Order::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->whereDate('order_date', $today)
            ->where('status', '!=', 'cancelled');

        $todaySalesTotal = (float) (clone $todayOrders)->sum('total_amount');
        $todayTicketsCount = (clone $todayOrders)->count();

        // Total encaissé aujourd'hui au guichet
        $todayCollected = (float) Payment::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->whereDate('payment_date', $today)
            ->sum('amount');

        // Commandes en cours et impayées
        $ordersInProgress = Order::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->whereIn('status', ['confirmed', 'in_production'])
            ->count();

        $unpaidOrdersCount = Order::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->whereIn('payment_status', ['unpaid', 'partial'])
            ->where('status', '!=', 'cancelled')
            ->count();

        // Devis en attente de réponse
        $pendingInquiriesCount = Inquiry::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->where('status', 'pending')
            ->count();

        // Dernières ventes du guichet
        $recentOrders = Order::query()
            ->when($yearId, fn ($q) => $q->where('fiscal_year_id', $yearId))
            ->with(['customer:id,name,phone'])
            ->orderByDesc('id')
            ->limit(8)
            ->get(['id', 'order_number', 'customer_id', 'order_date', 'total_amount', 'paid_amount', 'payment_status', 'status']);

        return response()->json([
            'success' => true,
            'scope' => 'secretary',
            'fiscal_year' => $activeYear?->name,
            'summary' => [
                'today_sales_total' => $todaySalesTotal,
                'today_tickets_count' => $todayTicketsCount,
                'today_collected' => $todayCollected,
                'orders_in_progress' => $ordersInProgress,
                'unpaid_orders_count' => $unpaidOrdersCount,
                'pending_inquiries_count' => $pendingInquiriesCount,
            ],
            'recent_orders' => $recentOrders,
        ]);
    }
}


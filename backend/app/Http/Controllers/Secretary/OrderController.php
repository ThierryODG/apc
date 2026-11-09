<?php

namespace App\Http\Controllers\Secretary;

use App\Http\Controllers\Controller;
use App\Http\Requests\Secretary\StoreOrderRequest;
use App\Http\Requests\Secretary\StorePaymentRequest;
use App\Models\FiscalYear;
use App\Models\Order;
use App\Services\Secretary\PosOrderService;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    public function __construct(
        protected PosOrderService $posService
    ) {}

    public function index(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $query = Order::query()
            ->where('fiscal_year_id', $fiscalYear->id)
            ->with(['customer:id,name,phone,code', 'user:id,name'])
            ->orderByDesc('order_date');

        if ($status = $request->input('status')) {
            $query->where('status', $status);
        }

        if ($paymentStatus = $request->input('payment_status')) {
            $query->where('payment_status', $paymentStatus);
        }

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('order_number', 'like', "%{$search}%")
                  ->orWhereHas('customer', fn ($c) => $c->where('name', 'like', "%{$search}%")->orWhere('phone', 'like', "%{$search}%"));
            });
        }

        $orders = $query->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'orders' => $orders,
        ]);
    }

    public function store(StoreOrderRequest $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        $order = $this->posService->createOrder($request->validated(), $user, $fiscalYear);

        return response()->json([
            'success' => true,
            'message' => "Ticket {$order->order_number} enregistré avec succès.",
            'order' => $order,
        ], 201);
    }

    public function show(Order $order): JsonResponse
    {
        $order->load(['customer', 'user', 'items.product', 'payments']);

        return response()->json([
            'success' => true,
            'order' => $order,
        ]);
    }

    public function addPayment(StorePaymentRequest $request, Order $order): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        $payment = $this->posService->recordPayment($order, $request->validated(), $user, $fiscalYear);

        return response()->json([
            'success' => true,
            'message' => "Règlement de {$payment->amount} FCFA enregistré avec succès sur le ticket {$order->order_number}.",
            'payment' => $payment,
            'order' => $order->fresh(['payments']),
        ]);
    }

    public function updateStatus(Request $request, Order $order): JsonResponse
    {
        $request->validate([
            'status' => ['required', 'string', 'in:draft,confirmed,in_production,ready,delivered,cancelled'],
        ]);

        $order->update(['status' => $request->input('status')]);

        return response()->json([
            'success' => true,
            'message' => "Statut de la commande {$order->order_number} mis à jour : {$order->status}.",
            'order' => $order,
        ]);
    }
}


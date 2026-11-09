<?php

namespace App\Http\Controllers\Secretary;

use App\Http\Controllers\Controller;
use App\Http\Requests\Secretary\StoreCustomerRequest;
use App\Models\Customer;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CustomerController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $query = Customer::query()->where('is_active', true);

        if ($search = $request->input('search')) {
            $query->where(function ($q) use ($search) {
                $q->where('name', 'like', "%{$search}%")
                  ->orWhere('phone', 'like', "%{$search}%")
                  ->orWhere('code', 'like', "%{$search}%")
                  ->orWhere('ifu_number', 'like', "%{$search}%");
            });
        }

        $customers = $query->orderBy('name')->paginate($request->input('per_page', 25));

        return response()->json([
            'success' => true,
            'customers' => $customers,
        ]);
    }

    public function store(StoreCustomerRequest $request): JsonResponse
    {
        $data = $request->validated();

        $count = Customer::count() + 1;
        $data['code'] = sprintf('CLT-%05d', $count);

        $customer = Customer::create($data);

        return response()->json([
            'success' => true,
            'message' => "Client {$customer->name} enregistré avec succès.",
            'customer' => $customer,
        ], 201);
    }

    public function show(Customer $customer): JsonResponse
    {
        $customer->load(['orders' => function ($q) {
            $q->orderByDesc('order_date')->limit(10);
        }]);

        $totalPurchases = (float) $customer->orders()->where('status', '!=', 'cancelled')->sum('total_amount');
        $totalDue = (float) $customer->orders()->where('status', '!=', 'cancelled')->sum('due_amount');

        return response()->json([
            'success' => true,
            'customer' => $customer,
            'stats' => [
                'total_purchases' => $totalPurchases,
                'total_due' => $totalDue,
            ],
        ]);
    }

    public function update(StoreCustomerRequest $request, Customer $customer): JsonResponse
    {
        $customer->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => "Fiche client mise à jour.",
            'customer' => $customer,
        ]);
    }
}

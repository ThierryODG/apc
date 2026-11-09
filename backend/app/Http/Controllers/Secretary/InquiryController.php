<?php

namespace App\Http\Controllers\Secretary;

use App\Http\Controllers\Controller;
use App\Http\Requests\Secretary\StoreInquiryRequest;
use App\Models\FiscalYear;
use App\Models\Inquiry;
use App\Models\Order;
use App\Services\Secretary\PosOrderService;
use Carbon\Carbon;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class InquiryController extends Controller
{
    public function index(Request $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');

        $inquiries = Inquiry::where('fiscal_year_id', $fiscalYear->id)
            ->with(['customer:id,name,phone'])
            ->orderByDesc('id')
            ->paginate($request->input('per_page', 20));

        return response()->json([
            'success' => true,
            'inquiries' => $inquiries,
        ]);
    }

    public function store(StoreInquiryRequest $request): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        $count = Inquiry::where('fiscal_year_id', $fiscalYear->id)->count() + 1;
        $quoteNumber = sprintf('DEV-%s-%05d', str_replace(['/', ' '], '-', $fiscalYear->code), $count);

        $data = $request->validated();
        $data['fiscal_year_id'] = $fiscalYear->id;
        $data['user_id'] = $user->id;
        $data['quote_number'] = $quoteNumber;
        $data['status'] = 'pending';

        $inquiry = Inquiry::create($data);

        return response()->json([
            'success' => true,
            'message' => "Devis {$inquiry->quote_number} créé avec succès.",
            'inquiry' => $inquiry->load('customer'),
        ], 201);
    }

    public function convertToOrder(Request $request, Inquiry $inquiry, PosOrderService $posService): JsonResponse
    {
        $fiscalYear = $request->attributes->get('active_fiscal_year');
        $user = $request->user();

        if ($inquiry->status === 'converted' && $inquiry->converted_order_id) {
            return response()->json([
                'success' => false,
                'message' => "Ce devis a déjà été converti en commande.",
                'order_id' => $inquiry->converted_order_id,
            ], 422);
        }

        $orderData = [
            'customer_id' => $inquiry->customer_id,
            'order_date' => Carbon::now(),
            'notes' => "Issu du devis {$inquiry->quote_number} : {$inquiry->title}",
            'items' => [
                [
                    'designation' => $inquiry->title,
                    'unit' => 'forfait',
                    'quantity' => 1,
                    'unit_price' => (float) $inquiry->estimated_amount,
                    'tax_rate' => 0,
                    'discount_amount' => 0,
                    'notes' => $inquiry->description,
                ],
            ],
        ];

        $order = $posService->createOrder($orderData, $user, $fiscalYear);

        $inquiry->update([
            'status' => 'converted',
            'converted_order_id' => $order->id,
        ]);

        return response()->json([
            'success' => true,
            'message' => "Devis {$inquiry->quote_number} converti avec succès en commande {$order->order_number}.",
            'order' => $order,
        ]);
    }
}

<?php

namespace App\Http\Controllers\Secretary;

use App\Http\Controllers\Controller;
use App\Models\Order;
use App\Services\Secretary\ReceiptPrintService;
use Illuminate\Http\JsonResponse;

class ReceiptController extends Controller
{
    public function __construct(
        protected ReceiptPrintService $receiptService
    ) {}

    public function show(Order $order): JsonResponse
    {
        $receiptData = $this->receiptService->formatReceipt($order);

        return response()->json([
            'success' => true,
            'receipt' => $receiptData,
        ]);
    }
}

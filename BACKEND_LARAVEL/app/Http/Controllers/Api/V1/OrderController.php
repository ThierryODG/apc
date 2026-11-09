<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Orders\Services\OrderService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\ConvertInquiryToOrderRequest;
use App\Http\Resources\Api\V1\OrderResource;
use App\Models\Inquiry;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class OrderController extends Controller
{
    use ApiResponse;

    public function index(Request $request, OrderService $orderService): JsonResponse
    {
        $this->authorize('orders.view');

        return $this->successResponse(
            OrderResource::collection($orderService->listOrders((int) $request->input('per_page', 20)))
                ->response()->getData(true),
            'Liste des commandes récupérée avec succès.'
        );
    }

    public function show(Inquiry $inquiry): JsonResponse
    {
        $this->authorize('orders.view');

        $order = $inquiry->order()->with(['customer', 'workOrders.department'])->firstOrFail();

        return $this->successResponse(
            new OrderResource($order),
            'Commande récupérée avec succès.'
        );
    }

    public function convertInquiry(
        ConvertInquiryToOrderRequest $request,
        Inquiry $inquiry,
        OrderService $orderService,
    ): JsonResponse {
        $order = $orderService->convertInquiry(
            $inquiry,
            (int) $request->validated('department_id'),
            $request->user(),
        );

        return $this->successResponse(
            new OrderResource($order),
            'Commande créée et ordre de travail envoyé à l’atelier.',
            201,
        );
    }
}

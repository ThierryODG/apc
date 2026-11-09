<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Orders\Services\OrderService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\UpdateWorkOrderStatusRequest;
use App\Http\Resources\Api\V1\WorkOrderResource;
use App\Models\WorkOrder;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class WorkOrderController extends Controller
{
    use ApiResponse;

    public function index(Request $request, OrderService $orderService): JsonResponse
    {
        $this->authorize('production.view_queue');

        return $this->successResponse(
            WorkOrderResource::collection(
                $orderService->workOrderQueue($request->user(), (int) $request->input('per_page', 20))
            )->response()->getData(true),
            'File des travaux récupérée avec succès.'
        );
    }

    public function departments(Request $request, OrderService $orderService): JsonResponse
    {
        abort_unless(
            $request->user()->can('orders.create') || $request->user()->can('production.view_queue'),
            Response::HTTP_FORBIDDEN,
        );

        $departments = $orderService->productionDepartments($request->user())
            ->map(fn ($department): array => [
                'id' => $department->id,
                'name' => $department->name,
                'code' => $department->code,
            ]);

        return $this->successResponse($departments, 'Ateliers disponibles récupérés.');
    }

    public function updateStatus(
        UpdateWorkOrderStatusRequest $request,
        WorkOrder $workOrder,
        OrderService $orderService,
    ): JsonResponse {
        $updated = $orderService->updateWorkOrderStatus(
            $workOrder,
            $request->validated('status'),
            $request->user(),
        );

        return $this->successResponse(
            new WorkOrderResource($updated),
            'Avancement du travail mis à jour.'
        );
    }
}

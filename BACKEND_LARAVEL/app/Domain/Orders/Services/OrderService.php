<?php

namespace App\Domain\Orders\Services;

use App\Models\Department;
use App\Models\Inquiry;
use App\Models\Order;
use App\Models\User;
use App\Models\WorkOrder;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Collection;
use Illuminate\Support\Facades\DB;
use Illuminate\Validation\ValidationException;

class OrderService
{
    private const PRODUCTION_DEPARTMENTS = ['PAO', 'NUMERIQUE', 'SERIGRAPHIE', 'FINITION'];

    public function convertInquiry(Inquiry $inquiry, int $departmentId, User $creator): Order
    {
        return DB::transaction(function () use ($inquiry, $departmentId, $creator): Order {
            $lockedInquiry = Inquiry::query()->lockForUpdate()->findOrFail($inquiry->id);

            if ($lockedInquiry->status !== 'quote_sent') {
                throw ValidationException::withMessages([
                    'inquiry' => 'Seule une demande avec devis envoyé peut devenir une commande.',
                ]);
            }

            $department = Department::query()
                ->whereIn('code', self::PRODUCTION_DEPARTMENTS)
                ->where('is_active', true)
                ->findOrFail($departmentId);

            $order = Order::create([
                'inquiry_id' => $lockedInquiry->id,
                'customer_id' => $lockedInquiry->customer_id,
                'created_by' => $creator->id,
                'source' => $lockedInquiry->source,
                'contact_name' => $lockedInquiry->contact_name,
                'contact_phone' => $lockedInquiry->contact_phone,
                'contact_email' => $lockedInquiry->contact_email,
                'subject' => $lockedInquiry->subject,
                'description' => $lockedInquiry->description,
                'quoted_total' => $lockedInquiry->quote_amount,
                'status' => 'received',
                'ordered_at' => now(),
            ]);

            $order->update([
                'order_number' => sprintf('CMD-%s-%06d', now()->format('Y'), $order->id),
            ]);

            WorkOrder::create([
                'order_id' => $order->id,
                'department_id' => $department->id,
                'work_order_number' => sprintf('OT-%06d-01', $order->id),
                'description' => $lockedInquiry->description,
                'status' => 'pending',
            ]);

            $lockedInquiry->update(['status' => 'converted']);

            return $order->load(['customer', 'inquiry', 'workOrders.department']);
        });
    }

    public function listOrders(int $perPage = 20): LengthAwarePaginator
    {
        return Order::query()
            ->with(['customer', 'workOrders.department'])
            ->orderByDesc('id')
            ->paginate(max(1, min($perPage, 100)));
    }

    public function workOrderQueue(User $user, int $perPage = 20): LengthAwarePaginator
    {
        return WorkOrder::query()
            ->with(['order.customer', 'department', 'assignee'])
            ->where('department_id', $user->department_id)
            ->where(function ($query) use ($user): void {
                $query->whereNull('assigned_to')->orWhere('assigned_to', $user->id);
            })
            ->orderByRaw("CASE WHEN status = 'blocked' THEN 0 WHEN status = 'pending' THEN 1 ELSE 2 END")
            ->orderBy('id')
            ->paginate(max(1, min($perPage, 100)));
    }

    /** @return Collection<int, Department> */
    public function productionDepartments(User $user): Collection
    {
        $query = Department::query()
            ->whereIn('code', self::PRODUCTION_DEPARTMENTS)
            ->where('is_active', true)
            ->orderBy('name');

        if (! $user->can('orders.create')) {
            $query->whereKey($user->department_id);
        }

        return $query->get(['id', 'name', 'code']);
    }

    public function updateWorkOrderStatus(WorkOrder $workOrder, string $status, User $user): WorkOrder
    {
        $canManageAll = $user->can('orders.edit');
        $canManageDepartment = $workOrder->department_id === $user->department_id
            && ($workOrder->assigned_to === null || $workOrder->assigned_to === $user->id);

        abort_unless($canManageAll || $canManageDepartment, 403);

        $transitions = [
            'pending' => ['in_progress', 'blocked'],
            'in_progress' => ['blocked', 'completed'],
            'blocked' => ['in_progress', 'completed'],
            'completed' => [],
        ];

        if (! in_array($status, $transitions[$workOrder->status] ?? [], true)) {
            throw ValidationException::withMessages([
                'status' => 'Cette étape ne peut pas être appliquée depuis le statut actuel.',
            ]);
        }

        $workOrder->update([
            'status' => $status,
            'status_updated_by' => $user->id,
            'started_at' => $status === 'in_progress' ? ($workOrder->started_at ?? now()) : $workOrder->started_at,
            'completed_at' => $status === 'completed' ? now() : null,
        ]);

        $order = $workOrder->order;
        $allCompleted = $order->workOrders()->where('status', '!=', 'completed')->doesntExist();
        $hasStarted = $order->workOrders()->whereIn('status', ['in_progress', 'blocked'])->exists();

        $order->update([
            'status' => $allCompleted ? 'ready' : ($hasStarted ? 'in_production' : 'received'),
        ]);

        return $workOrder->refresh()->load(['order.customer', 'department', 'assignee']);
    }
}

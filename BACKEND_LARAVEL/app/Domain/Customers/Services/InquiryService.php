<?php

namespace App\Domain\Customers\Services;

use App\Models\Inquiry;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;

class InquiryService
{
    /**
     * @param  array<string, mixed>  $filters
     */
    public function list(array $filters = [], int $perPage = 20): LengthAwarePaginator
    {
        $query = Inquiry::query()->with('customer');

        foreach (['status', 'source', 'customer_id'] as $filter) {
            if (isset($filters[$filter]) && $filters[$filter] !== '') {
                $query->where($filter, $filters[$filter]);
            }
        }

        if (! empty($filters['search'])) {
            $search = trim((string) $filters['search']);
            $query->where(function ($query) use ($search): void {
                $query->where('subject', 'like', "%{$search}%")
                    ->orWhere('contact_name', 'like', "%{$search}%")
                    ->orWhere('contact_phone', 'like', "%{$search}%");
            });
        }

        return $query->latest()->paginate(max(1, min($perPage, 100)));
    }

    /** @param array<string, mixed> $data */
    public function create(array $data, User $creator): Inquiry
    {
        $data['created_by'] = $creator->id;
        $data['status'] = 'new';

        return Inquiry::create($data);
    }

    /** @param array<string, mixed> $data */
    public function update(Inquiry $inquiry, array $data): Inquiry|false
    {
        if (! in_array($inquiry->status, ['new', 'qualified'], true)) {
            return false;
        }

        $inquiry->update($data);

        return $inquiry->refresh();
    }

    public function qualify(Inquiry $inquiry, User $user): Inquiry|false
    {
        if ($inquiry->status !== 'new') {
            return false;
        }

        $inquiry->update([
            'status' => 'qualified',
            'qualified_at' => now(),
            'qualified_by' => $user->id,
        ]);

        return $inquiry->refresh();
    }

    public function sendQuote(Inquiry $inquiry, float $amount, User $user): Inquiry|false
    {
        if ($inquiry->status !== 'qualified') {
            return false;
        }

        $inquiry->update([
            'status' => 'quote_sent',
            'quote_amount' => $amount,
            'quote_sent_at' => now(),
            'quote_sent_by' => $user->id,
        ]);

        return $inquiry->refresh();
    }

    public function refuse(Inquiry $inquiry, string $reason, User $user): Inquiry|false
    {
        if (! in_array($inquiry->status, ['new', 'qualified', 'quote_sent'], true)) {
            return false;
        }

        $inquiry->update([
            'status' => 'refused',
            'refusal_reason' => $reason,
            'refused_at' => now(),
            'refused_by' => $user->id,
        ]);

        return $inquiry->refresh();
    }
}

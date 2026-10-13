<?php

namespace App\Domain\Customers\Services;

use App\Models\Customer;
use App\Models\User;
use Illuminate\Contracts\Pagination\LengthAwarePaginator;
use Illuminate\Support\Carbon;
use Illuminate\Support\Facades\DB;

class CustomerService
{
    /**
     * Liste paginée avec filtres et recherche.
     */
    public function list(array $filters = [], int $perPage = 20): LengthAwarePaginator
    {
        $query = Customer::with(['contacts' => fn($q) => $q->where('is_primary', true)])
                         ->withCount('contacts');

        // Filtre par type
        if (! empty($filters['type'])) {
            $query->where('type', $filters['type']);
        }

        // Filtre par segment
        if (! empty($filters['segment'])) {
            $query->where('segment', $filters['segment']);
        }

        // Filtre actif/inactif
        if (isset($filters['is_active'])) {
            $query->where('is_active', (bool) $filters['is_active']);
        } else {
            $query->active();
        }

        // Recherche plein texte
        if (! empty($filters['search'])) {
            $query->search($filters['search']);
        }

        // Tri
        $sortBy  = in_array($filters['sort_by'] ?? '', ['name', 'created_at', 'segment']) ? $filters['sort_by'] : 'name';
        $sortDir = ($filters['sort_dir'] ?? 'asc') === 'desc' ? 'desc' : 'asc';

        return $query->orderBy($sortBy, $sortDir)->paginate($perPage);
    }

    /**
     * Crée un nouveau client.
     */
    public function create(array $data, User $actor): Customer
    {
        return DB::transaction(function () use ($data, $actor) {
            $customer = Customer::create([
                ...$data,
                'created_by' => $actor->id,
            ]);

            // Adresse par défaut si fournie
            if (! empty($data['address'])) {
                $customer->addresses()->create([
                    ...$data['address'],
                    'is_default' => true,
                    'type'       => 'both',
                ]);
            }

            // Contact principal si fourni
            if (! empty($data['contact'])) {
                $customer->contacts()->create([
                    ...$data['contact'],
                    'is_primary' => true,
                ]);
            }

            return $customer->fresh(['contacts', 'addresses']);
        });
    }

    /**
     * Met à jour un client existant.
     */
    public function update(Customer $customer, array $data): Customer
    {
        $customer->update($data);

        return $customer->fresh(['contacts', 'addresses']);
    }

    /**
     * Active ou désactive un client.
     */
    public function toggleStatus(Customer $customer): Customer
    {
        $customer->update(['is_active' => ! $customer->is_active]);

        return $customer;
    }

    /**
     * Suppression douce (soft delete).
     */
    public function delete(Customer $customer): void
    {
        $customer->delete();
    }

    /**
     * Ajoute un contact à un client.
     */
    public function addContact(Customer $customer, array $data): void
    {
        DB::transaction(function () use ($customer, $data) {
            // S'il est marqué comme principal, déclasse les autres
            if (! empty($data['is_primary'])) {
                $customer->contacts()->update(['is_primary' => false]);
            }

            $customer->contacts()->create($data);
        });
    }

    /**
     * Ajoute une adresse à un client.
     */
    public function addAddress(Customer $customer, array $data): void
    {
        DB::transaction(function () use ($customer, $data) {
            // Si marquée par défaut, déclasse les autres du même type
            if (! empty($data['is_default'])) {
                $typeFilter = $data['type'] === 'both'
                    ? ['delivery', 'billing', 'both']
                    : [$data['type'], 'both'];

                $customer->addresses()
                         ->whereIn('type', $typeFilter)
                         ->update(['is_default' => false]);
            }

            $customer->addresses()->create($data);
        });
    }

    /**
     * Statistiques rapides pour le tableau de bord.
     */
    public function stats(): array
    {
        return [
            'total'      => Customer::count(),
            'active'     => Customer::active()->count(),
            'companies'  => Customer::companies()->count(),
            'individuals' => Customer::individuals()->count(),
            'vip'        => Customer::vip()->count(),
            'new_this_month' => Customer::whereMonth('created_at', Carbon::now()->format('n'))
                                        ->whereYear('created_at', Carbon::now()->format('Y'))
                                        ->count(),
        ];
    }
}

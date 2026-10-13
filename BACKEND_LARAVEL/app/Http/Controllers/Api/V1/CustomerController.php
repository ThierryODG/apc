<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Customers\Services\CustomerService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\StoreCustomerRequest;
use App\Http\Requests\Api\V1\UpdateCustomerRequest;
use App\Http\Resources\Api\V1\CustomerResource;
use App\Models\Customer;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;


class CustomerController extends Controller
{
    use ApiResponse;

    public function __construct(
        protected CustomerService $customerService,
    ) {}

    /**
     * Liste paginée des clients avec filtres.
     * GET /api/v1/customers
     */
    public function index(Request $request): JsonResponse
    {
        $this->authorize('customers.view');

        $customers = $this->customerService->list(
            filters: $request->only(['type', 'segment', 'is_active', 'search', 'sort_by', 'sort_dir']),
            perPage: (int) $request->get('per_page', 20),
        );

        return $this->successResponse(
            CustomerResource::collection($customers)->response()->getData(true),
            'Liste des clients récupérée avec succès.'
        );
    }

    /**
     * Détail d'un client.
     * GET /api/v1/customers/{customer}
     */
    public function show(Customer $customer): JsonResponse
    {
        $this->authorize('customers.view');

        $customer->load(['contacts', 'addresses', 'createdBy']);

        return $this->successResponse(
            new CustomerResource($customer),
            'Fiche client récupérée avec succès.'
        );
    }

    /**
     * Création d'un nouveau client.
     * POST /api/v1/customers
     */
    public function store(StoreCustomerRequest $request): JsonResponse
    {
        $customer = $this->customerService->create(
            $request->validated(),
            $request->user()
        );

        $customer->load(['contacts', 'addresses']);

        return $this->successResponse(
            new CustomerResource($customer),
            'Client créé avec succès.',
            Response::HTTP_CREATED
        );
    }

    /**
     * Mise à jour d'un client.
     * PATCH /api/v1/customers/{customer}
     */
    public function update(UpdateCustomerRequest $request, Customer $customer): JsonResponse
    {
        $updated = $this->customerService->update($customer, $request->validated());

        return $this->successResponse(
            new CustomerResource($updated),
            'Fiche client mise à jour avec succès.'
        );
    }

    /**
     * Suppression logique d'un client.
     * DELETE /api/v1/customers/{customer}
     */
    public function destroy(Request $request, Customer $customer): JsonResponse
    {
        $this->authorize('customers.delete');

        $this->customerService->delete($customer);

        return $this->successResponse(null, 'Client archivé avec succès.');
    }

    /**
     * Activation / Désactivation d'un compte client.
     * PATCH /api/v1/customers/{customer}/toggle-status
     */
    public function toggleStatus(Request $request, Customer $customer): JsonResponse
    {
        $this->authorize('customers.edit');

        $updated = $this->customerService->toggleStatus($customer);

        $status = $updated->is_active ? 'activé' : 'désactivé';

        return $this->successResponse(
            new CustomerResource($updated),
            "Client {$status} avec succès."
        );
    }

    /**
     * Statistiques clients pour le tableau de bord.
     * GET /api/v1/customers/stats
     */
    public function stats(Request $request): JsonResponse
    {
        $this->authorize('customers.view');

        return $this->successResponse(
            $this->customerService->stats(),
            'Statistiques clients récupérées.'
        );
    }

    /**
     * Ajoute un contact à un client.
     * POST /api/v1/customers/{customer}/contacts
     */
    public function addContact(Request $request, Customer $customer): JsonResponse
    {
        $this->authorize('customers.edit');

        $data = $request->validate([
            'first_name'        => 'required|string|max:80',
            'last_name'         => 'nullable|string|max:80',
            'position'          => 'nullable|string|max:100',
            'email'             => 'nullable|email|max:150',
            'phone'             => 'nullable|string|max:30',
            'phone_2'           => 'nullable|string|max:30',
            'is_primary'        => 'nullable|boolean',
            'receives_invoices' => 'nullable|boolean',
            'receives_quotes'   => 'nullable|boolean',
            'notes'             => 'nullable|string|max:500',
        ]);

        $this->customerService->addContact($customer, $data);

        $customer->load('contacts');

        return $this->successResponse(
            new CustomerResource($customer),
            'Contact ajouté avec succès.',
            Response::HTTP_CREATED
        );
    }

    /**
     * Ajoute une adresse à un client.
     * POST /api/v1/customers/{customer}/addresses
     */
    public function addAddress(Request $request, Customer $customer): JsonResponse
    {
        $this->authorize('customers.edit');

        $data = $request->validate([
            'type'           => 'required|in:delivery,billing,both',
            'label'          => 'nullable|string|max:80',
            'address_line_1' => 'required|string|max:200',
            'address_line_2' => 'nullable|string|max:200',
            'district'       => 'nullable|string|max:100',
            'city'           => 'nullable|string|max:100',
            'region'         => 'nullable|string|max:100',
            'is_default'     => 'nullable|boolean',
            'delivery_notes' => 'nullable|string|max:500',
            'latitude'       => 'nullable|numeric|between:-90,90',
            'longitude'      => 'nullable|numeric|between:-180,180',
        ]);

        $this->customerService->addAddress($customer, $data);

        $customer->load('addresses');

        return $this->successResponse(
            new CustomerResource($customer),
            'Adresse ajoutée avec succès.',
            Response::HTTP_CREATED
        );
    }
}

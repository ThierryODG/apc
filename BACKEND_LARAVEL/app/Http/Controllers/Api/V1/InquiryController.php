<?php

namespace App\Http\Controllers\Api\V1;

use App\Domain\Customers\Services\InquiryService;
use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\RefuseInquiryRequest;
use App\Http\Requests\Api\V1\SendInquiryQuoteRequest;
use App\Http\Requests\Api\V1\StoreInquiryRequest;
use App\Http\Requests\Api\V1\UpdateInquiryRequest;
use App\Http\Resources\Api\V1\InquiryResource;
use App\Models\Inquiry;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class InquiryController extends Controller
{
    use ApiResponse;

    public function __construct(private readonly InquiryService $inquiryService) {}

    public function index(Request $request): JsonResponse
    {
        $this->authorize('inquiries.view');

        $inquiries = $this->inquiryService->list(
            $request->only(['status', 'source', 'customer_id', 'search']),
            (int) $request->input('per_page', 20),
        );

        return $this->successResponse(
            InquiryResource::collection($inquiries)->response()->getData(true),
            'Liste des demandes récupérée avec succès.'
        );
    }

    public function store(StoreInquiryRequest $request): JsonResponse
    {
        $inquiry = $this->inquiryService->create($request->validated(), $request->user());

        return $this->successResponse(
            new InquiryResource($inquiry->load('customer')),
            'Demande enregistrée avec succès.',
            Response::HTTP_CREATED
        );
    }

    public function show(Inquiry $inquiry): JsonResponse
    {
        $this->authorize('inquiries.view');
        $inquiry->load(['customer', 'creator', 'files']);

        return $this->successResponse(
            new InquiryResource($inquiry),
            'Détail de la demande récupéré avec succès.'
        );
    }

    public function update(UpdateInquiryRequest $request, Inquiry $inquiry): JsonResponse
    {
        $updated = $this->inquiryService->update($inquiry, $request->validated());

        if ($updated === false) {
            return $this->errorResponse(
                'Une demande ne peut être modifiée qu’avant l’envoi du devis.',
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        return $this->successResponse(
            new InquiryResource($updated->load('customer')),
            'Demande mise à jour avec succès.'
        );
    }

    public function qualify(Request $request, Inquiry $inquiry): JsonResponse
    {
        $this->authorize('inquiries.edit');
        $updated = $this->inquiryService->qualify($inquiry, $request->user());

        if ($updated === false) {
            return $this->errorResponse(
                'Seule une demande nouvelle peut être qualifiée.',
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        return $this->successResponse(new InquiryResource($updated), 'Demande qualifiée avec succès.');
    }

    public function sendQuote(SendInquiryQuoteRequest $request, Inquiry $inquiry): JsonResponse
    {
        $updated = $this->inquiryService->sendQuote(
            $inquiry,
            (float) $request->validated('quote_amount'),
            $request->user(),
        );

        if ($updated === false) {
            return $this->errorResponse(
                'La demande doit être qualifiée avant l’envoi du devis.',
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        return $this->successResponse(new InquiryResource($updated), 'Devis marqué comme envoyé.');
    }

    public function refuse(RefuseInquiryRequest $request, Inquiry $inquiry): JsonResponse
    {
        $updated = $this->inquiryService->refuse(
            $inquiry,
            $request->validated('reason'),
            $request->user(),
        );

        if ($updated === false) {
            return $this->errorResponse(
                'Cette demande ne peut plus être refusée.',
                Response::HTTP_UNPROCESSABLE_ENTITY
            );
        }

        return $this->successResponse(new InquiryResource($updated), 'Demande refusée.');
    }
}

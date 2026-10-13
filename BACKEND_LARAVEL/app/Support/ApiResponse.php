<?php

namespace App\Support;

use Illuminate\Http\JsonResponse;
use Symfony\Component\HttpFoundation\Response;

trait ApiResponse
{
    /**
     * Retourne une réponse API de succès standardisée.
     */
    protected function successResponse(
        mixed $data = null,
        string $message = 'Opération effectuée avec succès.',
        int $statusCode = Response::HTTP_OK,
        array $meta = []
    ): JsonResponse {
        $payload = [
            'success' => true,
            'message' => $message,
            'data' => $data,
        ];

        if (!empty($meta)) {
            $payload['meta'] = $meta;
        }

        return response()->json($payload, $statusCode);
    }

    /**
     * Retourne une réponse API d'erreur standardisée.
     */
    protected function errorResponse(
        string $message = 'Une erreur est survenue.',
        int $statusCode = Response::HTTP_BAD_REQUEST,
        mixed $errors = null
    ): JsonResponse {
        $payload = [
            'success' => false,
            'message' => $message,
        ];

        if (!is_null($errors)) {
            $payload['errors'] = $errors;
        }

        return response()->json($payload, $statusCode);
    }
}

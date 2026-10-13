<?php

namespace App\Http\Controllers\Api\V1;

use App\Http\Controllers\Controller;
use App\Http\Requests\Api\V1\LoginRequest;
use App\Models\User;
use App\Support\ApiResponse;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Symfony\Component\HttpFoundation\Response;

class AuthController extends Controller
{
    use ApiResponse;

    /**
     * Authentifie un utilisateur et délivre un jeton Sanctum.
     */
    public function login(LoginRequest $request): JsonResponse
    {
        $credentials = $request->validated();
        $user = User::with('department')->where('email', $credentials['email'])->first();

        if (!$user || !Hash::check($credentials['password'], $user->password)) {
            return $this->errorResponse(
                'Identifiants incorrects. Veuillez vérifier votre email et mot de passe.',
                Response::HTTP_UNAUTHORIZED
            );
        }

        if (!$user->is_active) {
            return $this->errorResponse(
                'Ce compte utilisateur est désactivé. Veuillez contacter l\'administrateur.',
                Response::HTTP_FORBIDDEN
            );
        }

        $deviceName = $credentials['device_name'] ?? 'apc-client';
        $token = $user->createToken($deviceName)->plainTextToken;

        return $this->successResponse([
            'token' => $token,
            'token_type' => 'Bearer',
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'department' => $user->department ? [
                    'id' => $user->department->id,
                    'name' => $user->department->name,
                    'code' => $user->department->code,
                ] : null,
                'roles' => $user->getRoleNames(),
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
        ], 'Connexion réussie.');
    }

    /**
     * Retourne les informations de l'utilisateur actuellement authentifié.
     */
    public function me(Request $request): JsonResponse
    {
        /** @var User $user */
        $user = $request->user()->load('department');

        return $this->successResponse([
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'phone' => $user->phone,
                'department' => $user->department ? [
                    'id' => $user->department->id,
                    'name' => $user->department->name,
                    'code' => $user->department->code,
                ] : null,
                'roles' => $user->getRoleNames(),
                'permissions' => $user->getAllPermissions()->pluck('name'),
            ],
        ], 'Profil utilisateur récupéré avec succès.');
    }

    /**
     * Déconnecte l'utilisateur et révoque le jeton courant.
     */
    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return $this->successResponse(null, 'Déconnexion réussie. Jeton révoqué.');
    }
}

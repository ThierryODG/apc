<?php

namespace App\Http\Controllers\Auth;

use App\Http\Controllers\Controller;
use App\Http\Requests\Auth\LoginRequest;
use App\Models\Company;
use App\Models\FiscalYear;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use Illuminate\Validation\ValidationException;

class LoginController extends Controller
{
    public function login(LoginRequest $request): JsonResponse
    {
        $user = User::where('email', $request->email)->first();

        if (! $user || ! Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Identifiants incorrects. Veuillez vérifier votre adresse e-mail et votre mot de passe.'],
            ]);
        }

        if (! $user->is_active) {
            return response()->json([
                'success' => false,
                'message' => 'Ce compte utilisateur a été désactivé par l\'administrateur.',
            ], 403);
        }

        $token = $user->createToken('apc_auth_token')->plainTextToken;
        $activeFiscalYear = FiscalYear::active();
        $company = Company::current();

        return response()->json([
            'success' => true,
            'message' => 'Connexion réussie.',
            'token' => $token,
            'user' => [
                'id' => $user->id,
                'name' => $user->name,
                'email' => $user->email,
                'role' => $user->role,
                'phone' => $user->phone,
            ],
            'active_fiscal_year' => $activeFiscalYear ? [
                'id' => $activeFiscalYear->id,
                'name' => $activeFiscalYear->name,
                'code' => $activeFiscalYear->code,
                'status' => $activeFiscalYear->status,
            ] : null,
            'company' => [
                'name' => $company->name,
                'ifu_number' => $company->ifu_number,
                'currency' => $company->currency,
            ],
        ]);
    }

    public function logout(Request $request): JsonResponse
    {
        $request->user()->currentAccessToken()->delete();

        return response()->json([
            'success' => true,
            'message' => 'Déconnexion effectuée avec succès.',
        ]);
    }
}

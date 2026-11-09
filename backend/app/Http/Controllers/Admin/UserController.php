<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\StoreUserRequest;
use App\Models\User;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;

class UserController extends Controller
{
    public function index(): JsonResponse
    {
        $users = User::select('id', 'name', 'email', 'role', 'phone', 'is_active', 'created_at')
            ->orderBy('role')
            ->orderBy('name')
            ->get();

        return response()->json([
            'success' => true,
            'users' => $users,
        ]);
    }

    public function store(StoreUserRequest $request): JsonResponse
    {
        $data = $request->validated();
        $data['password'] = Hash::make($data['password']);

        $user = User::create($data);

        return response()->json([
            'success' => true,
            'message' => "L'utilisateur {$user->name} ({$user->role}) a été créé avec succès.",
            'user' => $user->only(['id', 'name', 'email', 'role', 'phone', 'is_active']),
        ], 201);
    }

    public function toggleActive(User $user): JsonResponse
    {
        $user->update(['is_active' => ! $user->is_active]);

        return response()->json([
            'success' => true,
            'message' => "Statut de l'utilisateur {$user->name} mis à jour.",
            'is_active' => $user->is_active,
        ]);
    }
}

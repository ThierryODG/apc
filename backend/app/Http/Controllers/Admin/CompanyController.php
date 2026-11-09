<?php

namespace App\Http\Controllers\Admin;

use App\Http\Controllers\Controller;
use App\Http\Requests\Admin\UpdateCompanyRequest;
use App\Models\Company;
use Illuminate\Http\JsonResponse;
use Illuminate\Http\Request;

class CompanyController extends Controller
{
    public function show(): JsonResponse
    {
        $company = Company::current();

        return response()->json([
            'success' => true,
            'company' => $company,
        ]);
    }

    public function update(UpdateCompanyRequest $request): JsonResponse
    {
        $company = Company::current();
        $company->update($request->validated());

        return response()->json([
            'success' => true,
            'message' => 'Informations de l\'entreprise mises à jour avec succès.',
            'company' => $company,
        ]);
    }

    public function uploadLogo(Request $request): JsonResponse
    {
        $request->validate([
            'logo' => ['required', 'image', 'mimes:jpeg,png,jpg,webp,svg', 'max:2048'],
        ]);

        $company = Company::current();
        $path = $request->file('logo')->store('company', 'public');
        $company->update(['logo_path' => '/storage/' . $path]);

        return response()->json([
            'success' => true,
            'message' => 'Logo de l\'entreprise mis à jour avec succès.',
            'logo_url' => $company->logo_path,
            'company' => $company,
        ]);
    }
}


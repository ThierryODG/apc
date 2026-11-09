<?php

namespace App\Http\Middleware;

use App\Models\FiscalYear;
use Closure;
use Illuminate\Http\Request;
use Symfony\Component\HttpFoundation\Response;

class EnsureActiveFiscalYear
{
    /**
     * Handle an incoming request.
     *
     * @param  \Closure(\Illuminate\Http\Request): (\Symfony\Component\HttpFoundation\Response)  $next
     */
    public function handle(Request $request, Closure $next): Response
    {
        $activeYear = FiscalYear::where('is_active', true)
            ->where('status', 'open')
            ->first();

        if (! $activeYear) {
            return response()->json([
                'success' => false,
                'message' => "Aucun exercice d'activité (année de travail) n'est actuellement actif ou ouvert. Veuillez contacter l'administrateur pour ouvrir l'exercice en cours (ex: 2025-2026).",
                'code' => 'NO_ACTIVE_FISCAL_YEAR',
            ], 428); // 428 Precondition Required
        }

        // On injecte l'exercice actif dans la requête pour simplifier l'accès dans les contrôleurs
        $request->merge(['active_fiscal_year_id' => $activeYear->id]);
        $request->attributes->set('active_fiscal_year', $activeYear);

        return $next($request);
    }
}

<?php

use App\Http\Controllers\Accounting\CashFlowController;
use App\Http\Controllers\Accounting\DailyRegisterController;
use App\Http\Controllers\Accounting\DashboardController;
use App\Http\Controllers\Accounting\ExpenseController;
use App\Http\Controllers\Accounting\PaymentController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Routes réservées à la Comptabilité & Trésorerie
| Préfixe automatique : /api/accounting
|--------------------------------------------------------------------------
*/

Route::middleware(['auth:sanctum', 'role:accounting,admin', 'fiscal.active'])->group(function () {
    // Dashboard Comptabilité (Entrées, sorties, solde théorique, créances, graphes)
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Journal des flux de caisse / Trésorerie (Entrées & Sorties d'argent)
    Route::get('/cash-flows', [CashFlowController::class, 'index']);
    Route::post('/cash-flows', [CashFlowController::class, 'store']);

    // Dépenses d'exploitation de l'imprimerie (achats papier, encres, maintenance, charges)
    Route::get('/expenses', [ExpenseController::class, 'index']);
    Route::post('/expenses', [ExpenseController::class, 'store']);

    // Suivi des encaissements & Créances clients restant à recouvrer
    Route::get('/payments', [PaymentController::class, 'index']);
    Route::get('/receivables', [PaymentController::class, 'receivables']);

    // Session journalière de caisse & Z-Report de clôture (style Aronium)
    Route::get('/daily-register/current', [DailyRegisterController::class, 'current']);
    Route::post('/daily-register/open', [DailyRegisterController::class, 'open']);
    Route::post('/daily-register/close', [DailyRegisterController::class, 'close']);
});

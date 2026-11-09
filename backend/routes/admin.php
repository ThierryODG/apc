<?php

use App\Http\Controllers\Admin\CompanyController;
use App\Http\Controllers\Admin\DashboardController;
use App\Http\Controllers\Admin\FiscalYearController;
use App\Http\Controllers\Admin\ProductCatalogController;
use App\Http\Controllers\Admin\UserController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Routes réservées à l'Administrateur
| Préfixe automatique : /api/admin
|--------------------------------------------------------------------------
*/

Route::middleware(['auth:sanctum', 'role:admin'])->group(function () {
    // Dashboard Direction / Administration
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Paramètres de l'entreprise (Nom, IFU, RCCM, Contacts, Logo, Pied de page reçu)
    Route::get('/company', [CompanyController::class, 'show']);
    Route::put('/company', [CompanyController::class, 'update']);
    Route::post('/company/logo', [CompanyController::class, 'uploadLogo']);

    // Gestion des Exercices / Années d'activité (ex: 2025-2026)
    Route::get('/fiscal-years', [FiscalYearController::class, 'index']);
    Route::post('/fiscal-years', [FiscalYearController::class, 'store']);
    Route::post('/fiscal-years/{fiscalYear}/activate', [FiscalYearController::class, 'activate']);
    Route::post('/fiscal-years/{fiscalYear}/close', [FiscalYearController::class, 'close']);

    // Gestion des Utilisateurs & Profils (Secrétaire, Comptabilité, Admin)
    Route::get('/users', [UserController::class, 'index']);
    Route::post('/users', [UserController::class, 'store']);
    Route::patch('/users/{user}/toggle-active', [UserController::class, 'toggleActive']);

    // Gestion du catalogue produits & prestations
    Route::get('/catalog', [ProductCatalogController::class, 'index']);
    Route::post('/catalog/categories', [ProductCatalogController::class, 'storeCategory']);
    Route::put('/catalog/categories/{category}', [ProductCatalogController::class, 'updateCategory']);
    Route::delete('/catalog/categories/{category}', [ProductCatalogController::class, 'destroyCategory']);
    Route::post('/catalog/products', [ProductCatalogController::class, 'storeProduct']);
    Route::put('/catalog/products/{product}', [ProductCatalogController::class, 'updateProduct']);
    Route::delete('/catalog/products/{product}', [ProductCatalogController::class, 'destroyProduct']);
});


<?php

use App\Http\Controllers\Api\V1\AuthController;
use App\Http\Controllers\Api\V1\CatalogController;
use App\Http\Controllers\Api\V1\CustomerController;
use App\Http\Controllers\Api\V1\InquiryController;
use App\Http\Controllers\Api\V1\UnitController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes - Version 1 (Africa Print Communication)
|--------------------------------------------------------------------------
*/

Route::prefix('v1')->group(function () {

    // Authentification publique
    Route::prefix('auth')->group(function () {
        Route::post('/login', [AuthController::class, 'login'])->middleware('throttle:10,1');

        // Authentification protégée
        Route::middleware('auth:sanctum')->group(function () {
            Route::get('/me', [AuthController::class, 'me']);
            Route::post('/logout', [AuthController::class, 'logout']);
        });
    });

    // Catalogue des prestations & Tarifs
    Route::prefix('catalog')->group(function () {
        Route::get('/', [CatalogController::class, 'index']);
        Route::get('/units', [UnitController::class, 'index']);
        Route::get('/services/{service}', [CatalogController::class, 'show']);
        Route::post('/calculate-price', [CatalogController::class, 'calculate']);

        // Modification de tarif (protégée par Sanctum + permission catalog.edit)
        Route::middleware('auth:sanctum')->group(function () {
            Route::patch('/services/{service}/price', [CatalogController::class, 'updatePrice']);
        });
    });

    // ─── Module 3 : Clients & Contacts ────────────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {

        // Module 4 : demandes entrantes et devis
        Route::get('/inquiries', [InquiryController::class, 'index']);
        Route::post('/inquiries', [InquiryController::class, 'store']);
        Route::get('/inquiries/{inquiry}', [InquiryController::class, 'show']);
        Route::patch('/inquiries/{inquiry}', [InquiryController::class, 'update']);
        Route::patch('/inquiries/{inquiry}/qualify', [InquiryController::class, 'qualify']);
        Route::patch('/inquiries/{inquiry}/quote', [InquiryController::class, 'sendQuote']);
        Route::patch('/inquiries/{inquiry}/refuse', [InquiryController::class, 'refuse']);

        // Statistiques (avant le group apiResource pour éviter le conflit avec {customer})
        Route::get('/customers/stats', [CustomerController::class, 'stats']);

        // CRUD clients
        Route::apiResource('customers', CustomerController::class);

        // Actions spéciales sur un client
        Route::patch('/customers/{customer}/toggle-status', [CustomerController::class, 'toggleStatus']);

        // Contacts et adresses d'un client
        Route::post('/customers/{customer}/contacts', [CustomerController::class, 'addContact']);
        Route::post('/customers/{customer}/addresses', [CustomerController::class, 'addAddress']);
    });

});

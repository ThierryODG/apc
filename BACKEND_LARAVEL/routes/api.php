<?php

use App\Http\Controllers\Api\V1\AuthController;
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
        Route::get('/', [\App\Http\Controllers\Api\V1\CatalogController::class, 'index']);
        Route::get('/units', [\App\Http\Controllers\Api\V1\UnitController::class, 'index']);
        Route::get('/services/{service}', [\App\Http\Controllers\Api\V1\CatalogController::class, 'show']);
        Route::post('/calculate-price', [\App\Http\Controllers\Api\V1\CatalogController::class, 'calculate']);

        // Modification de tarif (protégée par Sanctum + permission catalog.edit)
        Route::middleware('auth:sanctum')->group(function () {
            Route::patch('/services/{service}/price', [\App\Http\Controllers\Api\V1\CatalogController::class, 'updatePrice']);
        });
    });

    // ─── Module 3 : Clients & Contacts ────────────────────────────────────────
    Route::middleware('auth:sanctum')->group(function () {

        // Statistiques (avant le group apiResource pour éviter le conflit avec {customer})
        Route::get('/customers/stats', [\App\Http\Controllers\Api\V1\CustomerController::class, 'stats']);

        // CRUD clients
        Route::apiResource('customers', \App\Http\Controllers\Api\V1\CustomerController::class);

        // Actions spéciales sur un client
        Route::patch('/customers/{customer}/toggle-status', [\App\Http\Controllers\Api\V1\CustomerController::class, 'toggleStatus']);

        // Contacts et adresses d'un client
        Route::post('/customers/{customer}/contacts', [\App\Http\Controllers\Api\V1\CustomerController::class, 'addContact']);
        Route::post('/customers/{customer}/addresses', [\App\Http\Controllers\Api\V1\CustomerController::class, 'addAddress']);
    });

});

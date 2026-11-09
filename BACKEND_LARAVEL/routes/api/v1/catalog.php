<?php

use App\Http\Controllers\Api\V1\CatalogController;
use App\Http\Controllers\Api\V1\UnitController;
use Illuminate\Support\Facades\Route;

Route::prefix('catalog')->group(function (): void {
    Route::get('/', [CatalogController::class, 'index']);
    Route::get('/units', [UnitController::class, 'index']);
    Route::get('/services/{service}', [CatalogController::class, 'show']);
    Route::post('/calculate-price', [CatalogController::class, 'calculate']);
    Route::patch('/services/{service}/price', [CatalogController::class, 'updatePrice'])
        ->middleware('auth:sanctum');
});

<?php

use Illuminate\Support\Facades\Route;

Route::prefix('v1')->group(function (): void {
    require __DIR__.'/api/v1/auth.php';
    require __DIR__.'/api/v1/catalog.php';

    Route::middleware('auth:sanctum')->group(function (): void {
        require __DIR__.'/api/v1/customers.php';
        require __DIR__.'/api/v1/inquiries.php';
        require __DIR__.'/api/v1/orders.php';
        require __DIR__.'/api/v1/production.php';
    });
});

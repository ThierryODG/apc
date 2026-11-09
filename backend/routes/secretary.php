<?php

use App\Http\Controllers\Secretary\CustomerController;
use App\Http\Controllers\Secretary\DashboardController;
use App\Http\Controllers\Secretary\InquiryController;
use App\Http\Controllers\Secretary\OrderController;
use App\Http\Controllers\Secretary\ProductController;
use App\Http\Controllers\Secretary\ReceiptController;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Routes réservées au Secrétariat (Guichet / Caisse POS inspiré d'Aronium)
| Préfixe automatique : /api/secretary
|--------------------------------------------------------------------------
*/

Route::middleware(['auth:sanctum', 'role:secretary,admin', 'fiscal.active'])->group(function () {
    // Dashboard Secrétariat (Ventes du jour, encaissements, commandes en attente)
    Route::get('/dashboard', [DashboardController::class, 'index']);

    // Gestion Clientèle (Recherche rapide, création au guichet)
    Route::get('/customers', [CustomerController::class, 'index']);
    Route::post('/customers', [CustomerController::class, 'store']);
    Route::get('/customers/{customer}', [CustomerController::class, 'show']);
    Route::put('/customers/{customer}', [CustomerController::class, 'update']);

    // Catalogue Produits & Prestations Imprimerie
    Route::get('/products', [ProductController::class, 'index']);

    // Commandes & Ventes Guichet (POS style Aronium)
    Route::get('/orders', [OrderController::class, 'index']);
    Route::post('/orders', [OrderController::class, 'store']);
    Route::get('/orders/{order}', [OrderController::class, 'show']);
    Route::post('/orders/{order}/payments', [OrderController::class, 'addPayment']);
    Route::patch('/orders/{order}/status', [OrderController::class, 'updateStatus']);

    // Impression de Tickets & Reçus (Format Aronium avec entête entreprise, IFU, pied de page)
    Route::get('/orders/{order}/receipt', [ReceiptController::class, 'show']);

    // Devis & Demandes de devis
    Route::get('/inquiries', [InquiryController::class, 'index']);
    Route::post('/inquiries', [InquiryController::class, 'store']);
    Route::post('/inquiries/{inquiry}/convert', [InquiryController::class, 'convertToOrder']);
});

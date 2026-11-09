<?php

use App\Http\Controllers\Api\V1\CustomerController;
use Illuminate\Support\Facades\Route;

Route::get('/customers/stats', [CustomerController::class, 'stats']);
Route::apiResource('customers', CustomerController::class);
Route::patch('/customers/{customer}/toggle-status', [CustomerController::class, 'toggleStatus']);
Route::post('/customers/{customer}/contacts', [CustomerController::class, 'addContact']);
Route::post('/customers/{customer}/addresses', [CustomerController::class, 'addAddress']);

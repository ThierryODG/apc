<?php

use App\Http\Controllers\Api\V1\OrderController;
use Illuminate\Support\Facades\Route;

Route::get('/orders', [OrderController::class, 'index']);
Route::get('/inquiries/{inquiry}/order', [OrderController::class, 'show']);
Route::post('/inquiries/{inquiry}/convert', [OrderController::class, 'convertInquiry']);

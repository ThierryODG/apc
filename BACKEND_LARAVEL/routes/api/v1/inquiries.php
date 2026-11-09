<?php

use App\Http\Controllers\Api\V1\InquiryController;
use Illuminate\Support\Facades\Route;

Route::get('/inquiries', [InquiryController::class, 'index']);
Route::post('/inquiries', [InquiryController::class, 'store']);
Route::get('/inquiries/{inquiry}', [InquiryController::class, 'show']);
Route::patch('/inquiries/{inquiry}', [InquiryController::class, 'update']);
Route::patch('/inquiries/{inquiry}/qualify', [InquiryController::class, 'qualify']);
Route::patch('/inquiries/{inquiry}/quote', [InquiryController::class, 'sendQuote']);
Route::patch('/inquiries/{inquiry}/refuse', [InquiryController::class, 'refuse']);

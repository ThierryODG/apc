<?php

use App\Http\Controllers\Api\V1\WorkOrderController;
use Illuminate\Support\Facades\Route;

Route::get('/work-orders/departments', [WorkOrderController::class, 'departments']);
Route::get('/work-orders', [WorkOrderController::class, 'index']);
Route::patch('/work-orders/{workOrder}/status', [WorkOrderController::class, 'updateStatus']);

<?php

use Illuminate\Support\Facades\Route;

Route::get('/', function () {
    return response()->json([
        'app' => 'Africa Print Communication - API',
        'status' => 'operational',
        'version' => '2.0',
    ]);
});


<?php

use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| Routes Principales de l'API (Architecture modulaire par profil)
|--------------------------------------------------------------------------
|
| Chaque profil utilisateur dispose de son propre fichier de routes dédié,
| assurant une maintenance claire et une isolation stricte des responsabilités.
|
*/

// Module Authentification & Profil commun
Route::prefix('auth')->group(base_path('routes/auth.php'));

// Module Administration & Direction
Route::prefix('admin')->group(base_path('routes/admin.php'));

// Module Secrétariat / Caisse & Guichet POS (Aronium)
Route::prefix('secretary')->group(base_path('routes/secretary.php'));

// Module Comptabilité & Trésorerie
Route::prefix('accounting')->group(base_path('routes/accounting.php'));

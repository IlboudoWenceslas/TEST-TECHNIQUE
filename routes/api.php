<?php

use App\Http\Controllers\Api\EvenementController;
use App\Http\Controllers\Api\InscriptionController;
use App\Http\Controllers\Api\AuthControllers;
use Illuminate\Support\Facades\Route;

// Auth
Route::post('/register', [AuthControllers::class, 'register']);
Route::post('/login', [AuthControllers::class, 'login']);

// Routes publiques
Route::get('/events', [EvenementController::class, 'index']);
Route::get('/events/{id}', [EvenementController::class, 'show']);
Route::post('/events/{id}/register', [InscriptionController::class, 'store']);
Route::get('/events/{id}/registrations', [InscriptionController::class, 'index']);
Route::delete('/registrations/{id}', [InscriptionController::class, 'destroy']);

// Routes protégées (JWT requis)
Route::middleware('auth:api')->group(function () {
    Route::post('/events', [EvenementController::class, 'store']);
    Route::put('/events/{id}', [EvenementController::class, 'update']);
    Route::delete('/events/{id}', [EvenementController::class, 'destroy']);

    Route::post('/logout', [AuthControllers::class, 'logout']);
});
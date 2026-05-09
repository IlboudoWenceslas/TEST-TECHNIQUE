<?php


use App\Http\Controllers\Api\EvenementController;
use App\Http\Controllers\Api\InscriptionController;
use Illuminate\Support\Facades\Route;


// Route::middleware('auth:sanctum')->get('/user', function (Request $request) {
//     return $request->user();
// });
 Route::middleware('auth:api')->group(function () {
    Route::post('/evenements', [EvenementController::class, 'store']);
    Route::post('/inscriptions', [InscriptionController::class, 'store']);
    Route::get('/evenements',[EvenementController::class, 'index']);
    Route::get('/evenements/{id}',[EvenementController::class, 'show']);
    Route::put('/evenements/{id}',[EvenementController::class, 'update']);
    Route::delete('/evenements/{id}',[EvenementController::class, 'destroy']);
        Route::get('/inscriptions',[InscriptionController::class, 'index']);
        Route::get('/inscriptions/{id}',[InscriptionController::class, 'show']);
        Route::put('/inscriptions/{id}',[InscriptionController::class, 'update']);
        Route::delete('/inscriptions/{id}',[InscriptionController::class, 'destroy']);
});

<?php

namespace App\Http\Controllers\Api;

use App\Http\Controllers\Controller;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Hash;
use App\Models\User;
use Illuminate\Validation\ValidationException;
class AuthControllers extends Controller
{
    //
     public function register(Request $request)
    {
        // 1. Validation de toutes les données envoyées par le mobile
        $validated = $request->validate([
            // Infos personnelles
            'firstName'            => 'required|string|max:255',
            'lastName'         => 'required|string|max:255',
            'email'          => 'required|email|unique:users,email',
            'password'       => 'required|string|min:8',
        ]);
            // Étape 1 — Créer l'utilisateur
            $user = User::create([
                'firstName'       => $validated['firstName'],
                'lastName'    => $validated['lastName'],
                'email'     => $validated['email'],
                'password'  => Hash::make($validated['password']),
            ]);        
            return $user;      
        // 3. Générer le token JWT pour l'utilisateur créé
        $token = auth('api')->login($result);

        return $this->respondWithToken($token, $result, 201);
    }

    // Connexion
    public function login(Request $request)
    {
        $request->validate([
            'email' => 'required|email',
            'password' => 'required|string',
        ]);

        // Correction: Chercher l'utilisateur 
        $user = User::where('email', $request->email)->first();

        if (!$user || !Hash::check($request->password, $user->password)) {
            throw ValidationException::withMessages([
                'email' => ['Les identifiants sont incorrects.'],
            ]);
        }

        // Générer un token avec JWT
        $token = auth('api')->login($user);

        return $this->respondWithToken($token, $user);
    }

     public function logout()
    {
        auth('api')->logout();
        return response()->json(['message' => 'Déconnecté']);
    }
    protected function respondWithToken($token, $user, $statusCode = 200)
    {
        return response()->json([
            'success'    => true,
            'data'       => $user,
            'access_token' => $token,
            'token_type' => 'bearer',
            'expires_in' => auth('api')->factory()->getTTL() * 60
        ], $statusCode);
    }


}

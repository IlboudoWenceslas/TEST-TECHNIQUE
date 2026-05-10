<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Evenement;
use App\Models\Inscription;
use Illuminate\Http\Request;
class InscriptionController extends Controller
{
    // public function index($eventId)
    // {
    //     $evenement = Evenement::find($eventId);
    //     if (!$evenement) {
    //         return response()->json(['message' => 'Evenement not found'], 404);
    //     }

    //     return response()->json($evenement->inscriptions);
    // }
    // public function index()
    // {
    //     //
    //     $inscriptions = Inscription::all();
    //     return response()->json($inscriptions->evenement);
    // }
    public function index($eventId)
{
    $evenement = Evenement::find($eventId);
    if (!$evenement) {
        return response()->json(['message' => 'Evenement not found'], 404);
    }
    return response()->json($evenement->inscriptions);
}

    public function store(Request $request, $eventId)
    {
        $evenement = Evenement::find($eventId);
        if (!$evenement) {
            return response()->json(['message' => 'Evenement not found'], 404);
        }

        $validated = $request->validate([
            'firstName' => 'required|string',
            'lastName'  => 'required|string',
            'email'     => 'required|email',
        ]);

        // Vérifier capacité
        $placesOccupees = $evenement->inscriptions()->count();
        if ($placesOccupees >= $evenement->capacity) {
            return response()->json([
                'error'   => 'CAPACITY_REACHED',
                'message' => 'Cet evenement est complet.',
            ], 422);
        }

        // Vérifier unicité email
        $dejaInscrit = $evenement->inscriptions()
            ->where('email', $validated['email'])
            ->exists();

        if ($dejaInscrit) {
            return response()->json([
                'error'   => 'DUPLICATE_EMAIL',
                'message' => 'Cette adresse email est deja enregistree pour cet evenement.',
            ], 409);
        }
        $validated['registeredAt'] = now()->toDateTimeString();
        $inscription = $evenement->inscriptions()->create($validated);
    

        return response()->json($inscription, 201);
    }
public function show($id)
    {
        //
        $inscription = Inscription::find($id);
        if (!$inscription) {
            return response()->json(['message' => 'Inscription not found'], 404);
        }
        return response()->json($inscription);
    }
    public function destroy($id)
    {
        $inscription = Inscription::find($id);
        if (!$inscription) {
            return response()->json(['message' => 'Inscription not found'], 404);
        }

        $inscription->delete();
        return response()->json(['message' => 'Inscription annulee']);
    }
}
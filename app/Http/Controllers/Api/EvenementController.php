<?php
namespace App\Http\Controllers\Api;
use App\Http\Controllers\Controller;
use App\Models\Evenement;
use Illuminate\Http\Request;

class EvenementController extends Controller
{
    public function index(Request $request)
{
    $query = Evenement::withCount('inscriptions');

    if ($request->has('search')) {
        $query->where('title', 'like', '%' . $request->search . '%');
    }

    if ($request->has('date')) {
        $query->whereDate('date', $request->date);
    }

    return response()->json($query->get());
}

    public function store(Request $request)
    {
        $validated = $request->validate([
            'title'       => 'required|string|max:100',
            'description' => 'nullable|string',
            'date'        => 'required|date',
            'location'    => 'required|string',
            'capacity'    => 'required|integer|min:1',
        ]);
        $validated['createdAt']=now()->toDateTimeString();

        $evenement = Evenement::create($validated);
        return response()->json($evenement, 201);
    }

   public function show($id)
{
    $evenement = Evenement::withCount('inscriptions')->find($id);
    if (!$evenement) {
        return response()->json(['message' => 'Evenement not found'], 404);
    }
    return response()->json($evenement);
}

    public function update(Request $request, $id)
    {
        $evenement = Evenement::find($id);
        if (!$evenement) {
            return response()->json(['message' => 'Evenement not found'], 404);
        }

        $validated = $request->validate([
            'title'       => 'sometimes|string|max:100',
            'description' => 'nullable|string',
            'date'        => 'sometimes|date',
            'location'    => 'sometimes|string',
            'capacity'    => 'sometimes|integer|min:1',
        ]);

        $evenement->update($validated);
        return response()->json($evenement);
    }

    public function destroy($id)
    {
        $evenement = Evenement::find($id);
        if (!$evenement) {
            return response()->json(['message' => 'Evenement not found'], 404);
        }

        // Supprime les inscriptions associées puis l'événement
        $evenement->inscriptions()->delete();
        $evenement->delete();

        return response()->json(['message' => 'Evenement et inscriptions supprimés']);
    }
}
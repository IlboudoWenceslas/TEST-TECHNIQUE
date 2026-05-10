<?php

namespace Tests\Feature;

use App\Models\Evenement;
use App\Models\User;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class EvenementTest extends TestCase
{
    use RefreshDatabase;
    

    private function getToken(): string
{
    $user = User::create([
        'firstName' => 'Premier',
        'lastName'  => 'Users',
        'email'     => 'test@gmail.com',
        'password'  => bcrypt('secret123'),
    ]);

    return auth('api')->login($user);
}

    public function test_liste_evenements_retourne_200(): void
    {
        $response = $this->getJson('/api/events');
        $response->assertStatus(200);
    }

    public function test_creation_evenement_valide_retourne_201(): void
    {
        $token = $this->getToken();

        $response = $this->withToken($token)->postJson('/api/events', [
            'title'    => 'Conférence Tech Ouaga',
            'date'     => '2025-11-15T18:00:00Z',
            'location' => 'Ouagadougou',
            'capacity' => 100,
        ]);

        $response->assertStatus(201);
        $response->assertJsonFragment(['title' => 'Conférence Tech Ouaga']);
    }

    public function test_creation_evenement_sans_titre_retourne_400(): void
    {
        $token = $this->getToken();

        $response = $this->withToken($token)->postJson('/api/events', [
            'date'     => '2025-11-15T18:00:00Z',
            'location' => 'Ouagadougou',
            'capacity' => 100,
        ]);

        $response->assertStatus(422); // Laravel retourne 422 pour les erreurs de validation
    }

    public function test_creation_evenement_capacity_zero_retourne_400(): void
    {
        $token = $this->getToken();

        $response = $this->withToken($token)->postJson('/api/events', [
            'title'    => 'Test',
            'date'     => '2025-11-15T18:00:00Z',
            'location' => 'Ouaga',
            'capacity' => 0,
        ]);

        $response->assertStatus(422);
    }

    public function test_evenement_inexistant_retourne_404(): void
    {
        $response = $this->getJson('/api/events/9999');
        $response->assertStatus(404);
    }

    public function test_suppression_evenement_supprime_inscriptions(): void
    {
        $token = $this->getToken();

        $evenement = Evenement::create([
            'title'    => 'Event à supprimer',
            'date'     => '2025-11-15 18:00:00',
            'location' => 'Ouaga',
            'capacity' => 10,
            'createdAt' => now()->toDateTimeString(),
        ]);

        $evenement->inscriptions()->create([
            'firstName' => 'Aminata',
            'lastName'  => 'Ouedraogo',
            'email'     => 'aminata@test.com',
            'registeredAt' => now()->toDateTimeString(),
        ]);

        $this->withToken($token)->deleteJson('/api/events/' . $evenement->id)
            ->assertStatus(200);

        $this->assertDatabaseMissing('inscriptions', ['eventId' => $evenement->id]);
    }
}
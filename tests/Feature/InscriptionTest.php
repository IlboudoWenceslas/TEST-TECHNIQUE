<?php

namespace Tests\Feature;

use App\Models\Evenement;
use Illuminate\Foundation\Testing\RefreshDatabase;
use Tests\TestCase;

class InscriptionTest extends TestCase
{
    use RefreshDatabase;

    private function creerEvenement(int $capacity = 2): Evenement
    {
        return Evenement::create([
            'title'    => 'Test Event',
            'date'     => '2025-11-15 18:00:00',
            'location' => 'Ouagadougou',
            'capacity' => $capacity,
            'createdAt' => now()->toDateTimeString(),
        ]);
    }

    public function test_inscription_valide_retourne_201(): void
    {
        $evenement = $this->creerEvenement(10);

        $response = $this->postJson("/api/events/{$evenement->id}/register", [
            'firstName' => 'Aminata',
            'lastName'  => 'Ouedraogo',
            'email'     => 'aminata@test.com',
        ]);

        $response->assertStatus(201);
        $response->assertJsonFragment(['email' => 'aminata@test.com']);
    }

    public function test_inscription_champs_manquants_retourne_422(): void
    {
        $evenement = $this->creerEvenement(10);

        $response = $this->postJson("/api/events/{$evenement->id}/register", [
            'firstName' => 'Aminata',
            // lastName et email manquants
        ]);

        $response->assertStatus(422);
    }

    public function test_inscription_email_invalide_retourne_422(): void
    {
        $evenement = $this->creerEvenement(10);

        $response = $this->postJson("/api/events/{$evenement->id}/register", [
            'firstName' => 'Aminata',
            'lastName'  => 'Ouedraogo',
            'email'     => 'pas-un-email',
        ]);

        $response->assertStatus(422);
    }

    /* Point non négociable #1 — Capacité */
    public function test_inscription_evenement_complet_retourne_422(): void
    {
        $evenement = $this->creerEvenement(1); // capacité = 1

        // Remplir l'événement
        $evenement->inscriptions()->create([
            'firstName' => 'Premier',
            'lastName'  => 'Inscrit',
            'email'     => 'premier@test.com',
            'registeredAt' => now()->toDateTimeString(),
        ]);

        // Tenter une 2ème inscription
        $response = $this->postJson("/api/events/{$evenement->id}/register", [
            'firstName' => 'Deuxieme',
            'lastName'  => 'Inscrit',
            'email'     => 'deuxieme@test.com',
        ]);

        $response->assertStatus(422);
        $response->assertJsonFragment(['error' => 'CAPACITY_REACHED']);
    }

    /** ✅ Point non négociable #2 — Unicité email */
    public function test_inscription_email_deja_inscrit_retourne_409(): void
    {
        $evenement = $this->creerEvenement(10);

        $data = [
            'firstName' => 'Aminata',
            'lastName'  => 'Ouedraogo',
            'email'     => 'aminata@test.com',
        ];

        // Première inscription OK
        $this->postJson("/api/events/{$evenement->id}/register", $data)
            ->assertStatus(201);

        // Deuxième avec le même email
        $response = $this->postJson("/api/events/{$evenement->id}/register", $data);

        $response->assertStatus(409);
        $response->assertJsonFragment(['error' => 'DUPLICATE_EMAIL']);
    }

    public function test_annulation_inscription_retourne_200(): void
    {
        $evenement = $this->creerEvenement(10);

        $inscription = $evenement->inscriptions()->create([
            'firstName' => 'Aminata',
            'lastName'  => 'Ouedraogo',
            'email'     => 'aminata@test.com',
            'registeredAt' => now()->toDateTimeString(),
        ]);

        $this->deleteJson("/api/registrations/{$inscription->id}")
            ->assertStatus(200);

        $this->assertDatabaseMissing('inscriptions', ['id' => $inscription->id]);
    }
}
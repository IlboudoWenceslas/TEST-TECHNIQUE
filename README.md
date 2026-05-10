# Gestion d'événements — Test technique Full Stack

IlboudoTongnooma Wenceslas  Développeur Full Stack  


## Stack choisie
Couche  Technologie 
Backend  Laravel  (API REST) 
Stockage  SQLite  
 Frontend web Angular 
 Frontend mobile Flutter (Dart) 



## Prérequis

- PHP >= 8.2 + Composer
- Node.js >= 18 + npm
- Flutter SDK >= 3.x
- Git

---

## 1. Backend — Laravel

### Installation

```bash
cd backend
composer install
cp .env.example .env
php artisan key:generate
```

### Configuration base de données

Dans le fichier `.env`, vérifier que SQLite est configuré :

```env
DB_CONNECTION=sqlite
DB_DATABASE=/chemin/absolu/vers/backend/database/database.sqlite
```

Créer le fichier SQLite et exécuter les migrations :

```bash
touch database/database.sqlite
php artisan migrate
```

### Lancement

```bash
php artisan serve
# API disponible sur http://localhost:8000
```

### CORS

Le CORS est configuré dans `config/cors.php` pour autoriser Angular (`http://localhost:4200`) et Flutter (toutes origines en développement).

---

## 2. Frontend web — Angular

### Installation

```bash
cd frontend-angular
npm install
```

### Lancement

```bash
ng serve
# Application disponible sur http://localhost:4200
```

L'URL de l'API est configurée dans `src/services/event.ts` :

```ts
export const environment = {
  production: false,
  apiUrl: 'http://localhost:8000/api'
};
```

### Écrans disponibles

- **Liste des événements** — cartes avec titre, date, lieu, places restantes, badge "Complet"
- **Détail & inscription** — compteur de places, formulaire (prénom, nom, email), retour visuel succès/erreur
- **Création d'événement** *(optionnel)* — formulaire avec validation côté client

---

## 3. Frontend mobile — Flutter

### Installation

```bash
cd testtechniquefronend_mobile
flutter pub get
```

### Lancement

```bash
# Émulateur Android
flutter run

# Ou cibler un appareil spécifique
flutter run -d emulator-5554
```

> **Important :** Sur émulateur Android, l'API Laravel est accessible via `http://addresseIpMachine:8000` (pas `localhost`). Cette URL est déjà configurée dans `lib/config/api_config.dart`.

### Écrans disponibles

- **Liste des événements** — ListView avec SearchBar, badge "Complet", CircularProgressIndicator
- **Détail & inscription** — compteur de places, formulaire, SnackBar pour le retour utilisateur

---

## Endpoints de l'API


GET  `/api/events`  Liste des événements. Supporte `?search=` et `?date=` 
 POST  `/api/events`  Créer un événement 
 GET  `/api/events/:id`  Détail d'un événement 
 PUT  `/api/events/:id`  Modifier un événement 
 DELETE  `/api/events/:id`  Supprimer un événement et ses inscriptions 
 POST  `/api/events/:id/register`  Inscrire un participant 
 GET  `/api/events/:id/registrations`  Liste des participants 
 DELETE  `/api/registrations/:id`  Annuler une inscription 

### Codes HTTP retournés


 200  Succès (GET, PUT, DELETE) 
 201  Création réussie (POST) 
 400  Champ manquant ou invalide — retourne la liste des erreurs 
 404  Ressource introuvable 
 409  Email déjà inscrit à cet événement 
 422  Événement complet — capacité atteinte 

---

## Exemples curl

### Créer un événement

```bash
curl -X POST http://localhost:8000/api/events \
  -H "Content-Type: application/json" \
  -d '{
    "title": "Conférence Tech Ouaga 2025",
    "description": "Rencontre des développeurs burkinabè",
    "date": "2025-11-15T18:00:00Z",
    "location": "Ouagadougou, CCVA",
    "capacity": 100
  }'
```

### Lister les événements

```bash
curl http://localhost:8000/api/events
curl "http://localhost:8000/api/events?search=tech"
curl "http://localhost:8000/api/events?date=2025-11-15"
```

### Inscrire un participant

```bash
curl -X POST http://localhost:8000/api/events/1/register \
  -H "Content-Type: application/json" \
  -d '{
    "firstName": "Aminata",
    "lastName": "Ouedraogo",
    "email": "aminata@example.com"
  }'
```

### Annuler une inscription

```bash
curl -X DELETE http://localhost:8000/api/registrations/1
```

## Soumission

Dépôt Git : https://github.com/IlboudoWenceslas/TEST-TECHNIQUE.git  
Email envoyé à : candidaturetech1@gmail.com  
Objet : ` IlboudoTongnooma Wenceslas — Gestion événements`

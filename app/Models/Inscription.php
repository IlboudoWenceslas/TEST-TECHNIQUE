<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Inscription extends Model
{
    //
    use HasUuids;
    protected $fillable=[
        'eventId',
        'firstName',
        'lastName',
        'email',
        'registeredAt',
    ];
    public function inscriptions()
    {
        return $this->hasMany(Inscription::class, 'eventId');
    }
}

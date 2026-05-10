<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Inscription extends Model
{
    //
    public $timestamps = false;
    protected $fillable=[
        'eventId',
        'firstName',
        'lastName',
        'email',
        'registeredAt',
    ];
    public function evenement()
    {
        return $this->belongsTo(Evenement::class, 'eventId');
    }
}

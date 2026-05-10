<?php

namespace App\Models;


use Illuminate\Database\Eloquent\Model;

class Evenement extends Model
{
    //

     public $timestamps = false;
    protected $fillable=[
        'title',
        'description',
        'date',
        'location',
        'capacity',
        'createdAt',
    ];
public function inscriptions()
{
    return $this->hasMany(Inscription::class, 'eventId');
}
}

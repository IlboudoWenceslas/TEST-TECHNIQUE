<?php

namespace App\Models;

use Illuminate\Database\Eloquent\Concerns\HasUuids;
use Illuminate\Database\Eloquent\Model;

class Evenement extends Model
{
    //
     use HasUuids;
    protected $fillable=[
        'title',
        'description',
        'date',
        'location',
        'capacity',
        'createdAt',
    ];

}

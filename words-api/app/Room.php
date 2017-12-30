<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    /**
     * {@inheritDoc}
     */
    protected $fillable = ['name', 'chatkit_room_id'];
}

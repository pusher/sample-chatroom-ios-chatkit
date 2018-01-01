<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Room extends Model
{
    public $timestamps = false;

    public $incrementing = false;

    protected $fillable = ['id', 'name', 'created_by_id', 'private', 'created_at', 'updated_at'];

    protected $casts = ['private' => 'boolean'];
}

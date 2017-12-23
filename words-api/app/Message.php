<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Message extends Model
{
    public $timestamps = false;

    protected $fillable = [
        'message_id', 'delivered'
    ];

    protected $casts = [
        'message_id' => 'integer',
        'delivered' => 'boolean',
    ];
}

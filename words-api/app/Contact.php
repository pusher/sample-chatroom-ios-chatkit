<?php

namespace App;

use Illuminate\Database\Eloquent\Model;

class Contact extends Model
{
    /**
     * {@inheritDoc}
     */
    protected $fillable = ['user1_id', 'user2_id', 'room_id'];

    /**
     * {@inheritDoc}
     */
    protected $with = ['user1', 'user2'];

    /**
    * Get the user1 relationship
    */
    public function user1()
    {
        return $this->belongsTo(User::class);
    }

    /**
    * Get the user2 relationship
    */
    public function user2()
    {
        return $this->belongsTo(User::class);
    }

    /**
     * Get the contacts list.
     */
    public function scopeFor($query, $user_id)
    {
        return $query->where('user1_id', $user_id)->orWhere('user2_id', $user_id);
    }
}

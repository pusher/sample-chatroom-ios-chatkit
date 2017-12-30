<?php

namespace App\Http\Controllers;

use Illuminate\Http\Request;

class ContactController extends Controller
{
    public function index()
    {
        $contacts = [];

        $user_id = request()->get('user_id');

        Contact::contacts($user_id)->get()->each(function ($contact) use ($user_id) {
            $friend = $contact->user1_id === $user_id ? $contact->user2 : $contact->user1;

            $contacts[] = array_merge($friend->toArray(), [
                'room_id' => $contact->room->id,
                'room_name' => $contact->room->name
            ]);
        });

        return response()->json($contacts);
    }

    public function create(Request $request)
    {
        $data = $request->validate([
            'user_id' => ''
        ]);
    }
}

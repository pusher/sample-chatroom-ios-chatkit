<?php

namespace App\Http\Controllers;

use App\User;
use App\Contact;
use Illuminate\Http\Request;

class ContactController extends Controller
{
    /**
     * Return contacts for the authenticated user.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function index()
    {
        $contacts = [];

        $user = request()->user();

        // Loop through the contacts and format each one
        Contact::for($user->id)->get()->each(function ($contact) use ($user, &$contacts) {
            $friend = $contact->user1_id === $user->id ? $contact->user2 : $contact->user1;
            $contacts[] = $this->formatContact($contact, $friend, $user);
        });

        return response()->json($contacts);
    }

    /**
     * Create a new contact.
     *
     * @param  \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function create(Request $request)
    {
        $user = $request->user();

        $data = $request->validate(['user_id' => "required|not_in:{$user->email}|valid_contact"]);

        $friend = User::whereEmail($data['user_id'])->first();

        $createdContact = Contact::create([
            'user1_id' => $user->id,
            'user2_id' => $friend->id,
            'room_id' => generate_room_id($user, $friend),
        ]);

        return response()->json($this->formatContact($createdContact, $friend, $user));
    }

    /**
     * Format a contact array
     */
    protected function formatContact(Contact $contact, User $friend, User $me) : array
    {
        return array_merge($friend->toArray(), [
            'room' => [
                'id' => $contact->room_id,
                'name' => $friend->name,
                'members' => [$me->chatkit_id, $friend->chatkit_id],
            ]
        ]);
    }
}

<?php

namespace App\Http\Controllers;

use App\User;
use App\Contact;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

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

        $user = Auth::user();

        Contact::for($user->id)->get()->each(function ($contact) use ($user, &$contacts) {
            $friend = $contact->user1_id === $user->id ? $contact->user2 : $contact->user1;

            $contacts[] = array_merge($friend->toArray(), [
                'room' => [
                    'id' => $contact->room_id,
                    'name' => $friend->name,
                    'members' => [$user->chatkit_id, $friend->chatkit_id],
                ]
            ]);
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
        $user = Auth::user();
        $friend = User::find($request->get('user_id'));

        $request->validate(['user_id' => "required|exists:users,id|not_in:{$user->id}|unique_contact"]);

        return response()->json(
            Contact::create([
                'user1_id' => $user->id,
                'user2_id' => $friend->id,
                'room_id' => generate_room_id($user, $friend),
            ])
        );
    }
}

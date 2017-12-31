<?php

namespace App\Http\Controllers;

use App\User;
use App\Chatkit;
use Illuminate\Http\Request;

class UserController extends Controller
{
    /**
     * Create a new user
     *
     * @param  \Illuminate\Http\Request  $request
     * @param  \App\Chatkit $chatkit
     * @return \Illuminate\Http\JsonResponse
     */
    public function create(Request $request, Chatkit $chatkit)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'password' => 'required|string|min:6',
            'email' => 'required|string|email|max:255|unique:users',
        ]);

        $data['chatkit_id'] = str_slug($data['email'], '_');

        $response = $chatkit->create_user($data['chatkit_id'], $data['name']);

        if ($response['status'] !== 201) {
            return response()->json(['status' => 'error'], 400);
        }

        return response()->json(User::create($data));
    }
}

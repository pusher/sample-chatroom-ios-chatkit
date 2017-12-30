<?php

namespace App\Http\Controllers;

use App\User;
use App\Chatkit;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Auth;

class UserController extends Controller
{
    /**
     * Chatkit instance
     *
     * @var \App\Chatkit
     */
    protected $chatkit;

    /**
     * Class constructor
     */
    public function __construct()
    {
        $this->chatkit = app('chatkit');
    }

    /**
     * Get all the registered users.
     *
     * @param \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function index(Request $request)
    {
        return response()->json(
            User::where('id', '!=', Auth::user()->id)->get()
        );
    }

    /**
     * Create a new user
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function create(Request $request)
    {
        $data = $request->validate([
            'name' => 'required|string|max:255',
            'password' => 'required|string|min:6',
            'email' => 'required|string|email|max:255|unique:users',
        ]);

        $data['chatkit_id'] = str_slug($data['email'], '_');

        $response = $this->chatkit->create_user($data['chatkit_id'], $data['name']);

        $user = $response['status'] == 201 ? User::create($data) : false;

        if (!$user) {
            $user = ['status' => 'error'];
            $statusCode = 400;
        }

        return response()->json($user, $statusCode ?? 200);
    }
}

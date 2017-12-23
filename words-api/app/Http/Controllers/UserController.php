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
     * @var \Chatkit\Chatkit
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
        $users = User::whereNot('id', (int) $request->get('id'))->get();

        return response()->json($users);
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
            'email' => 'required|string|email|max:255|unique:users',
            'password' => 'required|string|min:6',
        ]);

        $response = $this->chatkit->create_user($data['email'], $data['name'])['body'] ?? false;

        $user = $response ? $this->userWithToken(User::create($data)) : ['status' => 'error'];

        $statusCode = $user['token'] ?? false ? 200 : 400;

        return response()->json($user, $statusCode);
    }

    /**
     * Checks a users login credentials.
     *
     * @param  \Illuminate\Http\Request  $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function login(Request $request)
    {
        $data = $request->validate([
            'email' => 'required|string',
            'password' => 'required|string',
        ]);

        $user = Auth::attempt($data)
            ? $this->userWithToken(User::whereEmail($data['email'])->first())
            : ['status' => 'error'];

        $statusCode = $user['token'] ?? false ? 200 : 400;

        return response()->json($user, $statusCode);
    }

    /**
     * Adds the token to the user object array
     *
     * @param User $user
     * @return array
     */
    protected function userWithToken(User $user) : array
    {
        return array_merge($user->toArray(), [
            'token' => $this->chatkit->generate_token_pair(['user_id' => $user->email])
        ]);
    }
}

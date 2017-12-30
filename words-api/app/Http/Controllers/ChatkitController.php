<?php

namespace App\Http\Controllers;

use Illuminate\Support\Facades\Auth;

class ChatkitController extends Controller
{
    /**
     * Class constructor.
     */
    public function __construct()
    {
        $this->chatkit = app('chatkit');
    }

    /**
     * Checks a users login credentials.
     *
     * @return \Illuminate\Http\JsonResponse
     */
    public function getToken()
    {
        return response()->json(
            $this->chatkit->generate_token_pair(['user_id' => Auth::user()->chatkit_id])
        );
    }
}

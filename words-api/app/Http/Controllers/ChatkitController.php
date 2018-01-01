<?php

namespace App\Http\Controllers;

use App\Chatkit;
use Illuminate\Support\Facades\Auth;

class ChatkitController extends Controller
{
    /**
     * Checks a users login credentials.
     *
     * @param  \App\Chatkit $chatkit
     * @return \Illuminate\Http\JsonResponse
     */
    public function getToken(Chatkit $chatkit)
    {
        return response()->json(
            $chatkit->generate_token_pair(['user_id' => Auth::user()->chatkit_id])
        );
    }
}

<?php

namespace App\Http\Controllers;

use App\Message;
use Illuminate\Http\Request;

class MessageController extends Controller
{
    /**
     * Create a new message.
     *
     * @param  \Illuminate\Http\Request $request
     * @return \Illuminate\Http\JsonResponse
     */
    public function create(Request $request)
    {
        $message = Message::create(
            $request->validate([
                'delivered' => 'boolean',
                'message_id' => 'required|unique:messages',
            ])
        );

        return response()->json($message);
    }

    /**
     * Update the message status.
     *
     * @param  \Illuminate\Http\Request $request
     * @param  \App\Message $message
     * @return \Illuminate\Http\JsonResponse
     */
    public function update(Request $request, Message $message)
    {
        $message->update(
            $request->validate(['delivered' => 'boolean'])
        );

        return response()->json($message);
    }
}

<?php
use App\User;

if (!function_exists('generate_room_id')) {
    /**
     * Generate room ID from the supplied user objects
     *
     * @param  \App\User
     * @param  \App\User
     * @return string
     */
    function generate_room_id(User $user, User $user2) : string
    {
        $chatkit_ids = [$user->chatkit_id, $user2->chatkit_id];

        sort($chatkit_ids);

        return md5(implode('', $chatkit_ids));
    }
}

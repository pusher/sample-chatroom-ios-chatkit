<?php

namespace App;

use Chatkit\Chatkit as PusherChatkit;

class Chatkit extends PusherChatkit
{
    /**
     * Creates a new room.
     *
     * @param array $options  The room options
     *                          [Available Options]
     *                          • name (string|optional): Represents the name with which the room is identified.
     *                              A room name must not be longer than 40 characters and can only contain lowercase letters,
     *                              numbers, underscores and hyphens.
     *                          • private (boolean|optional): Indicates if a room should be private or public. Private by default.
     *                          • user_ids (array|optional): If you wish to add users to the room at the point of creation,
     *                              you may provide their user IDs.
     * @return array
     */
    public function create_room(array $options = [])
    {
        $body = [];

        if (isset($options['name'])) {
            $body['name'] = (string) $options['name'];
        }

        if (isset($options['private'])) {
            $body['private'] = (bool) $options['private'];
        }

        if (isset($options['user_ids'])) {
            $body['user_ids'] = (array) $options['user_ids'];
        }

        $ch = $this->create_curl(
            $this->api_settings,
            '/rooms',
            $this->get_server_token(),
            'POST',
            $body
        );

        $response = $this->exec_curl($ch);
        return $response;
    }

    protected function get_server_token()
    {
        return $this->generate_access_token([
            'su' => true,
            'user_id' => 'chatkit-dashboard'
        ]);
    }
}

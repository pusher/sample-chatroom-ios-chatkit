<?php

namespace App\Providers;

use App\Chatkit;
use App\Contact;
use Illuminate\Support\Facades\Auth;
use Illuminate\Support\ServiceProvider;
use Illuminate\Support\Facades\Validator;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        Validator::extend('unique_contact', function ($attribute, $value, $parameters, $validator) {
            $friend_id = (int) $value;
            $user_id = Auth::user()->id;

            return Contact::where(function ($query) use ($friend_id, $user_id) {
                $query->where(function ($query) use ($friend_id, $user_id) {
                    $query->where('user1_id', $user_id)->where('user2_id', $friend_id);
                })
                ->orWhere(function ($query) use ($friend_id, $user_id) {
                    $query->where('user2_id', $user_id)->where('user1_id', $friend_id);
                });
            })->count() === 0;
        });
    }

    /**
     * Register any application services.
     *
     * @return void
     */
    public function register()
    {
        $this->app->singleton('chatkit', function () {
            $instanceLocator = config('services.chatkit.instanceLocator');
            $secret = config('services.chatkit.secret');

            return new Chatkit($instanceLocator, $secret);
        });
    }
}

<?php

namespace App\Providers;

use App\Chatkit;
use App\User;
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
        Validator::extend('valid_contact', function ($attribute, $value, $parameters, $validator) {
            if (!$friend = User::whereEmail($value)->first()) {
                return false;
            }

            $user = Auth::user();

            return Contact::where(function ($query) use ($friend, $user) {
                $query->where(function ($query) use ($friend, $user) {
                    $query->where('user1_id', $user->id)->where('user2_id', $friend->id);
                })
                ->orWhere(function ($query) use ($friend, $user) {
                    $query->where('user2_id', $user->id)->where('user1_id', $friend->id);
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
        $this->app->singleton('App\Chatkit', function () {
            $instanceLocator = config('services.chatkit.instanceLocator');
            $secret = config('services.chatkit.secret');

            return new Chatkit($instanceLocator, $secret);
        });
    }
}

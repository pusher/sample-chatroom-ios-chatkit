<?php

namespace App\Providers;

use App\Chatkit;
use Illuminate\Support\ServiceProvider;

class AppServiceProvider extends ServiceProvider
{
    /**
     * Bootstrap any application services.
     *
     * @return void
     */
    public function boot()
    {
        //
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

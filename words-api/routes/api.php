<?php


/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider within a group which
| is assigned the "api" middleware group. Enjoy building your API!
|
*/

Route::group(['middleware' => 'auth:api'], function () {
    Route::post('/users', 'UserController@index');
    Route::post('/chatkit/token', 'ChatkitController@getToken');
    Route::put('/messages/{id}', 'MessageController@update');
    Route::post('/messages', 'MessageController@create');
});

Route::post('/users/signup', 'UserController@create');

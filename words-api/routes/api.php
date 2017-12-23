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

Route::post('/users/login', 'UserController@login');
Route::post('/users/signup', 'UserController@create');
Route::get('/users', 'UserController@index');
Route::put('/messages/{id}', 'MessageController@update');
Route::post('/messages', 'MessageController@create');

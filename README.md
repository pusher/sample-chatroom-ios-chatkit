# sample-chatroom-ios-chatkit
How to make an iOS Chatroom app using Swift and Chatkit

[![Get help on Codementor](https://cdn.codementor.io/badges/get_help_github.svg)](https://www.codementor.io/neoighodaro?utm_source=github&utm_medium=button&utm_term=neoighodaro&utm_campaign=github)

![](https://www.dropbox.com/s/yv4n4tjbzszp7n0/Create-iOS-Chat-App-Using-Chatkit-17.gif?raw=1)

## Prerequisites
* Xcode installed on your machine.
* Cocoapods installed on your machine.
* Composer installed on your machine.
* PHP and SQLite (or MySQL) installed on your machine.
* A [Pusher Chatkit](https://pusher.com/chatkit) application.

## How to run on your machine
* Download or clone the repository to your machine.
* `cd` to the project directory and run the following command: `pod install`.
* Next open the `words-api` project in your editor of choice. This is a Laravel application.
* Copy the `.env.example` file to `.env`.
* Run the command to generate an application key: `php artisan key:generate`
* Update the `CHATKIT_*` keys with your Chatkit app credentials.
* Run the command `composer install` to install the dependencies.
* Create a database and put the credentials to connect to it in the `.env` file.
* Run your migration: `php artisan migrate`.
* Run the command to install Passport: `php artisan passport:install`
* Start the server using the command: `php artisan serve`.
* Copy the `Client ID` and `Client Secret` of the "Password grant client".
* Open the `words.xcworkspace` file. This should open in Xcode.
* Open the `AppDelegate` and in there update the settings in the `AppConstants` struct.
* While your PHP server is running, build your Xcode project.

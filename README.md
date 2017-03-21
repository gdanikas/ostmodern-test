[![N|Ostmodern](https://media.licdn.com/mpr/mpr/shrink_150_150/AAEAAQAAAAAAAAenAAAAJDAwYTZkMzE3LTBkZmUtNDFmYi1hNTU4LTYzYmJiNmU2OTk0OQ.png)](http://www.ostmodern.co.uk/)

## Assignment

The goal of this exercise is to show that you understand the iOS platform through prototyping and debugging, with the aim to make the Ostmodern test app production ready.

It's driven by an instance of the Skylark API filled with sample data. Skylark is our video platform that enables our clients to curate their video content. Skylark has API endpoints for Sets and TV Episodes (explained more in the appendices).

Focus on the data and layout, written in Swift 3.0 so take advantage of the Swift language; with the final app being ready for public use.

Objective:
* Create the view that lists the contents of the ‘Home’ set with the option to favourite an item.
Examples
* http://player.bfi.org.uk/
* http://player.bfi.org.uk/

* Create a view that show details for each of the ‘Home’ options;
* http://player.bfi.org.uk/film/watch-shaun-the-sheep-movie-2014/
* https://www.alchemiya.com/#/programme/skateistan

Advantageous
* Validating and handling API errors and responses

Not required:
* Video playback

## Requirements

* Xcode 8.2+
* Swift 3.0+
* iOS 9.0+

## CocoaPods

* Alamofire
* AlamofireImage
* Realm
* RealmSwift
* SwiftyJSON
* SwiftyBeaver

## Features

* Adopting MVVM to show Home Set contents from ViewModel
Only updating the Home Set UI if data has truly changed (updated/removed/inserted)

* Storyboards
* AutoLayout
* Using XIBs to layout custom views
* Unit Tests
* Validating and handling API errors and responses
* Network waiting indicators in status bar
* Using Delegation and Notification Center to communicate between controllers 

## SOLID principles

Trying to apply SOLID principles and Clean Code, specially the Single Responsability. Classes must be lightewigth and perform only one task inside his abstraction layer. 

## Database

I have created the following Realm objects:

* Episode: List of episodes
* Divider: List of dividers for grouping episodes

The Divider and Episode are joined together in an One to Many relationship.

## Logging

Logs into the console the network requests/responses and database operations with different logs levels. It's instantiated as:
```sh
let log = SwiftyBeaver.self
```
Log level can be:
* Verbose
* Debug
* Info
* Warning
* Error

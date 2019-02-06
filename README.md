# brickhack-mobile-ios

The app for managing attendees for BrickHack.

* **Scan Wristbands:** Attendees wear wristbands embedded with NFC tags. These tags are used to identify key events during BrickHack such as "received dinner" or "entered/left venue".
* **Scan History**: Volunteers are able to quickly see their scan history to correct any errors.
* **Questionnaires:** Volunteers and organizers are able to quickly retreive attendee information whenever needed.
## Project
Since we're using CocoaPods, you must open the project using `.xcworkspace`, not `.xcodeproj`.

## Dependencies

Installing p2/OAuth2:

    $ cd path/to/brickhack-mobile-ios
    $ git clone --recursive https://github.com/p2/OAuth2.git

We're using CocoaPods as the dependency manager.

Installing CocoPods:

`$ sudo gem install cocoapods`

Installing dependencies:

`$ pod install`

Verify Apollo was installed correctly:

`$ pod try Apollo`

## Contribution
For Git, we will be following the
[Git Workflow](https://nvie.com/posts/a-successful-git-branching-model/)
set forth by Vincent Driessen on NVIE.

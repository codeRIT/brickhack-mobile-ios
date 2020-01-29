# brickhack-mobile-ios

[![Maintainability](https://api.codeclimate.com/v1/badges/9c6e5198aa3222ca35bd/maintainability)](https://codeclimate.com/github/codeRIT/brickhack-mobile-ios/maintainability)

The app for managing attendees for BrickHack.

* **Scan Wristbands:** Attendees wear wristbands embedded with NFC tags. These tags are used to identify key events during BrickHack such as "received dinner" or "entered/left venue".
* **Scan History**: Volunteers are able to quickly see their scan history to correct any errors.
* **Questionnaires:** Volunteers and organizers are able to quickly retreive attendee information whenever needed.
## Project
Since we're using CocoaPods, you must open the project using `.xcworkspace`, not `.xcodeproj`.

## Dependencies

We're using CocoaPods as the dependency manager.


### Installing CocoaPods (and related project-level dependencies):

To install CocoaPods (and other dependencies), make sure you have ruby `2.6.3` or greater. The easiest way to do this on macOS is to set a global `rbenv` version as follows:
```
$ brew install rbenv ruby-build
$ rbenv install 2.6.3
$ rbenv global 2.6.3
```

And add rbenv to your `~/.bashrc` or `~/.zshrc`:
```
eval "$(rbenv init -)"
```
Or, for `fish` users, in your `~/.config/fish/config.fish`:
```
source (rbenv init - | source)
```

Finally, run this to install `cocoapods` and its dependenceis. 

```
$ bundle install
```

### Installing code-level dependencies:

`$ pod install`

## Contribution
For Git, we will be following the
[Git Workflow](https://nvie.com/posts/a-successful-git-branching-model/)
set forth by Vincent Driessen on NVIE.

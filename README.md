
# Jump

iOS library for integrating Leap Motion gestures into an app.

[See it in action on ChallengePost!](http://challengepost.com/software/jump)

Depends on [JumpApp](https://github.com/Shrugs/JumpApp) to proxy Leap websocket server over Bonjour-enabled socket to iOS client.

**Has a massive memory leak, please do not use seriously yet.**

## Usage

Include and link against Jump. Also include and import headers where necessary.

Subscribe to the `JumpDelegate` protocol and implement any optional delegate methods you'd like. You probably want the

    - (void)jump:(Jump *)jump gotFrame:(LeapFrame *)frame;

method.

API is vaguely similar to the official Leap Motion ObjC SDK, but with a lot of functionality left out because I don't have access to their C implementation and couldn't compile it.

## Future

I want to turn this into an actual, real-world lib for playing iOS games. I'll need to learn how to memory management first, though...
//
//  Jump.m
//  Jump
//
//  Created by Matt Condon on 8/30/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "Jump.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

@implementation Jump

@synthesize delegate;

- (Jump *)init
{
    self = [super init];
    if (self) {
        NSLog(@"JUMP INIT");
    }
    return self;
}

- (void)jump
{
    netServiceBrowser = [[NSNetServiceBrowser alloc] init];
    [netServiceBrowser setDelegate:self];
    [netServiceBrowser searchForServicesOfType:@"_readysetjump._tcp." inDomain:@"local."];
}

- (void)socket:(GCDAsyncSocket *)sock didReadData:(NSData *)data withTag:(long)tag
{

//	NSString *jsonData = [[NSString alloc] initWithData:data encoding:NSUTF8StringEncoding];

    NSError *error;
    NSMutableDictionary *frameDict = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    if (!error) {

        // make a LeapFrame object
//        NSDate *start = [NSDate date];
        LeapFrame  *frame = [self unmarshallFrameDictionary: frameDict];
//        NSTimeInterval timeInterval = [start timeIntervalSinceNow];
//        NSLog(@"%f", timeInterval);


        if ([delegate respondsToSelector:@selector(jump:gotFrame:)]) {
            [delegate jump:self gotFrame:frame];
        }

        if ([delegate respondsToSelector:@selector(jump:gestureFinished:)]) {
            for (LeapGesture *gesture in frame.gestures) {
                if (gesture.state == LEAP_GESTURE_STATE_STOP) {
                    // we got a stopped gesture, alright!
                    if (!(gesture.type == LEAP_GESTURE_TYPE_CIRCLE)) {
                        gesture.generalDirection = [self getGestureDirection:((LeapSwipeGesture *)gesture).direction];
                    }
                    [delegate jump:self gestureFinished:gesture];
                    break;
                }
            }
        }

    }

//    [delegate jump:self gotFrame:frame];

    // Read the next line of the header
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];

}

- (LeapFrame *)unmarshallFrameDictionary:(NSMutableDictionary *)frameDict
{
    LeapFrame *frame = [[LeapFrame alloc] init];
    frame.id = [frameDict[@"id"] longLongValue];
    frame.timestamp = [frameDict[@"timestamp"] unsignedIntegerValue];
    frame.s = [frameDict[@"s"] floatValue];
    frame.t = [[LeapVector alloc] initWithArray:frameDict[@"t"]];
    if (![frameDict[@"currentFrameRate"] isEqual:[NSNull null]]) {
        frame.currentFrameRate = [frameDict[@"currentFrameRate"] floatValue];
    }
    NSMutableArray *gesturesArray = frameDict[@"gestures"];
    NSMutableArray *gestures = [[NSMutableArray alloc] initWithCapacity:[gesturesArray count]];
    for (NSMutableDictionary *gestureDict in gesturesArray) {
        if ([gestureDict[@"type"] isEqualToString:@"swipe"]) {
            LeapSwipeGesture *gesture = [[LeapSwipeGesture alloc] init];

            gesture.type = LEAP_GESTURE_TYPE_SWIPE;
            gesture.position = [[LeapVector alloc] initWithArray:gestureDict[@"position"]];
            gesture.direction = [[LeapVector alloc] initWithArray:gestureDict[@"direction"]];
            gesture.startPosition = [[LeapVector alloc] initWithArray:gestureDict[@"startPositon"]];
            gesture.speed = [gestureDict[@"speed"] floatValue];
            gesture.frame = frame;
            gesture.id = [gestureDict[@"id"] intValue];
            gesture.duration = [gestureDict[@"duration"] intValue];
            gesture.durationSeconds = gesture.duration/1000.0;
            if (![gestureDict[@"isValid"] isEqual: [NSNull null]]) {
                gesture.isValid = [gestureDict[@"isValid"] boolValue];
            }


            if ([gestureDict[@"state"] isEqualToString:@"start"]) {
                gesture.state = LEAP_GESTURE_STATE_START;
            } else if ([gestureDict[@"state"] isEqualToString:@"update"]) {
                gesture.state = LEAP_GESTURE_STATE_UPDATE;
            } else if ([gestureDict[@"state"] isEqualToString:@"stop"]) {
                gesture.state = LEAP_GESTURE_STATE_STOP;
            } else {
                gesture.state = LEAP_GESTURE_STATE_INVALID;
            }
            [gestures addObject:gesture];
        } else if ([gestureDict[@"type"] isEqualToString:@"circle"]) {
            LeapCircleGesture *gesture = [[LeapCircleGesture alloc] init];

            gesture.type = LEAP_GESTURE_TYPE_CIRCLE;
            gesture.progress = [gestureDict[@"progress"] floatValue];
            gesture.center = [[LeapVector alloc] initWithArray:gestureDict[@"center"]];
            gesture.normal = [[LeapVector alloc] initWithArray:gestureDict[@"normal"]];
            gesture.radius = [gestureDict[@"radius"] floatValue];
            // @TOOD(Shrugs) implement pointable by looking at json
            gesture.frame = frame;
            gesture.id = [gestureDict[@"id"] intValue];
            gesture.duration = [gestureDict[@"duration"] intValue];
            gesture.durationSeconds = gesture.duration/1000.0;
            if (![gestureDict[@"isValid"] isEqual: [NSNull null]]) {
                gesture.isValid = [gestureDict[@"isValid"] boolValue];
            }


            if ([gestureDict[@"state"] isEqualToString:@"start"]) {
                gesture.state = LEAP_GESTURE_STATE_START;
            } else if ([gestureDict[@"state"] isEqualToString:@"update"]) {
                gesture.state = LEAP_GESTURE_STATE_UPDATE;
            } else if ([gestureDict[@"state"] isEqualToString:@"stop"]) {
                gesture.state = LEAP_GESTURE_STATE_STOP;
            } else {
                gesture.state = LEAP_GESTURE_STATE_INVALID;
            }
            [gestures addObject:gesture];
        } else if ([gestureDict[@"type"] isEqualToString:@"screenTap"]) {
            LeapScreenTapGesture *gesture = [[LeapScreenTapGesture alloc] init];

            gesture.type = LEAP_GESTURE_TYPE_SCREEN_TAP;
            gesture.progress = [gestureDict[@"progress"] floatValue];
            gesture.direction = [[LeapVector alloc] initWithArray:gestureDict[@"direction"]];
            gesture.progress = [gestureDict[@"progress"] floatValue];
            // @TOOD(Shrugs) implement pointable by looking at json
            gesture.frame = frame;
            gesture.id = [gestureDict[@"id"] intValue];
            gesture.duration = [gestureDict[@"duration"] intValue];
            gesture.durationSeconds = gesture.duration/1000.0;
            if (![gestureDict[@"isValid"] isEqual: [NSNull null]]) {
                gesture.isValid = [gestureDict[@"isValid"] boolValue];
            }


            if ([gestureDict[@"state"] isEqualToString:@"start"]) {
                gesture.state = LEAP_GESTURE_STATE_START;
            } else if ([gestureDict[@"state"] isEqualToString:@"update"]) {
                gesture.state = LEAP_GESTURE_STATE_UPDATE;
            } else if ([gestureDict[@"state"] isEqualToString:@"stop"]) {
                gesture.state = LEAP_GESTURE_STATE_STOP;
            } else {
                gesture.state = LEAP_GESTURE_STATE_INVALID;
            }
            [gestures addObject:gesture];
        } else if ([gestureDict[@"type"] isEqualToString:@"keyTap"]) {
            LeapKeyTapGesture *gesture = [[LeapKeyTapGesture alloc] init];

            gesture.type = LEAP_GESTURE_TYPE_KEY_TAP;
            gesture.progress = [gestureDict[@"progress"] floatValue];
            gesture.position = [[LeapVector alloc] initWithArray:gestureDict[@"position"]];
            gesture.direction = [[LeapVector alloc] initWithArray:gestureDict[@"direction"]];
            // @TOOD(Shrugs) implement pointable by looking at json
            gesture.frame = frame;
            gesture.id = [gestureDict[@"id"] intValue];
            gesture.duration = [gestureDict[@"duration"] intValue];
            gesture.durationSeconds = gesture.duration/1000.0;
            if (![gestureDict[@"isValid"] isEqual: [NSNull null]]) {
                gesture.isValid = [gestureDict[@"isValid"] boolValue];
            }


            if ([gestureDict[@"state"] isEqualToString:@"start"]) {
                gesture.state = LEAP_GESTURE_STATE_START;
            } else if ([gestureDict[@"state"] isEqualToString:@"update"]) {
                gesture.state = LEAP_GESTURE_STATE_UPDATE;
            } else if ([gestureDict[@"state"] isEqualToString:@"stop"]) {
                gesture.state = LEAP_GESTURE_STATE_STOP;
            } else {
                gesture.state = LEAP_GESTURE_STATE_INVALID;
            }
            [gestures addObject:gesture];
        } else {
            // idfk
        }

    }
    frame.gestures = [NSArray arrayWithArray:gestures];

    NSMutableArray *handsArray = frameDict[@"hands"];
    NSMutableArray *hands = [[NSMutableArray alloc] initWithCapacity:[handsArray count]];
    for (NSMutableDictionary *handDict in handsArray) {
        LeapHand *hand = [[LeapHand alloc] init];
        hand.id = [handDict[@"id"] intValue];
        hand.palmPosition = [[LeapVector alloc] initWithArray:handDict[@"palmPosition"]];
        hand.stabilizedPalmPosition = [[LeapVector alloc] initWithArray:handDict[@"stabilizedPalmPosition"]];
        hand.palmVelocity = [[LeapVector alloc] initWithArray:handDict[@"palmVelocity"]];
        hand.palmNormal = [[LeapVector alloc] initWithArray:handDict[@"palmNormal"]];
        hand.direction = [[LeapVector alloc] initWithArray:handDict[@"direction"]];
        hand.frame = frame;
        hand.timeVisible = [handDict[@"timeVisible"] floatValue];
        hand.s = [handDict[@"s"] floatValue];
        hand.t = [[LeapVector alloc] initWithArray:handDict[@"t"]];

        if (![handDict[@"confidence"] isEqual:[NSNull null]]) {
            hand.confidence = [handDict[@"confidence"] floatValue];
        }

        if (![handDict[@"isValid"] isEqual: [NSNull null]]) {
            hand.isValid = [handDict[@"isValid"] boolValue];
        }
        [hands addObject:hand];

    }
    frame.hands = [NSArray arrayWithArray:hands];

    NSMutableArray *pointablesArray = frameDict[@"pointables"];
    NSMutableArray *pointables = [[NSMutableArray alloc] initWithCapacity:[pointablesArray count]];
    for (NSMutableDictionary *pDict in pointablesArray) {
        LeapPointable *p = [[LeapPointable alloc] init];
        p.frame = frame;
        p.direction = [[LeapVector alloc] initWithArray:pDict[@"direction"]];
        p.id = [pDict[@"id"] intValue];
        p.length = [pDict[@"length"] floatValue];
        p.width = [pDict[@"width"] floatValue];
        p.stabilizedTouchPosition = [[LeapVector alloc] initWithArray:pDict[@"stabilizedTipPosition"]];
        p.timeVisible = [pDict[@"timeVisible"] floatValue];
        p.tipPosition = [[LeapVector alloc] initWithArray:pDict[@"tipPosition"]];
        p.tipVelocity = [[LeapVector alloc] initWithArray:pDict[@"tipVelocity"]];
        p.isTool = [pDict[@"tool"] boolValue];
        p.touchDistance = [pDict[@"touchDistance"] floatValue];

        NSString *tz = pDict[@"touchZone"];
        if ([tz isEqualToString:@"none"]) {
            p.touchZone = LEAP_POINTABLE_ZONE_NONE;
        } else if ([tz isEqualToString:@"hovering"]) {
            p.touchZone = LEAP_POINTABLE_ZONE_HOVERING;
        } else if ([tz isEqualToString:@"touching"]) {
            p.touchZone = LEAP_POINTABLE_ZONE_TOUCHING;
        } else {
            p.touchZone = LEAP_POINTABLE_ZONE_NONE;
        }

        [pointables addObject:p];

    }
    frame.pointables = [NSArray arrayWithArray:pointables];

    frame.interactionBox = [[LeapInteractionBox alloc] init];
    frame.interactionBox.center = [[LeapVector alloc] initWithArray:frameDict[@"interactionBox"][@"center"]];
    frame.interactionBox.size = [[LeapVector alloc] initWithArray:frameDict[@"interactionBox"][@"size"]];

    return frame;
}

- (JumpGestureDirection)getGestureDirection:(LeapVector *)direction
{

    float fx = direction.x*10;
    float fy = direction.y*10;
    float fz = direction.z*10;

    const int ax = (int)fabsf(fx);
    const int ay = (int)fabsf(fy);
    const int az = (int)fabsf(fz);

    int largest = (int)MAX(ax, MAX(ay, az));

    if (largest == ax) {
        return fx > 0 ? JumpGestureDirectionRight : JumpGestureDirectionLeft;
    } else if (largest == ay) {
        return fy > 0 ? JumpGestureDirectionUp : JumpGestureDirectionDown;
    } else if (largest == az) {
        return fz > 0 ? JumpGestureDirectionIn : JumpGestureDirectionOut;
    } else {
        return JumpGestureDirectionNone;
    }

}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didNotSearch:(NSDictionary *)errorDict
{
    NSLog(@"DidNotSearch: %@", errorDict);
}


- (void)netServiceBrowser:(NSNetServiceBrowser *)aNetServiceBrowser didFindDomain:(NSString *)domainString moreComing:(BOOL)moreComing
{
    NSLog(@"FOUND DOMAIN %@", domainString);
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didFindService:(NSNetService *)netService moreComing:(BOOL)moreComing
{
	NSLog(@"DidFindService: %@", [netService name]);

	// Connect to the first service we find
	if (serverService == nil)
	{
		NSLog(@"Resolving...");

		serverService = netService;

		[serverService setDelegate:self];
		[serverService resolveWithTimeout:5.0];
        [serverService scheduleInRunLoop:[NSRunLoop currentRunLoop] forMode:NSDefaultRunLoopMode];
	}
}

- (void)netServiceBrowserWillSearch:(NSNetServiceBrowser *)browser
{
    NSLog(@"Searching...");
}

- (void)netServiceBrowser:(NSNetServiceBrowser *)sender didRemoveService:(NSNetService *)netService moreComing:(BOOL)moreComing
{
	NSLog(@"DidRemoveService: %@", [netService name]);
}

- (void)netServiceBrowserDidStopSearch:(NSNetServiceBrowser *)sender
{
	NSLog(@"DidStopSearch");
}

- (void)netService:(NSNetService *)sender didNotResolve:(NSDictionary *)errorDict
{
	NSLog(@"DidNotResolve");
}

- (void)netServiceDidResolveAddress:(NSNetService *)sender
{
	NSLog(@"DidResolve: %@", [sender addresses]);

	if (serverAddresses == nil)
	{
		serverAddresses = [[sender addresses] mutableCopy];
	}

	if (asyncSocket == nil)
	{
		asyncSocket = [[GCDAsyncSocket alloc] initWithDelegate:self delegateQueue:dispatch_get_main_queue()];

		[self connectToNextAddress];
	}
}

- (void)connectToNextAddress
{
	BOOL done = NO;

	while (!done && ([serverAddresses count] > 0))
	{
		NSData *addr;

		// Note: The serverAddresses array probably contains both IPv4 and IPv6 addresses.
		//
		// If your server is also using GCDAsyncSocket then you don't have to worry about it,
		// as the socket automatically handles both protocols for you transparently.

		if (YES) // Iterate forwards
		{
			addr = [serverAddresses objectAtIndex:0];
			[serverAddresses removeObjectAtIndex:0];
		}
		else // Iterate backwards
		{
			addr = [serverAddresses lastObject];
			[serverAddresses removeLastObject];
		}

		NSLog(@"Attempting connection to %@", addr);

		NSError *err = nil;
		if ([asyncSocket connectToAddress:addr error:&err])
		{
            NSLog(@"Connected to: %@", [GCDAsyncSocket hostFromAddress:addr]);
			done = YES;
		}
		else
		{
			NSLog(@"Unable to connect: %@", err);
		}

	}

	if (!done)
	{
		NSLog(@"Unable to connect to any resolved address");
	}
}

- (void)socket:(GCDAsyncSocket *)sock didConnectToHost:(NSString *)host port:(UInt16)port
{
	NSLog(@"Socket:DidConnectToHost: %@ Port: %hu", host, port);
	connected = YES;

	[asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];

}

- (void)socketDidDisconnect:(GCDAsyncSocket *)sock withError:(NSError *)err
{
	NSLog(@"SocketDidDisconnect:WithError: %@", err);

    

	if (!connected)
	{
		[self connectToNextAddress];
	}
}

@end

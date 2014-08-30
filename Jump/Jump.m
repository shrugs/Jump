//
//  Jump.m
//  Jump
//
//  Created by Matt Condon on 8/30/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "Jump.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>

typedef enum jumpGestureDirection {
    JumpGestureDirectionUp,
    JumpGestureDirectionLeft,
    JumpGestureDirectionRight,
    JumpGestureDirectionDown,
    JumpGestureDirectionOut,
    JumpGestureDirectionIn
} JumpGestureDirection;


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

        NSMutableArray *gesturesArray = frameDict[@"gestures"];
        if ([gesturesArray count] > 0) {
            // we have a gesture
            for (NSMutableDictionary *gesture in gesturesArray) {
                if ([gesture[@"state"] isEqualToString:@"stop"]) {
                    // we got a stopped gesture, alright!
                    if ([gesture[@"type"] isEqualToString:@"swipe"] ||
                        [gesture[@"type"] isEqualToString:@"keyTap"] ||
                        [gesture[@"type"] isEqualToString:@"screenTap"]) {
                            gesture[@"gestureDirection"] = [NSNumber numberWithInt:[self getGestureDirection: gesture[@"direction"]]];
                        }

                    if ([delegate respondsToSelector:@selector(jump:gotGesture:)]) {
                        [delegate jump:self gotGesture:gesture];
                    }

                }
            }
        }
        // make a LeapFrame object
//        LeapFrame *frame = [[LeapFrame alloc] init];
//        frame.currentFramesPerSecond = [frameDict[@"currentFrameRate"] floatValue];
//        NSMutableArray *gesturesArray = frameDict[@"gestures"];
////        for () {
////
////        }
//        NSMutableArray *handsArray = frameDict[@"hands"];
//        frame.id = [frameDict[@"id"] longLongValue];
//        frame.interactionBox = [[LeapInteractionBox alloc] init];
//        frame.interactionBox.center = [[LeapVector alloc] initWithArray:frameDict[@"interactionBox"][@"center"]];
////        frame.interactionBox.size = [[LeapVector alloc] initWithArray:frameDict[@"interactionBox"][@"size"]];
//        NSMutableArray *pointablesArray = frameDict[@"pointables"];
//        frame.r = [[LeapMatrix alloc] initWithR:frameDict[@"r"] andT:frameDict[@"t"]];
//        frame.s = [NSNumber numberWithFloat:[frameDict[@"s"] floatValue]];
//        frame.t = [[LeapVector alloc] initWithArray:frameDict[@"r"]];
//        frame.timestamp = [frameDict[@"timestamp"] unsignedIntegerValue];

        [delegate jump:self gotFrame:frameDict];
    }

//    [delegate jump:self gotFrame:frame];

    // Read the next line of the header
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];

}

- (JumpGestureDirection)getGestureDirection:(NSMutableArray *)gestureDirection
{

    if ([gestureDirection count] < 3) {
        return JumpGestureDirectionLeft;
    }

    float x = [[gestureDirection objectAtIndex:0] floatValue]*10;
    float y = [[gestureDirection objectAtIndex:1] floatValue]*10;
    float z = [[gestureDirection objectAtIndex:2] floatValue]*10;

    const int ax = (int)fabsf(x);
    const int ay = (int)fabsf(y);
    const int az = (int)fabsf(z);

    int largest = (int)MAX(ax, MAX(ay, az));

    NSLog(@"%@", gestureDirection);
    NSLog(@"%i, %i, %i", ax, ay, az);

    if (largest == ax) {
        return x > 0 ? JumpGestureDirectionRight : JumpGestureDirectionLeft;
    } else if (largest == ay) {
        return y > 0 ? JumpGestureDirectionUp : JumpGestureDirectionDown;
    } else if (largest == az) {
        return z > 0 ? JumpGestureDirectionIn : JumpGestureDirectionOut;
    } else {
        return JumpGestureDirectionLeft;
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
    NSLog(@"DID START SEARCH YAY");
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

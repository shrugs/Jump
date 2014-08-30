//
//  Jump.m
//  Jump
//
//  Created by Matt Condon on 8/30/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "Jump.h"
#import <CocoaAsyncSocket/GCDAsyncSocket.h>
#import "LeapObjC/LeapObjectiveC.h"

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
    NSMutableDictionary *frame = [NSJSONSerialization JSONObjectWithData:data options:NSJSONReadingMutableContainers error:&error];

    if (!error) {

//        NSMutableArray *gesturesArray = frameDict[@"gestures"];
//        if ([gesturesArray count] > 0) {
//            // we have a gesture
//            for (NSMutableDictionary *gesture in gesturesArray) {
//                if ([gesture[@"state"] isEqualToString:@"stop"]) {
//                    // we got a stopped gesture, alright!
//                    [self getGestureDirection: gesture[@"direction"]];
//                }
//            }
//        }
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
//        frame.interactionBox.size = [[LeapVector alloc] initWithArray:frameDict[@"interactionBox"][@"size"]];
//        NSMutableArray *pointablesArray = frameDict[@"pointables"];
//        frame.r = [[LeapVector alloc] initWithArray:frameDict[@"r"]];
//        frame.s = [NSNumber numberWithFloat:[frameDict[@"s"] floatValue]];
//        frame.t = [[LeapVector alloc] initWithArray:frameDict[@"r"]];
//        frame.timestamp = [frameDict[@"timestamp"] unsignedIntegerValue];

        [delegate jump:self gotFrame:frame];
    }

//    [delegate jump:self gotFrame:frame];

    // Read the next line of the header
    [asyncSocket readDataToData:[GCDAsyncSocket CRLFData] withTimeout:-1.0 tag:0];

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

//
//  Jump.h
//  Jump
//
//  Created by Matt Condon on 8/30/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import <Foundation/Foundation.h>

#import "Leap.h"


@class GCDAsyncSocket, Jump;

@protocol JumpDelegate <NSObject>

@optional
- (void)jump:(Jump *)jump gotFrame:(LeapFrame *)frame;
- (void)jump:(Jump *)jump gestureFinished:(LeapGesture *)gesture;

@end

@interface Jump : NSObject <NSNetServiceDelegate, NSNetServiceBrowserDelegate>
{
    NSNetServiceBrowser *netServiceBrowser;
	NSNetService *serverService;
	NSMutableArray *serverAddresses;
	GCDAsyncSocket *asyncSocket;
	BOOL connected;
}

@property (nonatomic, assign) id <JumpDelegate> delegate;

- (void)jump;

@end

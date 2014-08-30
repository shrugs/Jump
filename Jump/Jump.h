//
//  Jump.h
//  Jump
//
//  Created by Matt Condon on 8/30/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import <Foundation/Foundation.h>

@class GCDAsyncSocket, Jump;

@protocol JumpDelegate <NSObject>

- (void)jump:(Jump *)jump gotFrame:(NSMutableDictionary *)frame;

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

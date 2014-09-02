//
//  Leap.m
//  Jump
//
//  Created by Matt Condon on 8/31/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import "Leap.h"

@implementation LeapVector

@synthesize x=_x, y=_y, z=_z;

- (id)initWithX:(float)x y:(float)y z:(float)z
{
    self = [super init];
    if (self) {
        _x = x;
        _y = y;
        _z = z;
    }
    return self;
}
- (id)initWithVector:(const LeapVector *)vector
{
    self = [super init];
    if (self) {
        _x = [vector x];
        _y = [vector y];
        _z = [vector z];
    }
    return self;
}

- (id)initWithArray:(const NSMutableArray *)array
{
    self = [super init];
    if (self) {
        if ([[array objectAtIndex:0] isEqual:[NSNull null]]) {

        } else {
            _x = [[array objectAtIndex:0] floatValue];
            _y = [[array objectAtIndex:1] floatValue];
            _z = [[array objectAtIndex:2] floatValue];
        }
    }
    return self;
}

- (NSString *)description
{
    return [NSString stringWithFormat:@"(%f, %f, %f)", _x, _y, _z];
}


- (float)distanceTo:(const LeapVector *)vector
{
    return sqrt((_x - [vector x]) * (_x - [vector x]) +
                (_y - [vector y]) * (_y - [vector y]) +
                (_z - [vector z]) * (_z - [vector z]));
}


- (float)pitch
{
    return atan2(_y, -_z);
}

- (float)roll
{
    return atan2(_x, -_y);
}

- (float)yaw
{
    return atan2(_x, -_z);
}



- (LeapVector *)plus:(const LeapVector *)vector
{
    return [[LeapVector alloc] initWithX:(_x + [vector x]) y:(_y + [vector y]) z:(_z + [vector z])];
}

- (LeapVector *)minus:(const LeapVector *)vector
{
    return [[LeapVector alloc] initWithX:(_x - [vector x]) y:(_y - [vector y]) z:(_z - [vector z])];
}

- (LeapVector *)negate
{
    return [[LeapVector alloc] initWithX:(-_x) y:(-_y) z:(-_z)];
}

- (LeapVector *)times:(float)scalar
{
    return [[LeapVector alloc] initWithX:(scalar*_x) y:(scalar*_y) z:(scalar*_z)];
}

- (LeapVector *)divide:(float)scalar
{
    return [[LeapVector alloc] initWithX:(_x/scalar) y:(_y/scalar) z:(_z/scalar)];
}

- (BOOL)equals:(const LeapVector *)vector
{
    return _x == [vector x] && _y == [vector y] && _z == [vector z];
}

- (float)dot:(const LeapVector *)vector
{
    return _x * [vector x] + _y * [vector y] + _z * [vector z];
}

- (LeapVector *)cross:(const LeapVector *)vector
{
    LeapVector *me = [[LeapVector alloc] initWithVector:self];
    LeapVector *other = [[LeapVector alloc] initWithVector:vector];
    
    return [[LeapVector alloc] initWithX:[me y]*[other z] - [me z]*[other y]
                                       y:[me z]*[other x] - [me x]*[other z]
                                       z:[me x]*[other y] - [me y]*[other x]];
}


+ (LeapVector *)zero
{
    return [[LeapVector alloc] initWithX:0 y:0 z:0];
}

+ (LeapVector *)xAxis
{
    return [[LeapVector alloc] initWithX:1.0 y:0 z:0];
}

+ (LeapVector *)yAxis
{
    return [[LeapVector alloc] initWithX:0 y:1.0 z:0];
}

+ (LeapVector *)zAxis
{
    return [[LeapVector alloc] initWithX:0 y:0 z:1.0];
}

+ (LeapVector *)left
{
    return [[LeapVector xAxis] negate];
}

+ (LeapVector *)right
{
    return [LeapVector xAxis];
}

+ (LeapVector *)down
{
    return [[LeapVector yAxis] negate];
}

+ (LeapVector *)up
{
    return [LeapVector yAxis];
}

+ (LeapVector *)forward
{
    return [LeapVector zAxis];
}

+ (LeapVector *)backward
{
    return [[LeapVector zAxis] negate];
}

@end



@implementation LeapPointable

@synthesize frame=_frame, hand=_hand;


- (id)initWithPointable:(void *)pointable frame:(LeapFrame *)frame hand:(LeapHand *)hand
{
    self = [super init];
    if (self) {
        _frame = frame;
        _hand = hand;
    }
    return self;
}

+ (LeapPointable *)invalid
{
    LeapPointable *iv = [[LeapPointable alloc] init];
    iv.isValid = NO;
    return iv;
}

@end

@implementation LeapHand

@synthesize frame=_frame;

- (id)initWithHand:(void *)hand frame:(LeapFrame *)frame
{
    self = [super init];
    if (self) {
        _frame = frame;
    }
    return self;
}

- (NSString *)description
{
    if (![self isValid]) {
        return @"Invalid Hand";
    }
    return [NSString stringWithFormat:@"Hand Id:%d", [self id]];
}

@end

@implementation LeapInteractionBox

@end

@implementation LeapGesture

@end

@implementation LeapSwipeGesture

@end

@implementation LeapCircleGesture

@end

@implementation LeapScreenTapGesture

@end

@implementation LeapKeyTapGesture

@end

@implementation LeapFrame

@end

























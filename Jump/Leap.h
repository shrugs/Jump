//
//  Leap.h
//  Jump
//
//  Created by Matt Condon on 8/31/14.
//  Copyright (c) 2014 Shrugs. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface LeapVector : NSObject

//PROPS
@property (nonatomic, assign) float x;
@property (nonatomic, assign) float y;
@property (nonatomic, assign) float z;
@property (nonatomic, assign) float magnitude;
@property (nonatomic, assign) float pitch;
@property (nonatomic, assign) float roll;
@property (nonatomic, assign) float yaw;

//INIT
- (id)initWithX:(float)x y:(float)y z:(float)z;
- (id)initWithVector:(const LeapVector *)vector;
- (id)initWithArray:(const NSMutableArray *)array;

// MATH
- (float)distanceTo:(const LeapVector *)vector;
- (LeapVector *)plus:(const LeapVector *)vector;
- (LeapVector *)minus:(const LeapVector *)vector;
- (LeapVector *)negate;
- (LeapVector *)times:(float)scalar;
- (LeapVector *)divide:(float)scalar;
- (BOOL)equals:(const LeapVector *)vector;
- (float)dot:(const LeapVector *)vector;
- (LeapVector *)cross:(const LeapVector *)vector;

//CLASS
+ (LeapVector *)xAxis;
+ (LeapVector *)yAxis;
+ (LeapVector *)zAxis;

+ (LeapVector *)left;
+ (LeapVector *)right;
+ (LeapVector *)up;
+ (LeapVector *)down;
+ (LeapVector *)forward;
+ (LeapVector *)backward;


@end


/**
 * The supported types of gestures.
 * @available Since 1.0
 */
typedef enum LeapGestureType {
    LEAP_GESTURE_TYPE_INVALID = -1, /**< An invalid type. */
    LEAP_GESTURE_TYPE_SWIPE = 1, /**< A straight line movement by the hand with fingers extended. */
    LEAP_GESTURE_TYPE_CIRCLE = 4, /**< A circular movement by a finger. */
    LEAP_GESTURE_TYPE_SCREEN_TAP = 5, /**< A forward tapping movement by a finger. */
    LEAP_GESTURE_TYPE_KEY_TAP = 6, /**< A downward tapping movement by a finger. */
} LeapGestureType;

/**
 * The possible gesture states.
 */
typedef enum LeapGestureState {
    LEAP_GESTURE_STATE_INVALID = -1, /**< An invalid state */
    LEAP_GESTURE_STATE_START = 1, /**< The gesture is starting. Just enough has happened to recognize it. */
    LEAP_GESTURE_STATE_UPDATE = 2, /**< The gesture is in progress. (Note: not all gestures have updates). */
    LEAP_GESTURE_STATE_STOP = 3, /**< The gesture has completed or stopped. */
} LeapGestureState;

typedef enum jumpGestureDirection {
    JumpGestureDirectionNone,
    JumpGestureDirectionUp,
    JumpGestureDirectionLeft,
    JumpGestureDirectionRight,
    JumpGestureDirectionDown,
    JumpGestureDirectionOut,
    JumpGestureDirectionIn
} JumpGestureDirection;


typedef enum LeapFingerType {
    LEAP_FINGER_TYPE_THUMB  = 0, /**< The thumb */
    LEAP_FINGER_TYPE_INDEX  = 1, /**< The index or forefinger */
    LEAP_FINGER_TYPE_MIDDLE = 2, /**< The middle finger */
    LEAP_FINGER_TYPE_RING   = 3, /**< The ring finger */
    LEAP_FINGER_TYPE_PINKY  = 4  /**< The pinky or little finger */
} LeapFingerType;

typedef enum LeapPointableZone {
    LEAP_POINTABLE_ZONE_NONE       = 0,  /**< The Pointable object is too far from
                                          the plane to be considered hovering or touching.*/
    LEAP_POINTABLE_ZONE_HOVERING   = 1,   /**< The Pointable object is close to, but
                                           not touching the plane.*/
    LEAP_POINTABLE_ZONE_TOUCHING   = 2,  /**< The Pointable has penetrated the plane. */
} LeapPointableZone;



@class LeapFrame;
@class LeapHand;
@class LeapInteractionBox;

@interface LeapPointable : NSObject

@property (nonatomic) int32_t id;
@property (nonatomic, weak) LeapFrame *frame;
@property (nonatomic, weak) LeapHand *hand;
@property (nonatomic, weak) LeapInteractionBox *interactionBox;
@property (nonatomic, strong) LeapVector *tipPosition;
@property (nonatomic, strong) LeapVector *tipVelocity;
@property (nonatomic, strong) LeapVector *direction;
@property (nonatomic, assign) float width;
@property (nonatomic, assign) float length;
@property (nonatomic, assign) BOOL isFinger;
@property (nonatomic, assign) BOOL isTool;
@property (nonatomic, assign) BOOL isExtended;
@property (nonatomic, assign) BOOL isValid;
@property (nonatomic) LeapPointableZone touchZone;
@property (nonatomic) float touchDistance;
@property (nonatomic, retain) LeapVector *stabilizedTouchPosition;
@property (nonatomic) float timeVisible;

//CLASS
+ (LeapPointable *)invalid;

@end


@interface LeapHand : NSObject

@property (nonatomic) int32_t id;
@property (nonatomic, retain) NSArray *pointables;
@property (nonatomic, retain) LeapVector *palmPosition;
@property (nonatomic, retain) LeapVector *stabilizedPalmPosition;
@property (nonatomic, retain) LeapVector *palmVelocity;
@property (nonatomic, retain) LeapVector *palmNormal;
@property (nonatomic, retain) LeapVector *direction;
@property (nonatomic) BOOL isValid;
@property (nonatomic, weak) LeapFrame *frame;
@property (nonatomic) float timeVisible;
@property (nonatomic) float confidence;
@property (nonatomic) BOOL isLeft;
@property (nonatomic) BOOL isRight;
@property (nonatomic, assign) float palmWidth;
@property (nonatomic) float s;
@property (nonatomic, retain) LeapVector *t;

@end


@interface LeapInteractionBox : NSObject

@property (nonatomic, retain) LeapVector *center;
@property (nonatomic, retain) LeapVector *size;
@property (nonatomic) BOOL isValid;

//- (LeapVector *)normalizePoint:(const LeapVector *)position clamp:(BOOL)clamp;
//- (LeapVector *)denormalizePoint:(const LeapVector *)position;

@end

@interface LeapGesture : NSObject

@property (nonatomic, weak) LeapFrame *frame;
@property (nonatomic, strong) NSArray *hands;
@property (nonatomic, strong) NSArray *pointables;
@property (nonatomic) LeapGestureType type;
@property (nonatomic) LeapGestureState state;
@property (nonatomic) int32_t id;
@property (nonatomic) int64_t duration;
@property (nonatomic) float durationSeconds;
@property (nonatomic) BOOL isValid;
@property (nonatomic) JumpGestureDirection generalDirection;

@end


@interface LeapSwipeGesture : LeapGesture

@property (nonatomic, retain) LeapVector *position;
@property (nonatomic, retain) LeapVector *startPosition;
@property (nonatomic, retain) LeapVector *direction;
@property (nonatomic) float speed;

@end

@interface LeapCircleGesture : LeapGesture

@property (nonatomic) float progress;
@property (nonatomic, retain) LeapVector *center;
@property (nonatomic, retain) LeapVector *normal;
@property (nonatomic) float radius;
@property (nonatomic, retain) LeapPointable *pointable;

@end

@interface LeapScreenTapGesture : LeapGesture

@property (nonatomic, retain) LeapVector *position;
@property (nonatomic, retain) LeapVector *direction;
@property (nonatomic) float progress;
@property (nonatomic, retain) LeapPointable *pointable;

@end

@interface LeapKeyTapGesture : LeapGesture

@property (nonatomic, retain) LeapVector *position;
@property (nonatomic, retain) LeapVector *direction;
@property (nonatomic) float progress;
@property (nonatomic, retain) LeapPointable *pointable;

@end




@interface LeapFrame : NSObject

@property (nonatomic, retain) NSArray *hands;
@property (nonatomic, retain) NSArray *pointables;
@property (nonatomic, retain) NSArray *gestures;
@property (nonatomic, retain) LeapInteractionBox *interactionBox;
@property (nonatomic) int64_t id;
@property (nonatomic) float currentFrameRate;
@property (nonatomic) int64_t timestamp;
@property (nonatomic) BOOL isValid;
@property (nonatomic) float s;
@property (nonatomic, retain) LeapVector *t;

@end










































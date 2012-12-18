#import <Foundation/Foundation.h>

typedef enum {
    GEventType_CHECKPOINT,
    GEventType_PAUSE,
    GEventType_UNPAUSE,
    GEventType_QUIT,
    GEventType_LEVELEND,
    GEventType_UIANIM_TICK,
    GEventType_GAME_TICK,
    GEventType_LOAD_LEVELEND_MENU,
    GEventType_COLLECT_BONE
} GEventType;

@interface GEvent : NSObject
    @property(readwrite,assign) GEventType type;
    @property(readwrite,assign) NSMutableDictionary* data;
    +(GEvent*)init_type:(GEventType)t;
    -(GEvent*)add_key:(NSString*)k value:(id)v;
@end

@protocol GEventListener <NSObject>
    @required
    -(void)dispatch_event:(GEvent*)e;
@end

@interface GEventDispatcher : NSObject
    +(void)add_listener:(id<GEventListener>)tar;
    +(void)remove_all_listeners;
    +(void)remove_listener:(id<GEventListener>)tar;
    +(void)push_event:(GEvent*)e;
    +(void)dispatch_events;
@end

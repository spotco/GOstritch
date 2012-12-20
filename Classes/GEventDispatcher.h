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
    GEventType_COLLECT_BONE,
    
    GEventType_MENU_TICK,
    GEventType_MENU_TOUCHDOWN,
    GEventType_MENU_TOUCHMOVE,
    GEventType_MENU_TOUCHUP,
    GEventType_MENU_CANCELDRAG,
    GEventType_MENU_PLAY_AUTOLEVEL_MODE
} GEventType;

@interface GEvent : NSObject
    @property(readwrite,assign) GEventType type;
    @property(readwrite,assign) NSMutableDictionary* data;
    @property(readwrite,assign) CGPoint pt;
    @property(readwrite,assign) int i1,i2;
    +(GEvent*)init_type:(GEventType)t;
    -(GEvent*)add_key:(NSString*)k value:(id)v;
    -(GEvent*)add_pt:(CGPoint)tpt;
-(GEvent*)add_i1:(int)ti1 i2:(int)ti2;
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

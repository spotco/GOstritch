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
    GEventType_PLAYER_DIE,
    GEventType_GAMEOVER,
    GEventType_PLAYAGAIN_AUTOLEVEL,
    
    GEventType_BOSS1_ACTIVATE,
    GEventType_BOSS1_TICK,
    GEventType_BOSS1_DEFEATED,
    
    GEventType_MENU_TICK,
    GEventType_MENU_TOUCHDOWN,
    GEventType_MENU_TOUCHMOVE,
    GEventType_MENU_TOUCHUP,
    GEventType_MENU_CANCELDRAG,
    GEventType_MENU_PLAY_AUTOLEVEL_MODE,
    GEventType_MENU_GOTO_PAGE,
    GEventType_CHANGE_CURRENT_DOG
} GEventType;

@interface GEvent : NSObject
    @property(readwrite,assign) GEventType type;
    @property(readwrite,assign) NSMutableDictionary* data;
    @property(readwrite,assign) CGPoint pt;
    @property(readwrite,assign) int i1,i2;
    @property(readwrite,assign) float f1,f2;
    +(GEvent*)init_type:(GEventType)t;
    -(GEvent*)add_key:(NSString*)k value:(id)v;
    -(GEvent*)add_pt:(CGPoint)tpt;
    -(GEvent*)add_i1:(int)ti1 i2:(int)ti2;
    -(GEvent*)add_f1:(float)tf1 f2:(float)tf2;
@end

@protocol GEventListener <NSObject>
    @required
    -(void)dispatch_event:(GEvent*)e;
@end

@interface GEventDispatcher : NSObject
    +(void)lazy_alloc;

    +(void)add_listener:(id<GEventListener>)tar;
    +(void)remove_all_listeners;
    +(void)remove_listener:(id<GEventListener>)tar;
    +(void)push_event:(GEvent*)e;
    +(void)push_unique_event:(GEvent*)e;
    +(void)dispatch_events;
@end

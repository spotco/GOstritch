#import "GEventDispatcher.h"

@implementation GEventDispatcher

static NSMutableArray* listeners;
static NSMutableArray* event_queue;

+(void)lazy_alloc {
    if (!listeners) {
        listeners = [[NSMutableArray alloc] init];
    }
    if (!event_queue) {
        event_queue = [[NSMutableArray alloc] init];
    }
}

+(void)add_listener:(id<GEventListener>)tar {
    [GEventDispatcher lazy_alloc];
    [listeners addObject:tar];
}

+(void)remove_all_listeners {
    [GEventDispatcher lazy_alloc];
    [listeners removeAllObjects];
}

+(void)remove_listener:(id<GEventListener>)tar {
    [GEventDispatcher lazy_alloc];
    [listeners removeObject:tar];
}

+(void)push_event:(GEvent*)e {
    [GEventDispatcher lazy_alloc];
    [event_queue addObject:e];
}

+(void)dispatch_events {
    [GEventDispatcher lazy_alloc];
    if ([event_queue count]==0){return;}
    
    for(int ei = 0; ei < [event_queue count]; ei++) {
        GEvent* e = [event_queue objectAtIndex:ei];
        
        for(int li = 0; li < [listeners count]; li++) {
            id<GEventListener> l = [listeners objectAtIndex:li];
            [l dispatch_event:e];
        }
        
        if (e.data) {
            [e.data release];
            e.data = NULL;
        }
        [e release];
    }
    
    [event_queue removeAllObjects];
}
@end

@implementation GEvent
    @synthesize type;
    @synthesize data;
    @synthesize pt;

+(GEvent*)init_type:(GEventType)t {
    GEvent *e = [[GEvent alloc] init];
    e.type = t;
    return e;
}

-(GEvent*)add_key:(NSString*)k value:(id)v {
    if (!data) {
        data = [[NSMutableDictionary alloc] init];
    }
    [data setObject:v forKey:k];
    return self;
}

-(GEvent*)add_pt:(CGPoint)tpt {
    pt = tpt;
    return self;
}

@end

#import "UIAnim.h"

@implementation UIAnim

@synthesize anim_complete;

-(void)anim_finished {
    [self removeAllChildrenWithCleanup:YES];
    [GEventDispatcher remove_listener:self];
    [Common run_callback:anim_complete];
}

-(void)update {
    
}

-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_UIANIM_TICK) {
        [self update];
    }
}

@end

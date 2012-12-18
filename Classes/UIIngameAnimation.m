#import "UIIngameAnimation.h"

@implementation UIIngameAnimation
@synthesize ct;
-(void)update {}
-(void)dispatch_event:(GEvent *)e {
    if (e.type == GEventType_GAME_TICK) {
        [self update];
    }
}

@end

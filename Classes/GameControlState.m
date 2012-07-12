#import "GameControlState.h"

@implementation GameControlState

@synthesize last_touch;
@synthesize touch_timer,last_touch_time;
@synthesize is_touch_down;
@synthesize queue_jump,queue_roll;

- (id)init {
    self = [super init];
    if (self) {
        is_touch_down = NO;
    }
    return self;
}

-(void)start_touch:(CGPoint)pt {
    last_touch = pt;
    last_touch_time = touch_timer;
    is_touch_down = YES;
}

-(void)end_touch {
    is_touch_down = NO;
}

-(void)update {
    touch_timer++;
}

@end

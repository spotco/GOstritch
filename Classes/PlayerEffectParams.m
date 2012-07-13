#import "PlayerEffectParams.h"



@implementation PlayerEffectParams

@synthesize cur_min_speed,cur_gravity,cur_limit_speed;
@synthesize time_left;


+(PlayerEffectParams*)init_copy:(PlayerEffectParams*)p {
    return [PlayerEffectParams init_with_gravity:p.cur_gravity limitvel:p.cur_limit_speed minvel:p.cur_min_speed time:p.time_left];
}

+(PlayerEffectParams*)init_with_gravity:(float)gravity 
                               limitvel:(float)limitvel 
                                 minvel:(float)minvel 
                                   time:(int)time{
    
    PlayerEffectParams *p = [[PlayerEffectParams alloc] init];
    
    p.cur_gravity = gravity;
    p.cur_limit_speed = limitvel;
    p.cur_min_speed = minvel;
    p.time_left = time;
    
    return p;
}


-(BOOL)decrement_timer {
    if (time_left > 0) {
        time_left--;
        return YES;
    }
    return NO;
}

@end

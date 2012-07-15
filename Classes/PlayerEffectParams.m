#import "PlayerEffectParams.h"

@implementation PlayerEffectParams

@synthesize cur_min_speed,cur_gravity,cur_limit_speed,cur_accel_to_min,cur_airjump_count,time_left;


+(PlayerEffectParams*)init_copy:(PlayerEffectParams*)p {
    PlayerEffectParams *n = [[PlayerEffectParams alloc] init];
    n.cur_accel_to_min = p.cur_accel_to_min;
    n.cur_gravity = p.cur_gravity;
    n.cur_limit_speed = p.cur_limit_speed;
    n.cur_min_speed = p.cur_min_speed;
    n.cur_airjump_count = p.cur_airjump_count;
    return n;
}


-(BOOL)decrement_timer {
    if (time_left > 0) {
        time_left--;
        return YES;
    }
    return NO;
}

-(void)add_airjump_count {
    cur_airjump_count = 1;
}

-(void)decr_airjump_count {
    if (cur_airjump_count > 0) {
        cur_airjump_count--;
    }
}

-(void)update {}
-(NSString*)info {
    return [NSString stringWithFormat:@"DefaultEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}

@end

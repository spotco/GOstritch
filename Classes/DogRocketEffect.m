#import "DogRocketEffect.h"

@implementation DogRocketEffect

+(DogRocketEffect*)init_from:(PlayerEffectParams*)base {
    DogRocketEffect *n = [[DogRocketEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = 200;
    n.cur_airjump_count = 0;
    n.cur_min_speed = 20;
    n.cur_gravity = 0;
    return n;
}

-(void)update:(Player *)p {
    p.vy *= 0.9;
    if (p.vx < cur_min_speed) {
        p.vx += cur_accel_to_min;
    }
}

-(void)add_airjump_count {
    cur_airjump_count = 0;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DogRocketEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}

@end

#import "DogCapeEffect.h"

@implementation DogCapeEffect

+(DogCapeEffect*)init_from:(PlayerEffectParams*)base {
    DogCapeEffect *n = [[DogCapeEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = 400;
    n.cur_airjump_count = 1;
    return n;
}

-(void)update:(Player *)p {
    if(p.vx < 10) {
        p.vx = 10;
    }
}

-(void)decr_airjump_count {
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DogCapeEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}


@end

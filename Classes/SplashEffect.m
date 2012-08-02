#import "SplashEffect.h"
#import "GameEngineLayer.h"

@implementation SplashEffect

+(SplashEffect*)init_from:(PlayerEffectParams*)base time:(int)time {
    SplashEffect *e = [[SplashEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:e];
    e.time_left = time;
    return e;
}

-(player_anim_mode)get_anim {
    return player_anim_mode_SPLASH;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    [super update:p g:g];
    p.rotation = 0;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"SplashEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}

@end

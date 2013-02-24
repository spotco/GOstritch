#import "SplashEffect.h"
#import "GameEngineLayer.h"

@implementation SplashEffect

+(SplashEffect*)cons_from:(PlayerEffectParams*)base time:(int)time {
    SplashEffect *e = [[SplashEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:e];
    e.time_left = time;
    e.noclip = 2;
    return e;
}

-(player_anim_mode)get_anim {
    return player_anim_mode_SPLASH;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    [super update:p g:g];
    p.rotation = 0;
    p.dead = YES;
    p.vy = 0;
}

-(void)effect_end:(Player *)p g:(GameEngineLayer *)g {
    [super effect_end:p g:g];
}

-(void)effect_begin:(Player *)p {
    p.dead = YES;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"SplashEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}

@end

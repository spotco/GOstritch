#import "HitEffect.h"
#import "FlashEffect.h"
#import "GameEngineLayer.h"

@implementation HitEffect

+(HitEffect*)init_from:(PlayerEffectParams*)base time:(int)time {
    HitEffect *e = [[HitEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:e];
    e.time_left = time;
    e.noclip = YES;
    return e;
}

-(player_anim_mode)get_anim {
    return player_anim_mode_HIT;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    p.dead = YES;
    p.vx = 0;
    p.vy = 0;
}

-(void)effect_end:(Player*)p g:(GameEngineLayer*)g {
    [super effect_end:p g:g];
    p.dead = NO;
    [GEventDispatcher push_unique_event:[GEvent init_type:GEventType_PLAYER_DIE]];
}

-(void)effect_begin:(Player *)p {
    p.dead = YES;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"HitEffect(minspd:%1.1f,timeleft:%i)",cur_min_speed,time_left];
}



@end

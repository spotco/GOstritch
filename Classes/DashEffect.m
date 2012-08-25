#import "DashEffect.h"
#import "GameEngineLayer.h"
#import "JumpPadParticle.h"

@implementation DashEffect

+(DashEffect*)init_from:(PlayerEffectParams*)base {
    DashEffect *n = [[DashEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    n.time_left = 20;
    n.cur_airjump_count = 0;
    n.cur_gravity = 0;
    return n;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    p.vx = MAX(p.vx,12);
    
    if (p.current_island == NULL) {
        p.vy = 0;
    }
    
    if (arc4random_uniform(5) == 1) {
        JumpPadParticle* pt = [JumpPadParticle init_x:p.position.x y:p.position.y+20 vx:float_random(-10, -5) vy:float_random(-2, 2)];
        [g add_particle:pt];
    }
}

-(player_anim_mode)get_anim {
    return player_anim_mode_DASH;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DashEffect(timeleft:%i)",time_left];
}


@end

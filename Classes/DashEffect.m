#import "DashEffect.h"
#import "GameEngineLayer.h"
#import "JumpPadParticle.h"

@implementation DashEffect

@synthesize vx,vy;

+(DashEffect*)init_from:(PlayerEffectParams*)base vx:(float)vx vy:(float)vy {
    DashEffect *n = [[DashEffect alloc] init];
    [PlayerEffectParams copy_params_from:base to:n];
    
    n.vx = vx;
    n.vy = vy;
    
    n.time_left = 20;
    //n.cur_airjump_count = 0;
    n.cur_gravity = 0;
    return n;
}

-(void)update:(Player*)p g:(GameEngineLayer *)g{
    if (p.current_island != NULL) {
        Vec3D *t = [p.current_island get_tangent_vec];
        self.vx = t.x;
        self.vy = t.y;
        [t dealloc];
    } else {    
        p.vx = self.vx*12;
        p.vy = self.vy*12;
    }
}

-(player_anim_mode)get_anim {
    return player_anim_mode_DASH;
}

-(NSString*)info {
    return [NSString stringWithFormat:@"DashEffect(timeleft:%i)",time_left];
}


@end

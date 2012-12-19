#import "BreakableWallRockParticle.h"

#define BreakableWallRockParticle_CT_DEFAULT 50.0

@implementation BreakableWallRockParticle

+(BreakableWallRockParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    BreakableWallRockParticle* p = [BreakableWallRockParticle spriteWithTexture:[Resource get_tex:TEX_CAVE_ROCKPARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    [self setScale:float_random(0.5, 1.5)];
    [self setRotation:float_random(-180, 180)];
    ct = (int)BreakableWallRockParticle_CT_DEFAULT;
}

-(void)cons {
    vx = float_random(-2, -4);
    vy = float_random(0, 2);
    [self setScale:float_random(0.5, 2)];
    ct = (int)BreakableWallRockParticle_CT_DEFAULT;
}

-(void)update:(GameEngineLayer*)g{
    [self setPosition:ccp(position_.x+vx,position_.y+vy)];
    [self setOpacity:((int)(ct/BreakableWallRockParticle_CT_DEFAULT*255))];
    vy-=0.3;
    ct--;
}

-(BOOL)should_remove {
    return ct <= 0;
}

@end

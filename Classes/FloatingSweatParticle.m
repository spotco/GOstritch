#import "FloatingSweatParticle.h"

@implementation FloatingSweatParticle

+(FloatingSweatParticle*)cons_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    FloatingSweatParticle* p = [FloatingSweatParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    return p;
}

-(void)cons_vx:(float)tvx vy:(float)tvy {
    vx = tvx;
    vy = tvy;
    [self setScale:float_random(0.5, 0.9)];
    ct = 20;
    [self setColor:ccc3(255, 255, 255)];
}

-(void)update:(GameEngineLayer *)g {
    [super update:g];
    vy--;
}

@end

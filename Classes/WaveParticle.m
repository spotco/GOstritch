#import "WaveParticle.h"
#import "GameRenderImplementation.h"

@implementation WaveParticle

+(WaveParticle*)cons_x:(float)x y:(float)y vx:(float)vx vtheta:(float)vtheta {
    WaveParticle *p = [WaveParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p setPosition:ccp(x,y)];
    [p cons:vx vtheta:vtheta];
    return p;
}

-(void)cons:(float)tvx vtheta:(float)tvtheta {
    theta = 0;
    baseline = position_.y;
    vtheta = tvtheta;
    vx = tvx;
    [self setColor:ccc3(197+arc4random_uniform(20), 225+arc4random_uniform(25), 128+arc4random_uniform(20))];
    [self setScale:float_random(0.25, 1)];
    ct = 800;
}

-(void)update:(GameEngineLayer*)g{
    theta += vtheta;
    [self setPosition:ccp(position_.x+vx,baseline+sinf(theta)*30)];
    [self setOpacity:ct/800.0*255];
    ct--;
}

-(BOOL)should_remove {
    return ct < 0;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}


@end

#import "RocketParticle.h"
#import "GameRenderImplementation.h"

@implementation RocketParticle

+(RocketParticle*)cons_x:(float)x y:(float)y {
    RocketParticle* p = [RocketParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p cons];
    p.position = ccp(x,y);
    
    return p;
}

-(void)cons {
    [super cons];
    vx = float_random(-2, -4);
    vy = float_random(-2, 2);
    [self setColor:ccc3(255, 0, 0)];
}

-(void)update:(GameEngineLayer*)g{
    [super update:g];
    int pct_y = (int)(((float)ct/STREAMPARTICLE_CT_DEFAULT)*200);
    //NSLog(@"pct:%i",pct_y);
    [self setColor:ccc3(255,pct_y,0)];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

@end

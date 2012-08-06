#import "StreamParticle.h"

@implementation StreamParticle
@synthesize ct;

+(StreamParticle*)init_x:(float)x y:(float)y {
    StreamParticle* p = [StreamParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p initialize];
    p.position = ccp(x,y);
    
    return p;
}

-(void)initialize {
    vx = float_random(-2, -4);
    vy = float_random(0, 2);
    [self setScale:float_random(0.5, 2)];
    ct = (int)STREAMPARTICLE_CT_DEFAULT;
}

-(void)update {
    [self setPosition:ccp(position_.x+vx,position_.y+vy)];
    [self setOpacity:((int)(ct/STREAMPARTICLE_CT_DEFAULT*255))];
    ct--;
}

-(BOOL)should_remove {
    return ct <= 0;
}

@end

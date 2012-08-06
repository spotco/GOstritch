#import "JumpPadParticle.h"

@implementation JumpPadParticle

+(JumpPadParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    JumpPadParticle *p = [JumpPadParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p initialize_vx:vx vy:vy];
    p.position = ccp(x,y);
    
    return p;
}

-(void)initialize_vx:(float)lvx vy:(float)lvy {
    [super initialize];
    self.vx = lvx;
    self.vy = lvy;
    int wht = arc4random_uniform(100)+155;
    [self setColor:ccc3(wht, wht, 255)];
    [self setScale:float_random(1.5, 2.0)];
}

@end

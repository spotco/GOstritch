#import "JumpPadParticle.h"

@implementation JumpPadParticle

+(JumpPadParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    JumpPadParticle *p = [JumpPadParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p initialize_vx:vx vy:vy];
    p.position = ccp(x,y);
    p.scale = float_random(0.75, 1.75);
    return p;
}

-(void)initialize_vx:(float)lvx vy:(float)lvy {
    [super initialize];
    self.vx = lvx;
    self.vy = lvy;
    [self setColor:ccc3(150+arc4random_uniform(60), 210+arc4random_uniform(40), 200+arc4random_uniform(50))];
    [self setScale:float_random(1.5, 2.0)];
}

@end

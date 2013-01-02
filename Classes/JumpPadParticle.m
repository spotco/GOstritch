#import "JumpPadParticle.h"

@implementation JumpPadParticle
+(JumpPadParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    JumpPadParticle *p = [JumpPadParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p cons_vx:vx vy:vy];
    p.position = ccp(x,y);
    return p;
}

-(void)cons_vx:(float)lvx vy:(float)lvy {
    [super cons];
    self.vx = lvx;
    self.vy = lvy;
    [self setColor:ccc3(150+arc4random_uniform(60), 210+arc4random_uniform(40), 200+arc4random_uniform(50))];
    [self setScale:float_random(0.75, 1.75)];
}
@end

@implementation RocketLaunchParticle

+(RocketLaunchParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    RocketLaunchParticle *p = [RocketLaunchParticle spriteWithTexture:[Resource get_tex:TEX_GREY_PARTICLE]];
    [p cons_vx:vx vy:vy];
    p.position = ccp(x,y);
    return p;
}
-(void)cons_vx:(float)lvx vy:(float)lvy {
    [super cons_vx:lvx vy:lvy];
    [self setColor:ccc3(200+arc4random_uniform(55), 0+arc4random_uniform(100), 0+arc4random_uniform(100))];
    ct = 30;
}
@end

#import "BrokenMachineParticle.h"
#import "GameRenderImplementation.h"

@implementation BrokenMachineParticle

+(BrokenMachineParticle*)init_x:(float)x y:(float)y vx:(float)vx vy:(float)vy {
    BrokenMachineParticle* p = [BrokenMachineParticle spriteWithTexture:[Resource get_tex:TEX_ROBOT_PARTICLE]];
    p.position = ccp(x,y);
    [p cons_vx:vx vy:vy];
    [p setScale:float_random(0.5, 1)];
    return p;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}



@end

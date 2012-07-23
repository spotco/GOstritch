
#import "GameObject.h"

@implementation GameObject

@synthesize active;
@synthesize img;

-(GameObjectReturnCode)update:(Player*)player  {
    return GameObjectReturnCode_NONE;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:0 y1:0 x2:0 y2:0];
}

-(void)set_active:(BOOL)t_active {
    return;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_GAMEOBJ_ORD];
}

@end

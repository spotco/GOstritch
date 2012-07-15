
#import "GameObject.h"

@implementation GameObject

@synthesize active;

-(void)update:(Player*)player  {
    return;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:0 y1:0 x2:0 y2:0];
}

-(void)set_active:(BOOL)t_active {
    return;
}

@end

#import "MinionRobot.h"

@implementation MinionRobot

+(MinionRobot*)cons_x:(float)x y:(float)y {
    MinionRobot *r = [MinionRobot spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROBOT] 
                                               rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_ROBOT idname:@"robot"]];
    [r setPosition:ccp(x,y)];
    return r;
}

-(id)init {
    self = [super init];
    [self setAnchorPoint:ccp(0.5,0)];
    self.active = YES;
    return self;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x - self.textureRect.size.width/2
                                y1:position_.y 
                               wid:self.textureRect.size.width 
                               hei:self.textureRect.size.height];
}

@end

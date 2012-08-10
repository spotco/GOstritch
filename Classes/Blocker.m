#import "Blocker.h"

@implementation Blocker

+(Blocker*)init_x:(float)x y:(float)y width:(float)width height:(float)height {
    Blocker* n = [Blocker node];
    [n init_x:x y:y width:width height:height];
    
    return n;
}

-(void)init_x:(float)x y:(float)y width:(float)pwidth height:(float)pheight {
    [self setPosition:ccp(x,y)];
    width = pwidth;
    height = pheight;
    
    self.active = YES;
}

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    if (!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        player.vx = 0;
        player.vy = 0;
        active = NO;
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)reset {
    [self set_active:YES];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:self.position.x y1:self.position.y wid:width hei:height];
}

@end

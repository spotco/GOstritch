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

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (!active) {
        return;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]] && player.current_island == NULL) {
        [player add_effect:[BlockerEffect init_from:[player get_default_params]]];
        player.vy = ABS(player.vy)*-1;
        active = NO;
    }
    
    return;
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

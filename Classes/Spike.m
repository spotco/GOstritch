
#import "Spike.h"

@implementation Spike

+(Spike*)init_x:(float)posx y:(float)posy {
    Spike *s = [Spike node];
    s.position = ccp(posx,posy);
    s.active = YES;
    
    CCTexture2D *tex = [Resource get_tex:TEX_SPIKE];
    s.img = [CCSprite spriteWithTexture:tex];
    
    s.img.position = ccp(0,15);
    
    [s addChild:s.img];
    return s;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(GameObjectReturnCode)update:(Player*)player {
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        player.position = player.start_pt;
        [player reset_params];
        
    }
    
    return GameObjectReturnCode_NONE;
}


@end

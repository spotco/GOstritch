#import "Spike.h"
#import "Island.h"

@implementation Spike

+(Spike*)init_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands {
    Spike *s = [Spike node];
    s.position = ccp(posx,posy);
    s.active = YES;
    
    CCTexture2D *tex = [Resource get_tex:TEX_SPIKE];
    s.img = [CCSprite spriteWithTexture:tex];
    
    s.img.position = ccp(0,0);
    
    [s attach_toisland:islands];
    [s addChild:s.img];
    return s;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g {    
    if(!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [player reset_params];
        [self setActive:NO];
        [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)attach_toisland:(NSMutableArray*)islands {
    CGPoint p = [self position];
    line_seg vert = [Common cons_line_seg_a:ccp(p.x,p.y-10) b:ccp(p.x,p.y+10)];
    line_seg horiz = [Common cons_line_seg_a:ccp(p.x-10,p.y) b:ccp(p.x+10,p.y)];
    
    for (Island* i in islands) {
        line_seg iseg = [i get_line_seg];
        CGPoint vert_ins = [Common line_seg_intersection_a:vert b:iseg];
        CGPoint horiz_ins = [Common line_seg_intersection_a:horiz b:iseg];
        if ((vert_ins.x != [Island NO_VALUE] && vert_ins.y != [Island NO_VALUE]) ||
            (horiz_ins.x != [Island NO_VALUE] && horiz_ins.y != [Island NO_VALUE])){
            
            Vec3D *tangent_vec = [i get_tangent_vec];
            [tangent_vec scale:[i ndir]];
            float tar_rad = -[tangent_vec get_angle_in_rad];
            float tar_deg = [Common rad_to_deg:tar_rad];
            img.rotation = tar_deg;
            
            [tangent_vec normalize];
            Vec3D *normal_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
            [normal_vec scale:15];
            img.position = ccp(normal_vec.x,normal_vec.y);
            
            
            [tangent_vec dealloc];
            [normal_vec dealloc];
            
            return;
        }
    }
    NSLog(@"no island found");
}

@end

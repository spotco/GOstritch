#import "SwingVine.h"

#define VINE_TIGHT_LENGTH 220.0

@implementation SwingVine

+(SwingVine*)init_x:(float)x y:(float)y {
    SwingVine *s = [SwingVine node];
    [s setPosition:ccp(x,y)];
    [s initialize];
    return s;
}

-(void)initialize {
    vine = [CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_SWINGVINE_TIGHT]];
    [self addChild:vine];
    loosevine = [CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_SWINGVINE_LOOSE]];
    [self addChild:loosevine];
    
    [self addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_SWINGVINE_BASE]]];
    [vine setAnchorPoint:ccp(vine.anchorPoint.x,1)];
    [loosevine setAnchorPoint:ccp(loosevine.anchorPoint.x,1)];
    
}

-(void)temp_disable {
    disable_timer = 50;
}

-(GameObjectReturnCode)update:(Player *)player g:(GameEngineLayer *)g {
    //fix satpoly hitbox for moving position, see spikevine update
    if (vine.rotation > 0) {
        vr -= 0.1;
    } else {
        vr += 0.1;
    }
    [vine setRotation:vine.rotation+vr];
    [loosevine setRotation:vine.rotation];
    
    
    [vine setVisible:player.current_swingvine == self];
    [loosevine setVisible:player.current_swingvine != self];
    
    if (disable_timer >0) {
        disable_timer--;
        [vine setOpacity:150];
        [loosevine setOpacity:150];
        return GameObjectReturnCode_NONE;
    } else {
        [loosevine setOpacity:255];
        [vine setOpacity:255];
    }
    
    if (player.current_swingvine == NULL && player.current_island == NULL && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        line_seg playerseg = [self get_player_mid_line_seg:player];
        line_seg selfseg = [self get_hit_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:playerseg b:selfseg];
        if (ins.x != [Island NO_VALUE] && ins.y != [Island NO_VALUE]) {
            ins.x -= position_.x;
            ins.y -= position_.y;
            
            cur_dist = sqrtf(powf(ins.x, 2)+powf(ins.y, 2));
            player.current_swingvine = self;
            player.vx = 0;
            player.vy = 0;
            [player remove_temp_params:g];
            
            vr = -4; //~90deg
        }
    }
    
    if (player.current_swingvine == self) {        
        if (cur_dist < VINE_TIGHT_LENGTH) {
            cur_dist += (VINE_TIGHT_LENGTH-cur_dist)/20.0;
        }

        if (ABS(vine.rotation) > 90) {
            vine.rotation = 90 * [Common sig:vine.rotation];
            vr = 0;
        }
        
        CGPoint tip = [self get_tip_relative_pos];
        Vec3D *dirvec = [Vec3D init_x:tip.x y:tip.y z:0];
        [dirvec normalize];
        [dirvec scale:cur_dist];
        [player setPosition:ccp(position_.x+dirvec.x,position_.y+dirvec.y)];
        
        [dirvec scale:-1];
        [dirvec normalize];
        player.up_vec.x = dirvec.x;
        player.up_vec.y = dirvec.y;
        
        Vec3D *tangent_vec = [dirvec crossWith:[Vec3D Z_VEC]];
        float tar_rad = -[tangent_vec get_angle_in_rad];
        float tar_deg = [Common rad_to_deg:tar_rad];
        [player setRotation:tar_deg];
        
        [dirvec dealloc];
        [tangent_vec dealloc];
        
    } else {
        vr *= 0.95;
    }
    
    return GameObjectReturnCode_NONE;
}

-(line_seg)get_player_mid_line_seg:(Player*)p { 
    //64 wid,58 hei
    CGPoint base = p.position;
    Vec3D* up;
    if (p.current_island != NULL) {
        up = [p.current_island get_normal_vec];
    } else {
        up = [Vec3D init_x:0 y:1 z:0];
    }
    [up scale:58.0/2.0];
    base.x += up.x;
    base.y += up.y;
    Vec3D* tangent = [up crossWith:[Vec3D Z_VEC]];
    [tangent normalize];
    float hwid = 64.0/2.0;
    line_seg ret = [Common cons_line_seg_a:ccp(base.x-hwid*tangent.x,base.y-hwid*tangent.y) b:ccp(base.x+hwid*tangent.x,base.y+hwid*tangent.y)];
    [up dealloc];
    [tangent dealloc];
    return ret;
}

-(CGPoint)get_tip_relative_pos {
    float calc_a = vine.rotation - 90;
    float calc_rad = [Common deg_to_rad:calc_a];
    return ccp(-VINE_TIGHT_LENGTH*cosf(calc_rad),VINE_TIGHT_LENGTH*sinf(calc_rad));
}

-(line_seg)get_hit_line_seg {
    CGPoint tip_rel = [self get_tip_relative_pos];
    return [Common cons_line_seg_a:ccp(position_.x,position_.y) b:ccp(position_.x+tip_rel.x,position_.y+tip_rel.y)];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-VINE_TIGHT_LENGTH y1:position_.y-VINE_TIGHT_LENGTH wid:VINE_TIGHT_LENGTH*2 hei:VINE_TIGHT_LENGTH*2];
}

-(void)reset {
    [super reset];
    [vine setRotation:0];
    vr = 0;
}

-(CGPoint)get_tangent_vel {
    //    CGPoint tip_rel = [self get_tip_relative_pos];
    //    Vec3D *n = [Vec3D init_x:tip_rel.x y:tip_rel.y z:0];
    //    Vec3D *tangent_vel;
    //    if (vr > 0) {
    //        tangent_vel = [n crossWith:[Vec3D Z_VEC]];
    //    } else {
    //        tangent_vel = [[Vec3D Z_VEC] crossWith:n];
    //    }
    //    [n dealloc];
    //    [tangent_vel normalize];
    //    [tangent_vel scale:cur_dist/10];
    //    CGPoint t_vel = ccp(tangent_vel.x,tangent_vel.y);
    //    [tangent_vel dealloc];
    //    t_vel.x = MAX(t_vel.x,0);
    CGPoint t_vel = ccp(7,7);
    return t_vel;
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end

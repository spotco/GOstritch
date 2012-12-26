#import "SwingVine.h"

@interface VineBody : CCSprite {
    
}
+(VineBody*)cons_tex:(CCTexture2D*)tex len:(float)len;
@end

@implementation VineBody
+(VineBody*)cons_tex:(CCTexture2D *)tex len:(float)len {
    ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [tex setTexParameters:&par];
    VineBody* v = [VineBody spriteWithTexture:tex];
    [v init_len:len];
    return v;
}

-(void)init_len:(float)len {
    [self setTextureRect:CGRectMake(0, 0, [self.texture contentSizeInPixels].width, len)];
}
@end


@implementation SwingVine

+(SwingVine*)init_x:(float)x y:(float)y len:(float)len{
    SwingVine *s = [SwingVine node];
    [s setPosition:ccp(x,y)];
    [s cons_len:len];
    return s;
}

-(void)cons_len:(float)len {
    length = len;
    vine = [VineBody cons_tex:[Resource get_tex:TEX_SWINGVINE_TEX] len:len];
    [self addChild:vine];
    [self addChild:[CCSprite spriteWithTexture:[Resource get_tex:TEX_SWINGVINE_BASE]]];
    [vine setAnchorPoint:ccp(vine.anchorPoint.x,1)];
    
    headcov = [CCSprite spriteWithTexture:[Resource get_tex:[Player get_character]] 
                           rect:[FileCache get_cgrect_from_plist:[Player get_character] idname:@"swing_head"]];
    [headcov setAnchorPoint:ccp(0.5-0.05,0+0.05)];
    [headcov setVisible:NO];
    [self addChild:headcov];
    
}

-(void)temp_disable {
    disable_timer = 50;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    //fix satpoly hitbox for moving position, see spikevine update
    
    if (vine.rotation > 0) {
        vr -= 0.1;
    } else {
        vr += 0.1;
    }
    [vine setRotation:vine.rotation+vr];
    
    if (disable_timer >0) {
        disable_timer--;
        [vine setOpacity:150];
        [headcov setVisible:NO];
        return;
    } else {
        [vine setOpacity:255];
    }
    
    if (player.current_swingvine == NULL && player.current_island == NULL && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        line_seg playerseg = [self get_player_mid_line_seg:player];
        line_seg selfseg = [self get_hit_line_seg];
        CGPoint ins = [Common line_seg_intersection_a:playerseg b:selfseg];
        if (ins.x != [Island NO_VALUE] && ins.y != [Island NO_VALUE]) {
            ins_offset = ccp(ins.x-player.position.x,ins.y-player.position.y);
            
            ins.x -= position_.x;
            ins.y -= position_.y;
            
            cur_dist = sqrtf(powf(ins.x, 2)+powf(ins.y, 2));
            player.current_swingvine = self;
            player.vx = 0;
            player.vy = 0;
            [player remove_temp_params:g];
            
            vr = -3.5; //~90deg
        }
    }
    
    if (player.current_swingvine == self) {        
        if (cur_dist < length) {
            cur_dist += (length-cur_dist)/20.0;
        }

        if (ABS(vine.rotation) > 90) {
            vine.rotation = 90 * [Common sig:vine.rotation];
            vr = 0;
        }
        
        CGPoint tip = [self get_tip_relative_pos];
        Vec3D *dirvec = [Vec3D init_x:tip.x y:tip.y z:0];
        [dirvec normalize];
        Vec3D *offset_v = [dirvec crossWith:[Vec3D Z_VEC]];
        [dirvec scale:cur_dist];
        [offset_v normalize];
        [offset_v scale:15];
        
        [player setPosition:ccp(position_.x+dirvec.x+offset_v.x-ins_offset.x,position_.y+dirvec.y+offset_v.y-ins_offset.y)];
        ins_offset.x *= 0.9;
        ins_offset.y *= 0.9;
        
        [dirvec scale:-1];
        [dirvec normalize];
        player.up_vec.x = dirvec.x;
        player.up_vec.y = dirvec.y;
        
        Vec3D *tangent_vec = [dirvec crossWith:[Vec3D Z_VEC]];
        float tar_rad = -[tangent_vec get_angle_in_rad];
        float tar_deg = [Common rad_to_deg:tar_rad];
        
        if (player.current_anim == player._SWING_ANIM) {
            [player setRotation:tar_deg];
            [headcov setVisible:YES];
            [headcov setPosition:ccp(player.position.x-position_.x,player.position.y-position_.y)];
            [headcov setRotation:player.rotation];
        } else {
            [headcov setVisible:NO];
        }
        
        [offset_v dealloc];
        [dirvec dealloc];
        [tangent_vec dealloc];
        
    } else {
        [headcov setVisible:NO];
        vr *= 0.95;
    }
    
    return;
}

-(line_seg)get_player_mid_line_seg:(Player*)p { 
    //64 wid,58 hei
    CGPoint base = p.position;
    Vec3D* up;
    if (p.current_island != NULL) {
        Vec3D* nvec = [p.current_island get_normal_vecC];
        up = [Vec3D init_x:nvec.x y:nvec.y z:nvec.z];
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
    return ccp(-length*cosf(calc_rad),length*sinf(calc_rad));
}

-(line_seg)get_hit_line_seg {
    CGPoint tip_rel = [self get_tip_relative_pos];
    return [Common cons_line_seg_a:ccp(position_.x,position_.y) b:ccp(position_.x+tip_rel.x,position_.y+tip_rel.y)];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_FG_ISLAND_ORD];
    //return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-length y1:position_.y-length wid:length*2 hei:length*2];
}

-(void)reset {
    [super reset];
    [vine setRotation:0];
    vr = 0;
}

-(CGPoint)get_tangent_vel {
    CGPoint t_vel = ccp(10,10);
    return t_vel;
}

-(void)draw {
    [super draw];
    /*glColor4ub(0,255,0,100);
    ccDrawLine(ccp(0,0), [self get_tip_relative_pos]);
     */
}

-(void)dealloc {
    [self removeAllChildrenWithCleanup:YES];
    [super dealloc];
}

@end

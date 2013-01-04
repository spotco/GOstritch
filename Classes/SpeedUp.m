#import "SpeedUp.h"
#import "GameEngineLayer.h"

@implementation SpeedUp

+(SpeedUp*)init_x:(float)x y:(float)y dirvec:(Vec3D *)vec{
    SpeedUp *s = [SpeedUp node];
    s.position = ccp(x,y);
    //s.anchorPoint = ccp(s.anchorPoint.x,0);
    [s cons_anim];
    [s set_dir:vec];
    [s setActive:YES];
    
    return s;
}

-(HitRect)get_hit_rect {
     return [Common hitrect_cons_x1:[self position].x-30 y1:[self position].y-30 wid:60 hei:60];
}

-(void)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
    
    if (recharge_ct > 0) {
        recharge_ct--;
        if (self.opacity != 170)[self setOpacity:170];
    } else {
        if (self.opacity != 255)[self setOpacity:255];
    }
    
    if (recharge_ct == 0 && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {            
        [self particle_effect:g];
        player.vx += normal_vec.x*6;
        player.vy += normal_vec.y*6;
        
        PlayerEffectParams *e = [PlayerEffectParams init_copy:player.get_default_params];
        e.time_left = 100;
        e.cur_min_speed = 15;
        [player add_effect:e];
        
        recharge_ct = 50;
    }
}

-(void)particle_effect:(GameEngineLayer*)g {
    for(int i = 0; i < 6; i++) {
        float spd = float_random(4, 10);
        [g add_particle:[JumpPadParticle init_x:position_.x 
                                              y:position_.y
                                             vx:-normal_vec.x*spd+float_random(-5, 5)
                                             vy:-normal_vec.y*spd+float_random(-10, 10)]];
    }
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(void)cons_anim {
    anim = [self init_anim_ofspeed:0.2];
    [self runAction:anim];
}

-(id)init_anim_ofspeed:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_SPEEDUP];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[SpeedUp spritesheet_rect_tar:@"speedup1"]]];
    
    return [SpeedUp make_anim_frames:animFrames speed:speed];
}



+(id)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:YES];
    id m = [CCRepeatForever actionWithAction:animate];
    
    [m retain];    
	return m;
}

+(CGRect)spritesheet_rect_tar:(NSString*)tar {
    return [FileCache get_cgrect_from_plist:TEX_SPEEDUP idname:tar];
}

-(void)set_dir:(Vec3D*)vec {
    normal_vec = [Vec3D init_x:vec.x y:vec.y z:0];
    
    Vec3D* tangent = [vec crossWith:[Vec3D Z_VEC]];
    float tar_rad = -[tangent get_angle_in_rad] - M_PI/2;
    rotation_ = [Common rad_to_deg:tar_rad];
    [tangent dealloc];
}

/*-(void)attach_toisland:(NSMutableArray*)islands {
    Island *i = [self get_connecting_island:islands];
    
    if (i != NULL) {
        Vec3D *tangent_vec = [i get_tangent_vec];
        [tangent_vec scale:[i ndir]];
        float tar_rad = -[tangent_vec get_angle_in_rad];
        float tar_deg = [Common rad_to_deg:tar_rad];
        rotation_ = tar_deg;
        
        normal_vec = [[Vec3D Z_VEC] crossWith:tangent_vec];
        [normal_vec normalize];
        [normal_vec retain];
        
        [tangent_vec dealloc];
    } else {
        //NSLog(@"attach fail");
        normal_vec = [Vec3D init_x:0 y:1 z:0];
        [normal_vec retain];
    }
}*/

-(void)dealloc {
    [normal_vec dealloc];
    [self stopAllActions];
    [anim release];
    [super dealloc];
}

@end

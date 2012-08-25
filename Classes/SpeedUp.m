#import "SpeedUp.h"
#import "GameEngineLayer.h"

@implementation SpeedUp

+(SpeedUp*)init_x:(float)x y:(float)y islands:(NSMutableArray*)islands {
    SpeedUp *s = [SpeedUp node];
    s.position = ccp(x,y);
    s.anchorPoint = ccp(s.anchorPoint.x,0);
    [s initialize_anim];
    [s attach_toisland:islands];
    [s setActive:YES];
    
    return s;
}

-(HitRect)get_hit_rect {
     return [Common hitrect_cons_x1:[self position].x-10 y1:[self position].y-10 wid:20 hei:20];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
    if(!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        if ([[player get_current_params] get_anim] == player_anim_mode_RUN) {
            
            for(int i = 0; i < 8; i++) {
                float r = ((float)i);
                r = r/4.0 * M_PI;
                
                float dvx = cosf(r)*8+float_random(0, 1);
                float dvy = sinf(r)*8+float_random(0, 1);
                [g add_particle:[JumpPadParticle init_x:position_.x 
                                                      y:position_.y
                                                     vx:dvx
                                                     vy:dvy]];
            }
            
            
            PlayerEffectParams *e = [PlayerEffectParams init_copy:player.get_default_params];
            e.time_left = 100;
            player.vx = MIN(15,player.vx+5);
            e.cur_min_speed = 15;
            [player add_effect:e];
        }
        [self set_active:NO];
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)set_active:(BOOL)t_active {
    active = t_active;
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(void)initialize_anim {
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


#define SPEEDUP_SS_FILENAME @"speedup_ss"
static NSDictionary *speedup_ss_plist_dict;

+(CGRect)spritesheet_rect_tar:(NSString*)tar {
    NSDictionary *dict;
    if (speedup_ss_plist_dict == NULL) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:SPEEDUP_SS_FILENAME ofType:@"plist"];
        speedup_ss_plist_dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    dict = speedup_ss_plist_dict;
    
    NSDictionary *frames_dict = [dict objectForKey:@"frames"];
    NSDictionary *obj_info = [frames_dict objectForKey:tar];
    NSString *txt = [obj_info objectForKey:@"textureRect"];
    CGRect r = CGRectFromString(txt);
    return r;
}

-(void)attach_toisland:(NSMutableArray*)islands {
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
}

-(void)dealloc {
    [normal_vec dealloc];
    [self stopAllActions];
    [anim release];
    [super dealloc];
}

@end

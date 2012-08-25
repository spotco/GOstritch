#import "JumpPad.h"
#import "Player.h"
#import "GameEngineLayer.h"

#define JUMP_POWER 20
#define RECHARGE_TIME 15

@implementation JumpPad

+(JumpPad*)init_x:(float)x y:(float)y dirvec:(Vec3D *)vec{
    JumpPad *j = [JumpPad node];
    j.position = ccp(x,y);
    [j initialize_anim];
    
    [j set_dir:vec];
    
    [j setActive:YES];
    return j;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:[self position].x-20 y1:[self position].y-20 wid:40 hei:40];
}

-(GameObjectReturnCode)update:(Player*)player g:(GameEngineLayer *)g{
    [super update:player g:g];
    if (recharge_ct >= 0) {
        recharge_ct--;
        if (recharge_ct == 0) {
            [self set_active:YES];
        }
    }
    if(!active) {
        return GameObjectReturnCode_NONE;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        [self set_active:NO];
        recharge_ct = RECHARGE_TIME;
        [self boostjump:player];
        
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
    }
    
    return GameObjectReturnCode_NONE;
}

-(void)boostjump:(Player*)player {
    Vec3D *jnormal = [Vec3D init_x:normal_vec.x y:normal_vec.y z:0];
    [jnormal normalize];
    [jnormal scale:2];
    
    player.current_island = NULL;
    player.position = [jnormal transform_pt:player.position];
    
    [jnormal normalize];
    [jnormal scale:JUMP_POWER];
    
    player.vx = jnormal.x;
    player.vy = jnormal.y;
    
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_ISLAND_ORD];
}

-(void)initialize_anim {
    anim = [self init_anim_ofspeed:0.2];
    [self runAction:anim];
}

-(id)init_anim_ofspeed:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_JUMPPAD];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad2"]]];
	[animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[JumpPad spritesheet_rect_tar:@"jumppad3"]]];
    
    return [JumpPad make_anim_frames:animFrames speed:speed];
}



+(id)make_anim_frames:(NSMutableArray*)animFrames speed:(float)speed {
	id animate = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:YES];
    id m = [CCRepeatForever actionWithAction:animate];
    
    [m retain];    
	return m;
}


#define JUMPPAD_SS_FILENAME @"superjump_ss"
static NSDictionary *jumppad_ss_plist_dict;

+(CGRect)spritesheet_rect_tar:(NSString*)tar {
    NSDictionary *dict;
    if (jumppad_ss_plist_dict == NULL) {
        NSString* plistPath = [[NSBundle mainBundle] pathForResource:JUMPPAD_SS_FILENAME ofType:@"plist"];
        jumppad_ss_plist_dict = [[NSDictionary alloc] initWithContentsOfFile:plistPath];
    }
    dict = jumppad_ss_plist_dict;
    
    NSDictionary *frames_dict = [dict objectForKey:@"frames"];
    NSDictionary *obj_info = [frames_dict objectForKey:tar];
    NSString *txt = [obj_info objectForKey:@"textureRect"];
    CGRect r = CGRectFromString(txt);
    return r;
}

-(void)set_dir:(Vec3D*)vec {
    normal_vec = [Vec3D init_x:vec.x y:vec.y z:0];
    
    Vec3D* tangent = [vec crossWith:[Vec3D Z_VEC]];
    float tar_rad = -[tangent get_angle_in_rad];
    rotation_ = [Common rad_to_deg:tar_rad];
    [tangent dealloc];
}

-(void)set_active:(BOOL)t_active {
    if (t_active) {
        [self setOpacity:255];
    } else {
        [self setOpacity:0];
    }
    active = t_active;
}

- (void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
	for(CCSprite *sprite in [self children]) {
		sprite.opacity = opacity;
	}
}

-(void)dealloc {
    [normal_vec dealloc];
    [self stopAllActions];
    [anim release];
    [super dealloc];
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
 normal_vec = [Vec3D init_x:0 y:1 z:0];
 [normal_vec retain];
 }
 }*/

@end

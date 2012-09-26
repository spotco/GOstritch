#import "Player.h"
#import "PlayerEffectParams.h"
#import "GameEngineLayer.h"

#define IMGWID 64
#define IMGHEI 58
#define IMG_OFFSET_X -31
#define IMG_OFFSET_Y -3

#define DEFAULT_GRAVITY -0.5
#define DEFAULT_MIN_SPEED 7

#define MIN_SPEED_MAX 14
#define LIMITSPD_INCR 2

#define HITBOX_RESCALE 0.7

#define TRAIL_MIN 8
#define TRAIL_MAX 15


@implementation Player
@synthesize vx,vy;
@synthesize player_img;
@synthesize current_island;
@synthesize up_vec;
@synthesize start_pt;
@synthesize last_ndir;
@synthesize floating,dashing,dead;
@synthesize current_swingvine;

+(Player*)init_at:(CGPoint)pt {
	Player *new_player = [Player node];
    [new_player reset_params];
	CCSprite *player_img = [CCSprite node];
    new_player.player_img = player_img;
    new_player.last_ndir = 1;
    new_player.current_island = NULL;
	player_img.anchorPoint = ccp(0,0);
	player_img.position = ccp(IMG_OFFSET_X,IMG_OFFSET_Y);
	
    new_player.up_vec = [Vec3D init_x:0 y:1 z:0];
	[new_player addChild:player_img];
	
    [new_player init_anim];
	
    new_player.start_pt = pt;
	new_player.anchorPoint = ccp(0,0);
    new_player.position = new_player.start_pt;
	return new_player;
}

- (void)setOpacity:(GLubyte)opacity {
	[super setOpacity:opacity];
    
	for(CCSprite *sprite in [self children]) {
        
		sprite.opacity = opacity;
	}
}

-(void)init_anim {
    _RUN_ANIM_SLOW = [self init_run_anim_speed:0.075];
    _RUN_ANIM_MED = [self init_run_anim_speed:0.06];
    _RUN_ANIM_FAST = [self init_run_anim_speed:0.05];
    _RUN_ANIM_NONE = [self init_none_anim];
    _ROCKET_ANIM = [self init_rocket_anim_speed:0.1];
    _CAPE_ANIM = [self init_cape_anim_speed:0.1];
    _HIT_ANIM = [self init_hit_anim_speed:0.1];
    _SPLASH_ANIM = [self init_splash_anim_speed:0.1];
    _DASH_ANIM = [self init_rolldash_anim:0.05];
    
    [self start_anim:_RUN_ANIM_NONE];
}

-(id)init_hit_anim_speed:(float)speed {
    CCTexture2D *texture = [Resource get_tex:TEX_DOG_RUN_1];
    NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"hit_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"hit_1"]]];
    
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_rolldash_anim:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rolldash_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rolldash_1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rolldash_2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rolldash_3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rolldash_4"]]];
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_run_anim_speed:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    for(int i = 0; i < 5; i++) {
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_0"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_1"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_2"]]];
        [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_3"]]];
    }
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_blink"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_3"]]];
    
	return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_none_anim {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"run_0"]]];
    return [[Common make_anim_frames:animFrames speed:1] retain];
}

-(id)init_rocket_anim_speed:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rocket_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"rocket_1"]]];
	
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_cape_anim_speed:(float)speed {
	CCTexture2D *texture = [Resource get_aa_tex:TEX_DOG_RUN_1];
	NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"cape_0"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[Player dog1ss_spritesheet_rect_tar:@"cape_1"]]];
	
    return [[Common make_anim_frames:animFrames speed:speed] retain];
}

-(id)init_splash_anim_speed:(float)speed {
    CCTexture2D *tex = [Resource get_tex:TEX_DOG_SPLASH];
    NSMutableArray *animFrames = [NSMutableArray array];
    
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[Player splash_ss_plist_dict:@"splash1"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[Player splash_ss_plist_dict:@"splash2"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:[Player splash_ss_plist_dict:@"splash3"]]];
    [animFrames addObject:[CCSpriteFrame frameWithTexture:tex rect:CGRectMake(0, 0, 0, 0)]];
    
    id anim = [CCAnimate actionWithAnimation:[CCAnimation animationWithFrames:animFrames delay:speed] restoreOriginalFrame:NO];
    [anim retain];
    return anim;
}

#define SPLASH_SS_FILENAME @"splash_ss"
#define DOG_1_SS_FILENAME @"dog1ss"
static NSDictionary *dog_1_ss_plist_dict = NULL;
static NSDictionary *splash_ss_plist_dict = NULL;

+(CGRect)splash_ss_plist_dict:(NSString*)tar {
    if (splash_ss_plist_dict == NULL) {
        splash_ss_plist_dict =[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:SPLASH_SS_FILENAME ofType:@"plist"]];
    }
    return [Common ssrect_from_dict:splash_ss_plist_dict tar:tar];
}

+(CGRect)dog1ss_spritesheet_rect_tar:(NSString*)tar {
    if (dog_1_ss_plist_dict == NULL) {
        dog_1_ss_plist_dict =[[NSDictionary alloc] initWithContentsOfFile:[[NSBundle mainBundle] pathForResource:DOG_1_SS_FILENAME ofType:@"plist"]];
    }
    return [Common ssrect_from_dict:dog_1_ss_plist_dict tar:tar];
}


-(void)start_anim:(id)anim {
    if (current_anim == anim) {
        return;
    } else if (current_anim != NULL) {
        [player_img stopAction:current_anim];
    }
    [player_img runAction:anim];
    current_anim = anim;
}



-(PlayerEffectParams*) get_current_params {
    if (temp_params != NULL) {
        return temp_params;
    } else {
        return current_params;
    }
}

-(PlayerEffectParams*) get_default_params {
    return current_params;
}

-(void) reset {
    position_ = start_pt;
    current_island = NULL;
    [up_vec dealloc];
    up_vec = [Vec3D init_x:0 y:1 z:0];
    vx = 0;
    vy = 0;
    rotation_ = 0;
    last_ndir = 1;
    floating = NO;
    dashing = NO;
    dead = NO;
    current_swingvine = NULL;
    [self reset_params];
}

-(void) reset_params {
    if (temp_params != NULL) {
        [temp_params f_dealloc];
        temp_params = NULL;
    }
    if (current_params != NULL) {
        [current_params f_dealloc];
        current_params = NULL;
    }
    current_params = [[PlayerEffectParams alloc] init];
    current_params.cur_gravity = DEFAULT_GRAVITY;
    current_params.cur_limit_speed = DEFAULT_MIN_SPEED + LIMITSPD_INCR;
    current_params.cur_min_speed = DEFAULT_MIN_SPEED;
    current_params.cur_airjump_count = 1;
    current_params.cur_dash_count = 1;
    current_params.time_left = -1;
}

-(void)add_effect:(PlayerEffectParams*)effect {
    if (temp_params != NULL) {
        if (game_engine_layer != NULL) {
            [temp_params effect_end:self g:game_engine_layer];
        } else {
            NSLog(@"ERROR: add effect before player has reference to gameengine, check add_effect method of player");
        }
        [temp_params dealloc];
        temp_params = NULL;
    }
    temp_params = effect;
    [temp_params effect_begin:self];
}

static GameEngineLayer* game_engine_layer;

-(void) update:(GameEngineLayer*)g {
    game_engine_layer = g;
    float vel = sqrtf(powf(vx,2)+powf(vy,2));
    
    if (current_island == NULL) {
        Vec3D *dv = [Vec3D init_x:vx y:vy z:0];
        [dv normalize];
        
        float rot = -[Common rad_to_deg:[dv get_angle_in_rad]];
        float sig = [Common sig:rot];
        rot = sig*sqrtf(ABS(rot));
        rotation_ = rot;
        [dv dealloc];
    } else {
        if (vel > TRAIL_MIN) {
            float ch = (vel-TRAIL_MIN)/(TRAIL_MAX - TRAIL_MIN)*100;
            if (arc4random_uniform(100) < ch) {
                Vec3D *dv = [current_island get_tangent_vec];
                [dv normalize];
                [dv scale:-2.5];
                dv.x += float_random(-3, 3);
                dv.y += float_random(-3, 3);
                [g add_particle:[StreamParticle init_x:position_.x y:position_.y vx:dv.x vy:dv.y]];
                [dv dealloc];
            }
        }
    }
    
    if (floating && arc4random()%10 == 0) {
        float pvx;
        if (arc4random_uniform(2) == 0) {
            pvx = float_random(4, 6);
        } else {
            pvx = float_random(-4, -6);
        }
        [g add_particle:[FloatingSweatParticle init_x:position_.x+6 y:position_.y+29 vx:pvx+vx vy:float_random(3, 6)+vy]];
    }
    
    player_anim_mode cur_anim_mode = [[self get_current_params] get_anim];
    
    
    dashing = cur_anim_mode == player_anim_mode_DASH;
    
    if (cur_anim_mode == player_anim_mode_RUN) {
        if (current_island == NULL) {
            if (floating) {
                [self start_anim:_RUN_ANIM_FAST];
            } else {
                [self start_anim:_RUN_ANIM_NONE];
            }
            
        } else {
            if (vel > 10) {
                [self start_anim:_RUN_ANIM_FAST];
            } else if (vel > 6.9) {
                [self start_anim:_RUN_ANIM_MED];
            } else {
                [self start_anim:_RUN_ANIM_SLOW];
            }
        }
    } else if (cur_anim_mode == player_anim_mode_DASH) {
        [self start_anim:_DASH_ANIM];
    } else if (cur_anim_mode == player_anim_mode_CAPE) {
        [self start_anim:_CAPE_ANIM];
    } else if (cur_anim_mode == player_anim_mode_ROCKET) {
        [self start_anim:_ROCKET_ANIM];
        [g add_particle:[RocketParticle init_x:position_.x-40 y:position_.y+20]];
    } else if (cur_anim_mode == player_anim_mode_HIT) {
        [self start_anim:_HIT_ANIM];
    } else if (cur_anim_mode == player_anim_mode_SPLASH) {
        [self start_anim:_SPLASH_ANIM];
    }
    
    if (temp_params != NULL) {
        [temp_params update:self g:g];
        [temp_params decrement_timer];
        //NSLog([temp_params info]);
        if (temp_params.time_left == 0) {
            [temp_params effect_end:self g:g];
            if (temp_params.time_left <= 0) {
                [temp_params dealloc];
                temp_params = NULL;
            }
        }
    }
    refresh_hitrect = YES;
}

-(void)remove_temp_params:(GameEngineLayer*)g {
    if (temp_params != NULL) {
        [temp_params effect_end:self g:g];
        [temp_params dealloc];
        temp_params = NULL;
    }
}


BOOL refresh_hitrect = YES;
HitRect cached_rect;

-(HitRect) get_hit_rect {
    if ([self get_current_params].noclip) {
        return [Common hitrect_cons_x1:0 y1:0 wid:0 hei:0];
    } else if (refresh_hitrect == NO) {
        return cached_rect;
    }
    
    Vec3D *v = [Vec3D init_x:up_vec.x y:up_vec.y z:0];
    Vec3D *h = [v crossWith:[Vec3D Z_VEC]];
    float x = self.position.x;
    float y = self.position.y;
    [h normalize];
    [v normalize];
    [h scale:IMGWID/2 * HITBOX_RESCALE];
    [v scale:IMGHEI * HITBOX_RESCALE];
    CGPoint *pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
    pts[0] = ccp(x-h.x , y-h.y);
    pts[1] = ccp(x+h.x , y+h.y);
    pts[2] = ccp(x-h.x+v.x , y-h.y+v.y);
    pts[3] = ccp(x+h.x+v.x , y+h.y+v.y);
    
    float x1 = pts[0].x;
    float y1 = pts[0].y;
    float x2 = pts[0].x;
    float y2 = pts[0].y;

    for (int i = 0; i < 4; i++) {
        x1 = MIN(pts[i].x,x1);
        y1 = MIN(pts[i].y,y1);
        x2 = MAX(pts[i].x,x2);
        y2 = MAX(pts[i].y,y2);
    }
    free(pts);
    [v dealloc];
    [h dealloc];
    
    refresh_hitrect = NO;
    cached_rect = [Common hitrect_cons_x1:x1 y1:y1 x2:x2 y2:y2];
    return cached_rect;
}

-(void)setColor:(ccColor3B)color {
    [super setColor:color];
	for(CCSprite *sprite in [self children]) {
        [sprite setColor:color];
	}
}

-(void)cleanup_anims {
    [self stopAction:current_anim]; 
    
    [_RUN_ANIM_FAST dealloc];
    [_RUN_ANIM_MED dealloc];
    [_RUN_ANIM_NONE dealloc];
    [_RUN_ANIM_SLOW dealloc];
    
    [_ROCKET_ANIM dealloc];
    [_CAPE_ANIM dealloc];
    [_HIT_ANIM dealloc];
    [_SPLASH_ANIM dealloc];
    [_DASH_ANIM dealloc];
    
    [self removeAllChildrenWithCleanup:NO];
}

@end

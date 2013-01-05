#import "CopterRobot.h"
#import "GameEngineLayer.h"

#define ARM_DEFAULT_POSITION ccp(-30,-50)

@implementation CopterRobot

+(CopterRobot*)cons_with_playerpos:(CGPoint)p {
    return [[CopterRobot node] cons_at:p];
}

-(CopterRobot*)cons_at:(CGPoint)p {
    [self init_anims];
    active = YES;
    player_pos = p;
    cur_mode = CopterMode_IntroAnim;
    rel_pos = ccp(800,360);
    [self apply_rel_pos];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    player_pos = player.position;
    [self set_bounds_and_ground:g];
    [self anim_arm];
    
    
    if (cur_mode == CopterMode_PlayerDeadToRemove) {
        [g remove_gameobject:self];
        
    } else if (cur_mode == CopterMode_IntroAnim) {
        NSLog(@"intro");
        [self intro_anim:g];
        
    } else if (cur_mode == CopterMode_LeftDash) {
        NSLog(@"leftdash %f",rel_pos.x);
        [self left_dash:g];
        
    } else if (cur_mode == CopterMode_RightDash) {
        NSLog(@"rightdash %f",rel_pos.x);
        [self right_dash:g];
        
    }
}

static const float PLAYER_FOLLOW_OFFSET = 30;
static const float SLOWSPEED = 5;

static const int DASHWAITDIST = 400;
static const int DASHSPEED = 7;
static const int DASHWAITCT = 100;



-(void)get_random_action:(Side)s {
    if (s == Side_Left) {
        int rand = int_random(0, 1);
        if (rand == 0) {
            cur_mode = CopterMode_RightDash;
            rel_pos = ccp(-600,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
        }
    } else {
        int rand = int_random(0, 1);
        if (rand == 0) {
            cur_mode = CopterMode_LeftDash;
            rel_pos = ccp(800,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
            
        }
    }
}

-(void)left_dash:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:90 y:80 z:131]];
    [self setScaleX:-1];
    if (rel_pos.x > DASHWAITDIST) {
        rel_pos.x -= (DASHSPEED+2);
        [self track_y];
        
    } else if (ct > 0) {
        ct--;
        [self track_y];
        
    } else {
        rel_pos.x -= DASHSPEED;
    }
    
    
    [self setPosition:ccp(rel_pos.x+player_pos.x,position_.y)];
    if (rel_pos.x < -300) {
        [self get_random_action:Side_Left];
    }
}

-(void)right_dash:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:80 z:131]];
    [self setScaleX:1];
    
    if (rel_pos.x < -DASHWAITDIST) {
        rel_pos.x += DASHSPEED;
        [self track_y];
    } else if (ct > 0) {
        ct--;
        [self track_y];
    } else {
        rel_pos.x += DASHSPEED;
    }
    
    [self setPosition:ccp(rel_pos.x+player_pos.x,position_.y)];
    
    if (rel_pos.x > 400) {
        [self get_random_action:Side_Right];
    }
}

-(void)intro_anim:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
    [self setScaleX:-1];
    
    if (rel_pos.x > -300) {
        rel_pos.x-=SLOWSPEED;
        [self setPosition:ccp(rel_pos.x+player_pos.x,position_.y)];
        
    } else {
        [self get_random_action:Side_Left];
    }
}

-(void)track_y {
    position_.y += SIG(player_pos.y+PLAYER_FOLLOW_OFFSET-position_.y)*MIN(SLOWSPEED,ABS(player_pos.y+PLAYER_FOLLOW_OFFSET-position_.y));
}

-(void)apply_rel_pos {
    [self setPosition:ccp(rel_pos.x+player_pos.x,rel_pos.y+player_pos.y)];
}

-(void)reset {
    cur_mode = CopterMode_PlayerDeadToRemove;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:position_.x-40 y1:position_.y-60 wid:80 hei:80];
}

-(void)set_bounds_and_ground:(GameEngineLayer*)g {
    [g stopAction:g.follow_action];
    [g.follow_action release];
    HitRect r = [g get_world_bounds];
    float yl_min = g.player.position.y;
    for (Island *i in g.islands) {
        if (i.endX > g.player.position.x) {
            yl_min = MIN(i.endY,yl_min);
        }
    }
    r.y1 = yl_min-500;
    r.y2 = yl_min+300;
    g.follow_action = [[CCFollow actionWithTarget:g.player worldBoundary:[Common hitrect_to_cgrect:r]] retain];
    [g runAction:g.follow_action];
    
    groundlevel = yl_min;
}

-(void)anim_arm {
    if (arm_dir) {
        arm_r--;
        arm_dir = arm_r<-20?!arm_dir:arm_dir;
    } else {
        arm_r++;
        arm_dir = arm_r>20?!arm_dir:arm_dir;
    }
    [arm setRotation:arm_r];
}

-(void)init_anims {
    body = [CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_ENEMY_COPTER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"body"]];
    [self addChild:body];
    
    aux_prop = [CCSprite node];
    [aux_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"aux_prop_0",@"aux_prop_1",@"aux_prop_2",nil] speed:0.05]];
    [aux_prop setPosition:ccp(-80,-10)];
    [self addChild:aux_prop];
    
    main_prop = [CCSprite node];
    [main_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"main_prop_0",@"main_prop_1",nil] speed:0.05]];
    [main_prop setPosition:ccp(-5,75)];
    [self addChild:main_prop];
    
    main_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                      rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"main_bolt"]];
    [main_nut setPosition:ccp(7,77)];
    [self addChild:main_nut];
    
    aux_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                     rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"aux_bolt"]];
    [aux_nut setPosition:ccp(-80,-10)];
    [self addChild:aux_nut];
    
    arm = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                 rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"arm"]];
    [arm setPosition:ARM_DEFAULT_POSITION];
    [self addChild:arm];
}

-(int)get_render_ord {
    return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];
}

-(CCAction*)init_anim:(NSArray*)a speed:(float)speed {
	CCTexture2D *texture = [Resource get_tex:TEX_ENEMY_COPTER];
	NSMutableArray *animFrames = [NSMutableArray array];
    for (NSString* k in a) [animFrames addObject:[CCSpriteFrame frameWithTexture:texture rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:k]]];
    return [Common make_anim_frames:animFrames speed:speed];
}

@end

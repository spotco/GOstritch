#import "CopterRobot.h"
#import "GameEngineLayer.h"
#import "JumpPadParticle.h"

#define ARM_DEFAULT_POSITION ccp(-35,-55)

@implementation CopterRobot

static const float PLAYER_FOLLOW_OFFSET = 50;
static const float SLOWSPEED = 5;
static const float FLYOFFSPEED = 12;

static const float VIBRATION_SPEED = 0.1;
static const float VIBRATION_AMPLITUDE = 10;

static const int DASHWAITDIST = 400;
static const int DASHSPEED = 7;
static const int DASHWAITCT = 100;

static const int SKYFIRE_SPEED = 60;

static const int RAPIDFIRE_RELOAD_SPEED = 85;
static const int RAPIDFIRE_CT = 560;
static const int RAPIDFIRE_ROCKETSPEED = 5;

static const int TRACKINGFIRE_CT = 500;
static const int TRACKINGFIRE_DIST = 500;
static const int TRACKINGFIRE_RELOAD = 60;
static const int TRACKINGFIRE_ROCKETSPEED = 8;

static const float RECOIL_DIST = 40;
static const float RECOIL_CT = 10;

static const int DEFAULT_HP = 1;

#define DEFAULT_SCALE 1.2

+(CopterRobot*)cons_with_playerpos:(CGPoint)p {
    return [[CopterRobot node] cons_at:p];
}

-(CopterRobot*)cons_at:(CGPoint)p {
    [self init_anims];
    hp = DEFAULT_HP;
    active = YES;
    player_pos = p;
    cur_mode = CopterMode_IntroAnim;
    rel_pos = ccp(800,360);
    [self apply_rel_pos];
    [self setPosition:actual_pos];
    
    return self;
}

-(BOOL)can_hit {
    return (cur_mode != CopterMode_GotHit_FlyOff) && (cur_mode != Coptermode_DeathExplode) && (cur_mode != CopterMode_ToRemove);
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    player_pos = player.position;
    if (cur_mode != CopterMode_ToRemove) {
        [self set_bounds_and_ground:g];
        [GEventDispatcher push_event:[[GEvent init_type:GEventType_BOSS1_TICK] add_i1:hp i2:DEFAULT_HP]];
    }
    
    [self anim_arm];
    [self anim_vibration];
    [self anim_recoil];
    
    if ([self can_hit] && [Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        rel_pos = ccp(actual_pos.x - player.position.x,actual_pos.y-player.position.y);
        if (player.dashing) {
            hp--;
            if (hp <= 0) {
                cur_mode = Coptermode_DeathExplode;
                rel_pos = ccp(actual_pos.x-g.player.position.x,actual_pos.y-g.player.position.y);
                ct = 130;
                
            } else {
                cur_mode = CopterMode_GotHit_FlyOff;
                float velx = float_random(0, FLYOFFSPEED);
                float vely = (FLYOFFSPEED-velx)*(int_random(0, 2)?1:-1);
                flyoffdir = ccp(SIG(actual_pos.x-player.position.x)*velx,vely);
            }
            
        } else if (!player.dead) {
            cur_mode = CopterMode_Killed_Player;
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
            
            
        }
    }
    
    if (cur_mode == CopterMode_ToRemove) {
        [g remove_gameobject:self];
        return;
        
    } else if (cur_mode == CopterMode_IntroAnim) {
        [self intro_anim:g];
        
    } else if (cur_mode == CopterMode_LeftDash) {
        [self left_dash:g];
        
    } else if (cur_mode == CopterMode_RightDash) {
        [self right_dash:g];
        
    } else if (cur_mode == CopterMode_GotHit_FlyOff) {
        [self got_hit_flyoff:g];
        
    } else if (cur_mode == CopterMode_Killed_Player) {
        [self killed_player:g];
        
    } else if (cur_mode == CopterMode_SkyFireLeft) {
        [self skyfire_left:g];
        
    } else if (cur_mode == CopterMode_RapidFireRight) {
        [self rapidfire_right:g];
        
    } else if (cur_mode == CopterMode_TrackingFireLeft) {
        [self trackingfire_left:g];
        
    } else if (cur_mode == Coptermode_DeathExplode) {
        [self death_explode:g];
        
    }
    
    [self setPosition:ccp(actual_pos.x+vibration.x+recoil.x,actual_pos.y+vibration.y+recoil.y)];
}


-(void)get_random_action:(Side)s {
    if (s == Side_Left) {
        lct = (lct+1)%2;
        if (lct == 0) {
            cur_mode = CopterMode_RightDash;
            rel_pos = ccp(-600,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
            
        } else if (lct == 1) {
            cur_mode = CopterMode_RapidFireRight;
            rel_pos = ccp(-600,0);
            actual_pos = ccp(rel_pos.x+player_pos.x,groundlevel + 75);
            ct = RAPIDFIRE_CT;
            
        } else { NSLog(@"ERRORinG_rand_act"); }
        
    } else {
        rct = (rct+1)%3;
        if (rct == 0) {
            cur_mode = CopterMode_LeftDash;
            rel_pos = ccp(800,30);
            ct = DASHWAITCT;
            [self apply_rel_pos];
            
        } else if (rct == 1) {
            cur_mode = CopterMode_SkyFireLeft;
            rel_pos = ccp(1500,420);
            actual_pos = ccp(rel_pos.x+player_pos.x,groundlevel+rel_pos.y);
            
        } else if (rct == 2) {
            cur_mode = CopterMode_TrackingFireLeft;
            rel_pos = ccp(800,30);
            [self apply_rel_pos];
            ct = TRACKINGFIRE_CT;
            
        } else { NSLog(@"ERRORinG_rand_act"); }
    }
}

-(void)death_explode:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:140 y:80 z:131]];
    [self setOpacity:160];
    [self setRotation:rotation_+20];
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    
    (ct%15==0&&ct>20)?[g add_particle:[RelativePositionExplosionParticle init_x:position_.x+float_random(-60, 60) 
                                                                     y:position_.y+float_random(-60, 60) 
                                                                player:g.player.position]] : 0;
    
    ct%5==0?[g add_particle:[RocketLaunchParticle init_x:position_.x 
                                                      y:position_.y 
                                                     vx:float_random(-7, 7) 
                                                     vy:float_random(-7, 7)]]:0;
    
    ct--;
    if (ct <= 0) {
        cur_mode = CopterMode_ToRemove;
        for(float i = 0; i < 10; i++) {
            [g add_particle:[BrokenMachineParticle init_x:position_.x y:position_.y vx:float_random(-5, 10) vy:float_random(-10, 10)]];
        }
        [GEventDispatcher push_event:[[GEvent init_type:GEventType_BOSS1_DEFEATED] add_pt:g.player.position]];
    }
}

-(void)trackingfire_left:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:90 y:80 z:131]];
    [self setScaleX:-1];
    
    if (rel_pos.x > TRACKINGFIRE_DIST) {
        rel_pos.x -= (DASHSPEED+2);
        [self track_y];
        
    } else if (ct > 0) {
        ct--;
        [self track_y];
        
        if(ct%TRACKINGFIRE_RELOAD==0 && ct > TRACKINGFIRE_RELOAD) {
            CGPoint noz = [self get_nozzle];
            [LauncherRobot explosion:g at:noz];
            
            Vec3D *rv = [Vec3D init_x:-1 y:0 z:0];
            [rv normalize];
            [rv scale:TRACKINGFIRE_ROCKETSPEED];
            LauncherRocket *r = [[RelativePositionLauncherRocket cons_at:noz player:g.player.position vel:ccp(rv.x,rv.y)] set_remlimit:1300];
            [rv dealloc];
            
            [g add_gameobject:r];
            [self apply_recoil];
        }
        
    } else {
        rel_pos.x -= DASHSPEED;
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    if (rel_pos.x < -300) {
        [self get_random_action:Side_Left];
    }
}

-(void)rapidfire_right:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:320 y:80 z:131]];
    [self setScaleX:1];
    
    if (rel_pos.x < -DASHWAITDIST) {
        rel_pos.x += DASHSPEED;
    } else if (ct > 0) {
        ct--;
        if(ct%RAPIDFIRE_RELOAD_SPEED==0 && ct > RAPIDFIRE_RELOAD_SPEED) {
            CGPoint noz = [self get_nozzle];
            [LauncherRobot explosion:g at:noz];
            
            Vec3D *rv = [Vec3D init_x:1 y:0 z:0];
            [rv normalize];
            [rv scale:RAPIDFIRE_ROCKETSPEED];
            LauncherRocket *r = [[RelativePositionLauncherRocket cons_at:noz player:g.player.position vel:ccp(rv.x,rv.y)] set_remlimit:1300];
            [rv dealloc];
            
            [g add_gameobject:r];
            [self apply_recoil];
        }
    } else {
        rel_pos.x += DASHSPEED;
    }
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    if (rel_pos.x > 400) {
        [self get_random_action:Side_Right];
    }
}

-(void)skyfire_left:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
    [self setScaleX:-1];
    [self setRotation:-45];
    
    ct++;
    if(ct%SKYFIRE_SPEED==0) {
        CGPoint noz = [self get_nozzle];
        [LauncherRobot explosion:g at:noz];
        
        Vec3D *rv = [Vec3D init_x:-1 y:-1 z:0];
        [rv normalize];
        [rv scale:2.5];
        LauncherRocket *r = [LauncherRocket cons_at:noz vel:ccp(rv.x,rv.y)];
        [rv dealloc];
        
        [g add_gameobject:r];
        [self apply_recoil];
    }
    
    if (rel_pos.x > -300) {
        rel_pos.x-=SLOWSPEED;
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        
    } else {
        [self setRotation:0];
        [self get_random_action:Side_Left];
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
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
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
    
    actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
    
    if (rel_pos.x > 400) {
        [self get_random_action:Side_Right];
    }
}

-(void)intro_anim:(GameEngineLayer*)g {
    [g set_target_camera:[Common cons_normalcoord_camera_zoom_x:94 y:38 z:131]];
    [self setScaleX:-1];
    
    if (rel_pos.x > -300) {
        rel_pos.x-=SLOWSPEED;
        actual_pos = ccp(rel_pos.x+player_pos.x,actual_pos.y);
        
    } else {
        [self get_random_action:Side_Left];
    }
}

-(void)got_hit_flyoff:(GameEngineLayer*)g {
    [self setRotation:rotation_+25];
    [self setOpacity:160];
    rel_pos.x += flyoffdir.x;
    rel_pos.y += flyoffdir.y;
    [self apply_rel_pos];
    ct++;
    ct%6==0?[g add_particle:[RocketLaunchParticle init_x:position_.x 
                                                       y:position_.y 
                                                      vx:-flyoffdir.x + float_random(-4, 4)
                                                      vy:-flyoffdir.y + float_random(-4, 4)
                                                   scale:float_random(1, 3)]]:0;
    
    if (rel_pos.x > 800 || rel_pos.x < -800 || rel_pos.y < -800 || rel_pos.y > 800) {
        [self setRotation:0];
        [self setOpacity:255];
        ct = 0;
        [self get_random_action:(rel_pos.x < 0?Side_Left:Side_Right)];
    }
}

-(void)killed_player:(GameEngineLayer*)g {}

-(void)track_y {
    actual_pos.y += SIG(player_pos.y+PLAYER_FOLLOW_OFFSET-actual_pos.y)*MIN(SLOWSPEED,ABS(player_pos.y+PLAYER_FOLLOW_OFFSET-actual_pos.y));
}

-(void)apply_rel_pos {
    actual_pos = CGPointAdd(rel_pos, player_pos);
}

-(CGPoint)get_nozzle {
    Vec3D *dirvec = [Vec3D init_x:1 y:0 z:0];
    [dirvec scale:100];
    if (scaleX_ < 0) {
        dirvec.y += 40;
    } else {
        dirvec.y -=40;
    }
    
    [dirvec scale:scaleX_];
    Vec3D *rdirvec = [dirvec rotate_vec_by_rad:-[Common deg_to_rad:rotation_]];
    
    CGPoint n = [rdirvec transform_pt:position_];
    
    [rdirvec dealloc];
    [dirvec dealloc];
    return n;
}

-(void)apply_recoil {
    CGPoint noz = [self get_nozzle];
    Vec3D *recoil_dir = [Vec3D init_x:noz.x-position_.x y:noz.y-position_.y z:0];
    [recoil_dir normalize];
    [recoil_dir scale:-RECOIL_DIST];
    recoil_tar = ccp(recoil_dir.x,recoil_dir.y);
    recoil_ct = RECOIL_CT;
    [recoil_dir dealloc];
}

-(void)anim_recoil {
    if (recoil_ct > 0) {
        recoil_ct--;
        float pct = recoil_ct/RECOIL_CT;
        recoil = ccp(pct*(recoil_tar.x),pct*(recoil_tar.y));
        
    } else {
        recoil_tar = CGPointZero;
        recoil = CGPointZero;
    }
}

-(void)reset {
    cur_mode = CopterMode_ToRemove;
}

-(HitRect)get_hit_rect {
    return [Common hitrect_cons_x1:actual_pos.x-40 y1:actual_pos.y-60 wid:80 hei:80];
}

-(void)set_bounds_and_ground:(GameEngineLayer*)g {
    [g stopAction:g.follow_action];
    HitRect r = [g get_world_bounds];
    float yl_min = g.player.position.y;
    for (Island *i in g.islands) {
        if (i.endX > g.player.position.x) {
            yl_min = MIN(i.endY,yl_min);
        }
    }
    r.y1 = yl_min-500;
    r.y2 = yl_min+300;
    g.follow_action = [CCFollow actionWithTarget:g.player worldBoundary:[Common hitrect_to_cgrect:r]];
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

-(void)anim_vibration {
    vibration_theta+=VIBRATION_SPEED;
    vibration.y = VIBRATION_AMPLITUDE*sinf(vibration_theta);
}

-(void)init_anims {
    body = [CCSprite spriteWithTexture:[Resource get_aa_tex:TEX_ENEMY_COPTER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"body_broken"]];
    [self addChild:body];
    
    aux_prop = [CCSprite node];
    [aux_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"aux_prop_0",@"aux_prop_1",@"aux_prop_2",nil] speed:0.05]];
    [aux_prop setPosition:ccp(-86,-10)];
    [self addChild:aux_prop];
    
    main_prop = [CCSprite node];
    [main_prop runAction:[self init_anim:[NSArray arrayWithObjects:@"main_prop_0",@"main_prop_1",@"main_prop_2",@"main_prop_3",@"main_prop_4",nil] speed:0.05]];
    [main_prop setPosition:ccp(-5,85)];
    [self addChild:main_prop];
    
    main_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                      rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"main_bolt"]];
    [main_nut setPosition:ccp(7,87)];
    [self addChild:main_nut];
    
    aux_nut = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                     rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"aux_bolt"]];
    [aux_nut setPosition:ccp(-86,-10)];
    [self addChild:aux_nut];
    
    arm = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_COPTER] 
                                 rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_COPTER idname:@"arm_broken"]];
    [arm setPosition:ARM_DEFAULT_POSITION];
    [self addChild:arm];
    
    [body setScale:DEFAULT_SCALE];
    [aux_prop setScale:DEFAULT_SCALE];
    [main_prop setScale:DEFAULT_SCALE];
    [arm setScale:DEFAULT_SCALE];
    [main_nut setScale:DEFAULT_SCALE];
    [aux_nut setScale:DEFAULT_SCALE];
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

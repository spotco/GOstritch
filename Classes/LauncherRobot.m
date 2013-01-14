#import "LauncherRobot.h"
#import "GameEngineLayer.h"

@implementation LauncherRobot

#define TRACK_SPD 7
#define ANIM_NORMAL 1
#define ANIM_ANGRY 2
#define ANIM_DEAD 3

#define RECOIL_TIME 10.0
#define RECOIL_DIST 40
#define RELOAD 200

#define REMOVE_BEHIND_BUFFER 500

#define ROCKETSPEED 4

#define DEFAULT_SCALE 0.75

+(LauncherRobot*)cons_x:(float)x y:(float)y dir:(Vec3D*)dir {
    return [[LauncherRobot node] cons_x:x y:y dir:dir];
}

+(void)explosion:(GameEngineLayer*)g at:(CGPoint)pt {
    for(int i = 0; i < 10; i++) {
        float r = ((float)i);
        r = r/5.0 * M_PI;
        float dvx = cosf(r)*10+float_random(0, 1);
        float dvy = sinf(r)*10+float_random(0, 1);
        [g add_particle:[RocketLaunchParticle init_x:pt.x y:pt.y vx:dvx vy:dvy]];
    }
}

//launcher_dead
-(id)cons_x:(float)x y:(float)y dir:(Vec3D*)tdir {
    [self setPosition:ccp(x,y)];
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_LAUNCHER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_LAUNCHER idname:@"launcher"]];
    dir = [Vec3D init_x:tdir.x y:tdir.y z:0];
    
    float tara = [self get_tar_angle_deg_self:position_ tar:ccp(position_.x+dir.x,position_.y+dir.y)];
    if (ABS(tara) > 90) {
        tara+=180;
        [body setScaleX:-DEFAULT_SCALE];
    } else {
        [body setScaleX:DEFAULT_SCALE];
    }
    [body setScaleY:DEFAULT_SCALE];
    starting_rot = tara;
    [self setRotation:tara];
    
    [self addChild:body];
    starting_pos = ccp(x,y);
    active = YES;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    if (busted) {
        if (self.current_island == NULL) {
            [GamePhysicsImplementation player_move:self with_islands:g.islands];
            [self setRotation:rotation_+25];
        }
        return;
    }
    
    if (position_.x + REMOVE_BEHIND_BUFFER < player.position.x) {
        return;
    }
    
    
    ct--;
    if (ct < 50) {
        ct%5==0?[self toggle]:0;
    } else {
        [self set_anim:ANIM_NORMAL];
    }
    
    if (recoilanim_timer > 0) {
        recoilanim_timer--;
        float pct = (recoilanim_timer)/RECOIL_TIME;
        [self setPosition:ccp(
            pct*(RECOIL_DIST)*(-dir.x)+starting_pos.x,
            pct*(RECOIL_DIST)*(-dir.y)+starting_pos.y)
         ];
    } else {
        [self setPosition:starting_pos];
    }
    
    if (ct <= 0) {
        ct = RELOAD;
        
        CGPoint noz = [self get_nozzle];
        [LauncherRobot explosion:g at:noz];
        
        Vec3D *rv = [Vec3D init_x:dir.x y:dir.y z:0];
        [rv scale:ROCKETSPEED];
        LauncherRocket *r = [LauncherRocket cons_at:noz vel:ccp(rv.x,rv.y)];
        [rv dealloc];
        
        [g add_gameobject:r];
        recoilanim_timer = RECOIL_TIME;
    }
    
    if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        if (player.dashing) {
            busted = YES;
            [self set_anim:ANIM_DEAD];
            int ptcnt = arc4random_uniform(4)+4;
            for(float i = 0; i < ptcnt; i++) {
                [g add_particle:[BrokenMachineParticle init_x:position_.x y:position_.y vx:float_random(-5, 5) vy:float_random(-3, 10)]];
            }
            
        }/* else if (!player.dead) {
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
        }*/
        
    }
    
}

-(float)get_tar_angle_deg_self:(CGPoint)s tar:(CGPoint)t {
    //calc coord:       cocos2d coord:
    //+                    +
    //---0              0---
    //-                    -
    float ccwt = [Common rad_to_deg:atan2f(t.y-s.y, t.x-s.x)];
    return ccwt > 0 ? 180-ccwt : -(180-ABS(ccwt));
}

-(CGPoint)get_nozzle {
    CGPoint pos = position_;
    Vec3D *v = [Vec3D init_x:dir.x y:dir.y z:0];
    [v scale:110];
    pos = [v transform_pt:pos];
    [v dealloc];
    return pos;
}

-(void)reset {
    [super reset];
    ct = 0;
    busted = NO;
    [self setRotation:starting_rot];
    self.current_island = NULL;
    [self set_anim:ANIM_NORMAL];
}

-(void)toggle {
    animtoggle = animtoggle == ANIM_ANGRY?ANIM_NORMAL:ANIM_ANGRY;
    [self set_anim:animtoggle];
}

-(void)set_anim:(int)t {
    CGRect r = [FileCache get_cgrect_from_plist:TEX_ENEMY_LAUNCHER idname:
                (t==ANIM_NORMAL?@"launcher":
                 (t==ANIM_ANGRY?@"launcher_angry":
                  @"launcher_dead"))];
    [body setTextureRect:r];
}

-(void)set_active:(BOOL)t_active {active = t_active;}
-(HitRect)get_hit_rect {return [Common hitrect_cons_x1:position_.x-50 y1:position_.y-20 wid:100 hei:40];}
-(void)dealloc {
    [dir dealloc];
    [super dealloc];
}

@end


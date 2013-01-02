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

#define PARTICLE_FREQ 10
#define REMOVE_BEHIND_BUFFER 500

#define ROCKETSPEED 4

+(LauncherRobot*)cons_x:(float)x y:(float)y {
    return [[LauncherRobot node] cons_x:x y:y];
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
-(id)cons_x:(float)x y:(float)y {
    [self setPosition:ccp(x,y)];
    body = [CCSprite spriteWithTexture:[Resource get_tex:TEX_ENEMY_LAUNCHER] 
                                  rect:[FileCache get_cgrect_from_plist:TEX_ENEMY_LAUNCHER idname:@"launcher"]];
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
        [self setPosition:ccp(pct*(RECOIL_DIST)+starting_pos.x,starting_pos.y)];
    } else {
        [self setPosition:starting_pos];
    }
    
    if (ct <= 0) {
        ct = RELOAD;
        
        CGPoint noz = [self get_nozzle];
        [LauncherRobot explosion:g at:noz];
        LauncherRocket *r = [LauncherRocket cons_at:noz vel:ccp(-ROCKETSPEED,0)];
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
            
        } else if (!player.dead) {
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
        }
        
    }
    
}

-(CGPoint)get_nozzle {
    CGPoint pos = position_;
    Vec3D *v = [Vec3D init_x:110 y:0 z:0];
    body.scale == 1 ? [v scale:-1] : 0;
    pos.x += v.x;
    [v dealloc];
    return pos;
}

-(void)reset {
    [super reset];
    ct = 0;
    [self setRotation:0];
    busted = NO;
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

@end


@implementation LauncherRocket


+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    return [[LauncherRocket spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROCKET]] cons_at:pt vel:vel];
}

-(id)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    [self setPosition:pt];
    v = vel;
    active = YES;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    [self setPosition:ccp(position_.x+v.x,position_.y+v.y)];
    
    ct++;
    ct%PARTICLE_FREQ==0?[g add_particle:[RocketLaunchParticle init_x:position_.x y:position_.y vx:-v.x vy:-v.y]]:0;
    
    if (position_.x + REMOVE_BEHIND_BUFFER < player.position.x) {
        kill = YES;
    }
    
    if (kill || ![Common hitrect_touch:[self get_hit_rect] b:[g get_world_bounds]]) {
        [g remove_gameobject:self];
        
    } else if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        
        if (player.dashing) {
            
        } else if (!player.dead) {
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
        }
        [LauncherRobot explosion:g at:position_];
        [g remove_gameobject:self];
        
    }
}
-(int)get_render_ord{ return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];}
-(void)reset{[super reset];kill = YES;}
-(void)set_active:(BOOL)t_active {active = t_active;}
-(HitRect)get_hit_rect {return [Common hitrect_cons_x1:position_.x-30 y1:position_.y-25 wid:60 hei:50];}

@end
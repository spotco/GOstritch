#import "LauncherRocket.h"
#import "LauncherRobot.h"
#import "JumpPadParticle.h"
#import "GameEngineLayer.h"

@implementation LauncherRocket

#define PARTICLE_FREQ 10
#define REMOVE_BEHIND_BUFFER 500

#define DEFAULT_SCALE 0.75


+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    return [[LauncherRocket spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROCKET]] cons_at:pt vel:vel];
}

-(id)cons_at:(CGPoint)pt vel:(CGPoint)vel {
    [self setPosition:pt];
    v = vel;
    active = YES;
    remlimit = -1;
    [self setRotation:[self get_tar_angle_deg_self:pt tar:ccp(pt.x+vel.x,pt.y+vel.y)]];
    [self setScale:DEFAULT_SCALE];
    return self;
}

-(void)update_position {
    [self setPosition:ccp(position_.x+v.x,position_.y+v.y)];
}

-(id)set_remlimit:(int)t {
    remlimit = t;
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    [super update:player g:g];
    [self update_position];
    
    ct++;
    ct%PARTICLE_FREQ==0?[g add_particle:[RocketLaunchParticle init_x:position_.x y:position_.y vx:-v.x vy:-v.y]]:0;
    
    if (position_.x + REMOVE_BEHIND_BUFFER < player.position.x) {
        kill = YES;
    } else if (remlimit != -1 && ct > remlimit) {
        kill = YES;
    }
    
    if (kill || ![Common hitrect_touch:[self get_hit_rect] b:[g get_world_bounds]]) {
        [g remove_gameobject:self];
        return;
        
    } else if ([Common hitrect_touch:[self get_hit_rect] b:[player get_hit_rect]]) {
        
        if (player.dashing) {
            
        } else if (!player.dead) {
            [player add_effect:[HitEffect init_from:[player get_default_params] time:40]];
            [DazedParticle init_effect:g tar:player time:40];
        }
        [LauncherRobot explosion:g at:position_];
        [g remove_gameobject:self];
        return;
        
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

-(int)get_render_ord{ return [GameRenderImplementation GET_RENDER_BTWN_PLAYER_ISLAND];}
-(void)reset{[super reset];kill = YES;}
-(void)set_active:(BOOL)t_active {active = t_active;}
-(HitRect)get_hit_rect {return [Common hitrect_cons_x1:position_.x-30 y1:position_.y-25 wid:60 hei:50];}

@end


@implementation RelativePositionLauncherRocket

+(RelativePositionLauncherRocket*)cons_at:(CGPoint)pt player:(CGPoint)player vel:(CGPoint)vel {
    return [[RelativePositionLauncherRocket spriteWithTexture:[Resource get_tex:TEX_ENEMY_ROCKET]] cons_at:pt player:player vel:vel];
}

-(id)cons_at:(CGPoint)pt player:(CGPoint)player vel:(CGPoint)vel {
    player_pos = player;
    [self setPosition:pt];
    rel_pos = ccp(pt.x-player.x,0);
    v = vel;
    [self update_position];
    [self setScale:DEFAULT_SCALE];
    
    active = YES;
    [self setRotation:[self get_tar_angle_deg_self:pt tar:ccp(pt.x+vel.x,pt.y+vel.y)]];
    return self;
}

-(void)update:(Player *)player g:(GameEngineLayer *)g {
    player_pos = player.position;
    rel_pos.x += v.x;
    [super update:player g:g];
}

-(void)update_position {
    //only for horizontal relative, todo: make general
    [self setPosition:ccp(rel_pos.x+player_pos.x,position_.y+v.y)];
}

@end

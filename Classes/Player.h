#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"
#import "Common.h"
#import "StreamParticle.h"
#import "RocketParticle.h"
#import "FloatingSweatParticle.h"
#import "FileCache.h"

@class SwingVine;

@class GameEngineLayer;

@class PlayerEffectParams;

@interface Player : CCSprite <PhysicsObject> {
	float vx,vy;
	CCSprite* player_img;
    Island* current_island;
    Vec3D* up_vec;
    
    CGPoint start_pt;
    
    PlayerEffectParams *current_params;
    PlayerEffectParams *temp_params;
    int last_ndir;
    BOOL floating;
    BOOL dashing;
    SwingVine* current_swingvine;
    BOOL dead;
    
    int particlectr;
    
    GameEngineLayer* game_engine_layer;
}

typedef enum {
    player_anim_mode_RUN,
    player_anim_mode_CAPE,
    player_anim_mode_ROCKET,
    player_anim_mode_HIT,
    player_anim_mode_SPLASH,
    player_anim_mode_DASH
} player_anim_mode;

+(void)set_character:(NSString*)tar;
+(NSString*)get_character;

+(Player*)init_at:(CGPoint)pt;
-(void)init_anim;
-(void)add_effect:(PlayerEffectParams*)effect;
-(void)reset;
-(void)reset_params;
-(void)remove_temp_params:(GameEngineLayer*)g;
-(void)update:(GameEngineLayer*)g;

-(void)cleanup_anims;

-(HitRect) get_hit_rect;
-(HitRect) get_hit_rect_ignore_noclip;
-(void)add_effect_suppress_current_end_effect:(PlayerEffectParams *)effect;
-(PlayerEffectParams*) get_current_params;
-(PlayerEffectParams*) get_default_params;

@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) int last_ndir;
@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) Vec3D* up_vec;
@property(readwrite,assign) CGPoint start_pt;
@property(readwrite,assign) BOOL floating,dashing,dead;
@property(readwrite,assign) SwingVine* current_swingvine;

@property(readwrite,assign) id current_anim;
@property(readwrite,assign) id _RUN_ANIM_SLOW,_RUN_ANIM_MED,_RUN_ANIM_FAST,_RUN_ANIM_NONE;
@property(readwrite,assign) id _ROCKET_ANIM,_CAPE_ANIM,_HIT_ANIM,_SPLASH_ANIM, _DASH_ANIM, _SWING_ANIM;

@end

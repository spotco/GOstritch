#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"
#import "Common.h"
#import "StreamParticle.h"
#import "RocketParticle.h"
#import "FloatingSweatParticle.h"
#import "FileCache.h"

@interface Player : CCSprite <PhysicsObject> {
	CCSprite* player_img;
    CGPoint start_pt;
    PlayerEffectParams *current_params;
    PlayerEffectParams *temp_params;
    BOOL dashing;
    BOOL dead;
    int particlectr;
    
    int prevndir;
    int flipctr;
    
    int cur_scy;
    int inair_ct;
    
    GameEngineLayer* game_engine_layer;
}

typedef enum {
    player_anim_mode_RUN,
    player_anim_mode_CAPE,
    player_anim_mode_ROCKET,
    player_anim_mode_HIT,
    player_anim_mode_SPLASH,
    player_anim_mode_DASH,
    player_anim_mode_FLASH
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
-(HitRect) get_jump_rect;
-(void)add_effect_suppress_current_end_effect:(PlayerEffectParams *)effect;
-(PlayerEffectParams*) get_current_params;
-(PlayerEffectParams*) get_default_params;

@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) CGPoint start_pt;
@property(readwrite,assign) BOOL dashing,dead;

@property(readwrite,assign) id current_anim;
@property(readwrite,assign) id _RUN_ANIM_SLOW,_RUN_ANIM_MED,_RUN_ANIM_FAST,_RUN_ANIM_NONE;
@property(readwrite,assign) id _ROCKET_ANIM,_CAPE_ANIM,_HIT_ANIM,_SPLASH_ANIM, _DASH_ANIM, _SWING_ANIM, _FLASH_ANIM, _FLIP_ANIM;

@end

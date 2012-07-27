#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"
#import "Common.h"
@class GameEngineLayer;

@class PlayerEffectParams;

@interface Player : CCSprite {
	float vx,vy;
	CCSprite* player_img;
    Island* current_island;
    Vec3D* up_vec;
    
    CGPoint start_pt;
    
    PlayerEffectParams *current_params;
    PlayerEffectParams *temp_params;
}

typedef enum {
    player_anim_mode_RUN,
    player_anim_mode_CAPE,
    player_anim_mode_ROCKET,
    player_anim_mode_HIT
} player_anim_mode;

+(Player*)init_at:(CGPoint)pt;
-(void)init_anim;
-(void)add_effect:(PlayerEffectParams*)effect;
-(void) reset;
-(void) reset_params;
-(void) update:(GameEngineLayer*)g;
-(HitRect) get_hit_rect;
-(PlayerEffectParams*) get_current_params;
-(PlayerEffectParams*) get_default_params;

@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) Vec3D* up_vec;
@property(readwrite,assign) CGPoint start_pt;

@end

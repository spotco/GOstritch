#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"
#import "PlayerEffectParams.h"
#import "Common.h"

@interface Player : CCSprite {
	float vx,vy;
	CCSprite* player_img;
    Island* current_island;
    Vec3D* up_vec;
    
    CGPoint start_pt;
    
    PlayerEffectParams *current_params;
    PlayerEffectParams *temp_params;
}

+(Player*)init_at:(CGPoint)pt;
-(void)add_effect:(PlayerEffectParams*)effect;
-(void) reset;
-(void) reset_params;
-(void) update;
-(HitRect) get_hit_rect;
-(PlayerEffectParams*) get_current_params;

@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) Vec3D* up_vec;
@property(readwrite,assign) CGPoint start_pt;

@end

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Common.h"

@interface Player : CCSprite {
	float vx,vy;
	CCSprite* player_img;
    Island* current_island;
    Vec3D* up_vec;
    
    float rotate_to;
    
    float touch_count;
    float airjump_count;
}

-(CGRect) get_hit_rect;


+(BOOL)player_move:(Player*)player with_islands:(NSMutableArray*)islands;

+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands;
+(CGPoint)player_move_along_island:(Player*)player islands:(NSMutableArray*)islands;

@property(readwrite,assign) float vx,vy,touch_count,airjump_count,rotate_to;
@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) Vec3D* up_vec;

@end

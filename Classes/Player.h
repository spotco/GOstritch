#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Resource.h"

@interface Player : CCSprite {
	float vx,vy;
	CCSprite* player_img;
    Island* current_island;
    Vec3D* up_vec;
    
}

-(CGRect) get_hit_rect;

/*+(void)player_move:(Player*)player with_islands:(NSMutableArray*)islands;
+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands;
+(CGPoint)player_move_along_island:(Player*)player islands:(NSMutableArray*)islands;
*/
 
@property(readwrite,assign) float vx,vy;
@property(readwrite,assign) CCSprite* player_img;
@property(readwrite,assign) Island* current_island;
@property(readwrite,assign) Vec3D* up_vec;

@end

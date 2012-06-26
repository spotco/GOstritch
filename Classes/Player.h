#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Island.h"
#import "Common.h"

@interface Player : CCSprite {
	float vx,vy;
	CCSprite* player_img;
    
    float touch_count;
    float airjump_count;
}

-(CGRect) get_hit_rect;
+(BOOL)player_move:(Player*)player with_islands:(NSMutableArray*)islands;

+(CGPoint)player_free_fall:(Player*)player islands:(NSMutableArray*)islands pos_x:(float)pos_x pos_y:(float)pos_y;
+(CGPoint)player_move_along_island:(Player*)player contact_island:(Island*)contact_island islands:(NSMutableArray*)islands pos_x:(float)pos_x pos_y:(float)pos_y post_y:(float)post_y;
+(Island*)find_contact_island:(NSMutableArray*)islands pre_y:(float)pre_y post_y:(float)post_y pos_x:(float)pos_x;

@property(readwrite,assign) float vx,vy,touch_count,airjump_count;
@property(readwrite,assign) CCSprite* player_img;

@end

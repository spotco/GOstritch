#import "cocos2d.h"
#import "CJSONDeserializer.h"
#import "LineIsland.h"
#import "Island.h"
#import "Player.h"
#import "Common.h"
#import "Coin.h"
#import "GameObject.h"
#import "BGLayer.h"
#import "Resource.h"
#import "MapLoader.h"
#import "CurveIsland.h"

@interface GameEngineLayer : CCLayer {
	NSMutableArray *islands;
    NSMutableArray *game_objects;
	Player *player;
    
    
	BOOL is_touch;
}

+(float) get_cur_pos_x;
+(float) get_cur_pos_y;

+(CCScene *) scene;
+(NSMutableArray*) loadIslands;

-(CGRect) get_world_bounds;
-(void) loadMap;
-(void) check_sort_islands_given:(float)pos_x and:(float)pos_y;
-(CGPoint) player_move_x:(float)pos_x y:(float)pos_y;
-(void) check_game_state;
-(void) update_static_x:(float)pos_x y:(float)pos_y;
-(void) player_control_update:(BOOL)is_contact;

@end

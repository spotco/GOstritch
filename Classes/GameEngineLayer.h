#import "cocos2d.h"
#import "Island.h"
#import "Player.h"
#import "Common.h"
#import "GameObject.h"
#import "BGLayer.h"
#import "UILayer.h"
#import "Resource.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "GameRenderImplementation.h"
#import "GameControlImplementation.h"
#import "GameControlState.h"
#import "GameRenderState.h"

@interface GameEngineLayer : CCLayer {
	NSMutableArray *islands;
    NSMutableArray *game_objects;

	Player *player;
    GameControlState *game_control_state;
    GameRenderState *game_render_state;
    
    BOOL paused;
}

@property(readwrite,assign) BOOL paused;


+(float) get_cur_pos_x;
+(float) get_cur_pos_y;

+(CCScene *) scene_with:(NSString *) map_file_name of_type:(NSString *) map_file_type;
-(HitRect) get_world_bounds;
-(CGPoint) loadMap;
-(void) check_game_state;
-(void) update_static_x:(float)pos_x y:(float)pos_y;
-(void) update_game_obj;

+(BOOL)singleton_toggle_pause;

@end

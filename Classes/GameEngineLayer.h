#import "cocos2d.h"
#import "Island.h"
#import "Player.h"
#import "Common.h"
#import "GameObject.h"
@class BGLayer;
#import "UILayer.h"
#import "Resource.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "GameRenderImplementation.h"
#import "GameControlImplementation.h"
#import "GameControlState.h"
#import "GameRenderState.h"

typedef enum {
    GameEngineLayerMode_GAMEPLAY,
    GameEngineLayerMode_PAUSED,
    GameEngineLayerMode_ENDOUT
} GameEngineLayerMode;

@interface GameEngineLayer : CCLayer {
	NSMutableArray *islands;
    NSMutableArray *game_objects;

	Player *player;
    GameControlState *game_control_state;
    GameRenderState *game_render_state;
    
    CCFollow *follow_action;
    
    GameEngineLayerMode current_mode;
    BOOL paused;
}


@property(readwrite,assign) BOOL paused;

+(CCScene *) scene_with:(NSString *)map_file_name;
-(HitRect) get_world_bounds;
-(CGPoint) loadMap:(NSString*)filename;
-(void) check_game_state;
-(void) update_game_obj;

-(CGPoint)get_pos;

@end

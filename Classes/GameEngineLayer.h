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
    
    CGPoint map_start_pt;
    CCFollow *follow_action;
    
    GameEngineLayerMode current_mode;
    BOOL paused;
}


@property(readwrite,assign) BOOL paused;
@property(readwrite,assign) NSMutableArray *islands, *game_objects;

+(CCScene *) scene_with:(NSString *)map_file_name;
-(void)player_reset;
-(CGPoint)get_pos;

@end

#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Player.h"
#import "Island.h"
#import "GameObject.h"
#import "PlayerEffectParams.h"
@class GameEngineLayer;

@interface GameRenderImplementation:NSObject

+(void)update_render_on:(GameEngineLayer*)g;
+(void)reset_camera:(CameraZoom*)c;
+(void)update_camera_on:(CCLayer*)layer zoom:(CameraZoom)state;

+(int)GET_RENDER_FG_ISLAND_ORD;
+(int)GET_RENDER_PLAYER_ORD;
+(int)GET_RENDER_ISLAND_ORD;
+(int)GET_RENDER_GAMEOBJ_ORD;
+(int)GET_RENDER_BTWN_PLAYER_ISLAND;

@end

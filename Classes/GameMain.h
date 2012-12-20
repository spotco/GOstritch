#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "GameEngineLayer.h"
#import "MainMenuLayer.h"

@interface GameMain : NSObject

+(void)main;
+(void)start_game_autolevel;
+(void)start_menu;
+(void)start_testlevel;

+(BOOL)GET_USE_BG;
+(BOOL)GET_ENABLE_BG_PARTICLES;
+(BOOL)GET_DRAW_HITBOX;
+(float)GET_TARGET_FPS;

@end

#import <Foundation/Foundation.h>
#import "cocos2d.h"

#import "GameEngineLayer.h"
#import "MainMenuLayer.h"
#import "DataStore.h"
#import "AudioManager.h"
#import "Common.h"

@interface GameMain : NSObject

+(void)main;
+(void)start_game_autolevel;
+(void)start_menu;
+(void)start_testlevel;
+(void)start_game_bosstestlevel;
+(void)start_swingtestlevel;

+(BOOL)GET_USE_BG;
+(BOOL)GET_ENABLE_BG_PARTICLES;
+(BOOL)GET_DRAW_HITBOX;
+(float)GET_TARGET_FPS;
+(BOOL)GET_USE_NSTIMER;
+(BOOL)GET_HOLD_TO_STOP;
+(BOOL)GET_DEBUG_UI;

@end

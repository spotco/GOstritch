#import "GameMain.h"

@implementation GameMain

#define USE_BG NO
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO
#define TARGET_FPS 60
#define RESET_STATS NO
#define DISPLAY_FPS NO
#define USE_NSTIMER NO
#define STARTING_LIVES 2
#define TESTLEVEL @"shittytest"

/**
 TODO -- 
 -minion robot, boss robot + lab
 -fix: forward cache autolevel away a certain distance
 
 -fix: tap when snapto reverts
 
 -fix loadlevel + gameend_ui stuff
 **/

+(void)main {
    [GEventDispatcher lazy_alloc];
    [DataStore init];
    [Resource init_textures];
    if (RESET_STATS) [DataStore reset_all];
    [[CCDirector sharedDirector] setDisplayFPS:DISPLAY_FPS];
    
    [GameMain start_testlevel];
    //[GameMain start_game_autolevel];
    //[GameMain start_menu];
}

+(void)start_game_autolevel {
    [[CCDirector sharedDirector] runningScene] ? 
    [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with_autolevel_lives:STARTING_LIVES]] :
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with_autolevel_lives:STARTING_LIVES]];
}
+(void)start_menu {
    [[CCDirector sharedDirector] runningScene]?
    [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]]:
    [[CCDirector sharedDirector] runWithScene:[MainMenuLayer scene]];
}
+(void)start_testlevel {
    [[CCDirector sharedDirector] runningScene]?
    [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with:@"shittytest" lives:GAMEENGINE_INF_LIVES]]:
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"shittytest" lives:GAMEENGINE_INF_LIVES]];
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_ENABLE_BG_PARTICLES {return ENABLE_BG_PARTICLES;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
+(float)GET_TARGET_FPS {return 1.0/TARGET_FPS;}
+(BOOL)GET_USE_NSTIMER {return USE_NSTIMER;};
@end

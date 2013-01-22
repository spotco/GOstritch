#import "GameMain.h"

@implementation GameMain

#define USE_BG NO
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO
#define TARGET_FPS 60
#define RESET_STATS NO
#define DISPLAY_FPS NO
#define DEBUG_UI NO
#define USE_NSTIMER NO
#define HOLD_TO_STOP NO
#define STARTING_LIVES 1
#define TESTLEVEL @"robotstest"

/**
 TODO -- 
 -add electric,labentrance,labexit,uienemyalert to leveleditor
 
 -ui enemy alert
 -different death anims for electricity
 -more moves for boss, and damage show
 
 -add in that sun
 -player run in animation
 -different dogs differnt special powers
    ideas: higher jump, more float power, longer dash, faster, auto item magnet
 **/

+(void)main {
    [GEventDispatcher lazy_alloc];
    [DataStore init];
    [Resource init_textures];
    [BatchDraw init];
    
    if (RESET_STATS) [DataStore reset_all];
    [[CCDirector sharedDirector] setDisplayFPS:DISPLAY_FPS];
    
    [GameMain start_testlevel];
    //[GameMain start_game_autolevel];
    //[GameMain start_menu];
    //[GameMain start_game_bosstestlevel];
    
}

+(void)start_game_autolevel {
    [AutoLevel SET_DEBUG_MODE:0];
    [GameMain run_scene:[GameEngineLayer scene_with_autolevel_lives:STARTING_LIVES]];
}
+(void)start_menu {
    [GameMain run_scene:[MainMenuLayer scene]];
}
+(void)start_game_bosstestlevel {
    [AutoLevel SET_DEBUG_MODE:1];
    [GameMain run_scene:[GameEngineLayer scene_with_autolevel_lives:STARTING_LIVES]];
}
+(void)start_testlevel {
    [GameMain run_scene:[GameEngineLayer scene_with:TESTLEVEL lives:GAMEENGINE_INF_LIVES]];
}
+(void)start_swingtestlevel {
    [GameMain run_scene:[GameEngineLayer scene_with:@"swingvine_test" lives:GAMEENGINE_INF_LIVES]];
}
+(void)run_scene:(CCScene*)s {
    [[CCDirector sharedDirector] runningScene]?
    [[CCDirector sharedDirector] replaceScene:s]:
    [[CCDirector sharedDirector] runWithScene:s];
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_ENABLE_BG_PARTICLES {return ENABLE_BG_PARTICLES;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
+(float)GET_TARGET_FPS {return 1.0/TARGET_FPS;}
+(BOOL)GET_USE_NSTIMER {return USE_NSTIMER;}
+(BOOL)GET_HOLD_TO_STOP {return HOLD_TO_STOP;}
+(BOOL)GET_DEBUG_UI {return DEBUG_UI;}
@end

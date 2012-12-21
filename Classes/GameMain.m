#import "GameMain.h"

@implementation GameMain

#define USE_NSTIMER NO
#define USE_BG NO
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO
#define TARGET_FPS 60
#define RESET_STATS NO
#define DISPLAY_FPS NO


/**
 TODO -- 
 -swing vine animations and variable length
 -minion robot, boss robot + lab
 -forward cache autolevel
 
 -score tracking
 -fix loadlevel + gameend_ui stuff
 **/

+(void)main {
    [DataStore init];
    [Resource init_textures];
    if (RESET_STATS) [DataStore reset_all];
    [[CCDirector sharedDirector] setDisplayFPS:DISPLAY_FPS];
    
    [GameMain start_menu];
}

+(void)start_game_autolevel {
    if ([[CCDirector sharedDirector] runningScene]) {
        [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with_autolevel]];
    } else {
        [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with_autolevel]];
    }
    
}
+(void)start_menu {
    if ([[CCDirector sharedDirector] runningScene]) {
        [[CCDirector sharedDirector] replaceScene:[MainMenuLayer scene]];
    } else {
        [[CCDirector sharedDirector] runWithScene:[MainMenuLayer scene]];
    }
}
+(void)start_testlevel {
    if ([[CCDirector sharedDirector] runningScene]) {
        [[CCDirector sharedDirector] replaceScene:[GameEngineLayer scene_with:@"shittytest"]];
    } else {
        [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"shittytest"]];
    }
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_ENABLE_BG_PARTICLES {return ENABLE_BG_PARTICLES;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
+(float)GET_TARGET_FPS {return 1.0/TARGET_FPS;}
+(BOOL)GET_USE_NSTIMER {return USE_NSTIMER;};
@end

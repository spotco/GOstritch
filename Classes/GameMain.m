#import "GameMain.h"
#import "PolyLib.h"

@implementation GameMain

#define USE_BG YES
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO
#define TARGET_FPS 60


/**
 TODO --
 -lives + score
 -swing vine animations and variable length
 -minion robot, boss robot + lab
 -menu work, infinite mode and levels mode
 -forward cache autolevel
 -fix some rendering order problems
 **/

+(void)main {
    [[CCDirector sharedDirector] setDisplayFPS:NO];
    //[[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    //[[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"shittytest"]];
    [[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with_autolevel]];
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_ENABLE_BG_PARTICLES {return ENABLE_BG_PARTICLES;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
+(float)GET_TARGET_FPS {return 1.0/TARGET_FPS;}
@end

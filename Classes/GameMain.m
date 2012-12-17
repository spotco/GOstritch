#import "GameMain.h"
#import "PolyLib.h"

@implementation GameMain

#define USE_BG NO
#define ENABLE_BG_PARTICLES YES
#define DRAW_HITBOX NO


/**
 TODO --
 -menu work, lives + score
 
 -minion robot, boss robot
 -swing vine animations and variable length
 **/

+(void)main {
    //[[CCDirector sharedDirector] setDisplayFPS:YES];
    [[CCDirector sharedDirector] runWithScene:[CoverPage scene]];
    //[[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with:@"shittytest"]];
    //[[CCDirector sharedDirector] runWithScene:[GameEngineLayer scene_with_autolevel]];
}

+(BOOL)GET_USE_BG {return USE_BG;}
+(BOOL)GET_ENABLE_BG_PARTICLES {return ENABLE_BG_PARTICLES;}
+(BOOL)GET_DRAW_HITBOX {return DRAW_HITBOX;}
@end

#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

typedef enum {
    AutoLevelMode_Normal,
    AutoLevelMode_BOSS1
} AutoLevelMode;

@interface AutoLevel : GameObject <GEventListener> {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections; //current ingame mapsections
    NSMutableArray* queued_sections; //next mapsections
    NSMutableArray* stored; //past, not removed yet
    
    AutoLevelMode cur_mode;
    //int ct;
    
    BOOL has_pos_initial;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;
+(void)SET_DEBUG_MODE:(int)t;
-(NSString*)get_debug_msg;

@end

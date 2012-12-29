#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

@interface AutoLevel : GameObject <GEventListener> {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections; //current ingame mapsections
    NSMutableArray* queued_sections; //next mapsections
    NSMutableArray* stored; //past, not removed yet
    //int ct;
    
    BOOL has_pos_initial;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;

@end

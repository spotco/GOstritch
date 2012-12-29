#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

@interface AutoLevel : GameObject <GEventListener> {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections; //current ingame mapsections
    NSMutableArray* queued_sections;
    NSMutableArray* stored; //past, not removed yet
    int ct;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;

@end

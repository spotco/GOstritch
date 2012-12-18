#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

@interface AutoLevel : GameObject <GEventListener> {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections;
    NSMutableArray* stored;
    int ct;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;
-(void)cleanup:(CGPoint)player_startpt;

@end

#import "GameObject.h"
#import "MapLoader.h"
#import "MapSection.h"

@interface AutoLevel : GameObject {
    GameEngineLayer* tglayer;
    float cur_x,cur_y;
    NSMutableArray* map_sections;
    int ct;
}

+(AutoLevel*)init_with_glayer:(GameEngineLayer*)glayer;
-(void)cleanup:(CGPoint)player_startpt;

@end

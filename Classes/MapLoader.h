#import <Foundation/Foundation.h>
#import "CJSONDeserializer.h"

#import "LineIsland.h"
#import "Island.h"
#import "CaveLineIsland.h"
#import "BridgeIsland.h"
#import "LabLineIsland.h"

#import "DogBone.h"
#import "GroundDetail.h"
#import "DogCape.h"
#import "DogRocket.h"
#import "CheckPoint.h"
#import "GameEndArea.h"
#import "Spike.h"
#import "Water.h"
#import "JumpPad.h"
#import "BirdFlock.h"
#import "Blocker.h"
#import "SpeedUp.h"
#import "CaveWall.h"
#import "IslandFill.h"
#import "BreakableWall.h"
#import "SpikeVine.h"
#import "CameraArea.h"
#import "SwingVine.h"
#import "MinionRobot.h"
#import "LauncherRobot.h"
#import "FadeOutLabWall.h"
#import "CopterRobotLoader.h"
#import "ElectricWall.h"
#import "LabEntrance.h"

@interface MapLoader : NSObject

typedef struct GameMap {
    NSMutableArray *n_islands, *game_objects;
    CGPoint player_start_pt;
    int assert_links;
    float connect_pts_x1,connect_pts_x2,connect_pts_y1,connect_pts_y2;
} GameMap;

+(GameMap) load_map:(NSString *)map_file_name;
+(void) precache_map:(NSString *)map_file_name;

@end

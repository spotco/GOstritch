#import "cocos2d.h"
#import "DataStore.h"
#import "Island.h"
#import "Player.h"
#import "Common.h"
#import "GameObject.h"
#import "Particle.h"
#import "GEventDispatcher.h"
@class BGLayer;
@class UILayer;
#import "Resource.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "GameRenderImplementation.h"
#import "GameControlImplementation.h"
#import "AutoLevel.h"
#import "World1ParticleGenerator.h"

#define GAMEENGINE_INF_LIVES -99

typedef enum {
    GameEngineLayerMode_GAMEPLAY,
    GameEngineLayerMode_PAUSED,
    GameEngineLayerMode_UIANIM,
    GameEngineLayerMode_GAMEOVER
} GameEngineLayerMode;

typedef struct level_bone_status {
    int togets;
    int savedgets;
    int hasgets;
    int alreadygets;
} level_bone_status;

@interface GameEngineLayer : CCLayer <GEventListener> {
    NSTimer *updater;
    
	NSMutableArray *islands;
    NSMutableArray *game_objects;
    NSMutableArray *particles;
    CameraZoom camera_state;
    CameraZoom tar_camera_state;
    
    int lives;
    int time;
    
    NSMutableDictionary *bones;
	Player *player;
    CCFollow *follow_action;
    GameEngineLayerMode current_mode;
    
    BOOL refresh_bone_cache;
    level_bone_status cached_status;
    BOOL refresh_viewbox_cache;
    HitRect cached_viewbox;
    BOOL refresh_worldbounds_cache;
    HitRect cached_worldsbounds;
}


@property(readwrite,assign) GameEngineLayerMode current_mode;
@property(readwrite,assign) NSMutableArray *islands, *game_objects;
@property(readwrite,assign) Player *player;
@property(readwrite,assign) CameraZoom camera_state,tar_camera_state;
@property(readwrite,assign) CCFollow *follow_action; 

+(CCScene *) scene_with:(NSString *)map_file_name lives:(int)lives;
+(CCScene*) scene_with_autolevel_lives:(int)lives;
-(void)add_particle:(Particle*)p;

-(HitRect)get_viewbox;
-(HitRect) get_world_bounds;

-(void)set_camera:(CameraZoom)tar;
-(void)set_target_camera:(CameraZoom)tar;

-(void)add_bone:(DogBone*)c autoassign:(BOOL)aa;
-(void)set_bid_tohasget:(int)tbid;
-(level_bone_status)get_bonestatus;

-(int)get_lives;
-(int)get_time;

-(void)setColor:(ccColor3B)color;

@end

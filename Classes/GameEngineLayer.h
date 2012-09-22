#import "cocos2d.h"
#import "Island.h"
#import "Player.h"
#import "Common.h"
#import "GameObject.h"
#import "Particle.h"
@class BGLayer;
@class UILayer;
#import "Resource.h"
#import "MapLoader.h"
#import "GamePhysicsImplementation.h"
#import "GameRenderImplementation.h"
#import "GameControlImplementation.h"

#import "World1ParticleGenerator.h"

typedef enum {
    GameEngineLayerMode_UIANIM,
    GameEngineLayerMode_GAMEPLAY,
    GameEngineLayerMode_PAUSED,
    GameEngineLayerMode_ENDOUT,
    GameEngineLayerMode_ENDED,
    GameEngineLayerMode_OBJECTANIM
} GameEngineLayerMode;

typedef struct level_bone_status {
    int togets;
    int savedgets;
    int hasgets;
    int alreadygets;
} level_bone_status;

@interface GameEngineLayer : CCLayer {
	NSMutableArray *islands;
    NSMutableArray *game_objects;
    NSMutableArray *particles;
    CameraZoom camera_state;
    CameraZoom tar_camera_state;
    
    NSMutableDictionary *bones;

	Player *player;
    
    CGPoint map_start_pt;
    CCFollow *follow_action;
    
    GameEngineLayerMode current_mode;
    
    callback bg_update;
    callback ui_update;
    callback load_game_end_menu;
    callback bone_collect_ui_animation;
}


@property(readwrite,assign) GameEngineLayerMode current_mode;
@property(readwrite,assign) NSMutableArray *islands, *game_objects;
@property(readwrite,assign) Player* player;
@property(readwrite,assign) callback load_game_end_menu;
@property(readwrite,assign) CameraZoom camera_state,tar_camera_state;

+(CCScene *) scene_with:(NSString *)map_file_name;
-(void)player_reset;
-(void)add_particle:(Particle*)p;
-(CGPoint)get_pos;
-(HitRect)get_viewbox;

-(void)set_camera:(CameraZoom)tar;
-(void)set_target_camera:(CameraZoom)tar;

-(void)set_checkpoint_to:(CGPoint)pt;
-(void)set_bid_tohasget:(int)tbid;
-(level_bone_status)get_bonestatus;

-(void)setColor:(ccColor3B)color;

@end

#import "CCLayer.h"
#import "Resource.h"
#import "GameEngineLayer.h"
#import "GameStartAnim.h"
#import "UIIngameAnimation.h"
#import "BoneCollectUIAnimation.h"
#import "GEventDispatcher.h"

@interface UILayer : CCLayer <GEventListener> {
    GameEngineLayer* game_engine_layer;
    
    CCNode *ingame_ui,*pause_ui,*gameover_ui;
    CCLabelTTF *lives_disp, *bones_disp, *time_disp;
    
    CCLabelTTF *gameover_bones_disp, *gameover_time_disp;
    
    
    CCLayer *game_end_menu_layer; //todo, change to ui too
    
    UIAnim *curanim;
    NSMutableArray* ingame_ui_anims;
}

+(UILayer*)init_with_gamelayer:(GameEngineLayer*)g;

-(void)start_initial_anim;

@end

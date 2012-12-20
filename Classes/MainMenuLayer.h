#import "CCLayer.h"
#import "Resource.h"
#import "MainMenuPage.h"
#import "Common.h"
#import "GEventDispatcher.h"
#import "GameEngineLayer.h"

#import "PlayAutoPage.h"

@interface MainMenuBGLayer : CCLayer <GEventListener>
+(MainMenuBGLayer*)cons;
@end

@interface MainMenuPageStaticLayer : CCLayer <GEventListener> {
    NSMutableArray* indicator_pts;
}
+(MainMenuPageStaticLayer*)cons;
@end

typedef enum {
    MainMenuState_TouchDown,
    MainMenuState_Snapping,
    MainMenuState_None
} MainMenuState;

@interface MainMenuLayer : CCLayer <GEventListener> {
    MainMenuBGLayer* bg;
    NSMutableArray* menu_pages;
    int cur_page;
    CameraZoom cpos;
    
    CGPoint last,dp;
    BOOL killdrag;
    
    MainMenuState cstate;
}

+(CCScene*)scene;

@end
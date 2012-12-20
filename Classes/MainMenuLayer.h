#import "CCLayer.h"
#import "Resource.h"
#import "MainMenuPage.h"
#import "Common.h"
#import "GEventDispatcher.h"
#import "GameEngineLayer.h"

#import "MainMenuPageStaticLayer.h"
#import "MainMenuBGLayer.h"

#import "DogModePage.h"
#import "PlayAutoPage.h"
#import "SettingsPage.h"
#import "StatsPage.h"

#define MENU_STARTING_PAGE_ID 1
#define MENU_DOG_MODE_PAGE_ID 0
#define MENU_SETTINGS_PAGE_ID 2
#define MENU_STATS_PAGE_ID 3

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
#import "CCLayer.h"
#import "Resource.h"
#import "MainMenuPage.h"
#import "Common.h"
#import "GEventDispatcher.h"

#import "PlayAutoPage.h"

@interface MainMenuBGLayer : CCLayer <GEventListener>
+(MainMenuBGLayer*)initialize;
@end

@interface MainMenuLayer : CCLayer {
    MainMenuBGLayer* bg;
    NSMutableArray* menu_pages;
    CameraZoom cpos;
    
    CGPoint last;
    CGPoint dp;
}

+(CCScene*)scene;

@end
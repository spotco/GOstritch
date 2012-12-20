#import "cocos2d.h"
#import "GEventDispatcher.h"
#import "MainMenuPage.h"
#import "Player.h"


@interface MainMenuPageStaticLayer : CCLayer <GEventListener> {
    NSMutableArray* indicator_pts;
    NSMutableArray* interactive_items;
    
    MainMenuPageZoomButton* ccbtn;
    
    CCSprite* animp;
    CCAction* cur_char_anim;
    NSString* cur_disp_char;
}
+(MainMenuPageStaticLayer*)cons;
@end

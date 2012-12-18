#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "UIAnim.h"
#import "Resource.h"

@interface GameStartAnim : UIAnim {
    CCSprite* readyimg;
    CCSprite* goimg;
    
    int ct;
}

+(GameStartAnim*)init_with_callback:(callback)cb;

@end

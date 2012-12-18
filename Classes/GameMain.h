#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "CoverPage.h"

@interface GameMain : NSObject

+(void)main;

+(BOOL)GET_USE_BG;
+(BOOL)GET_ENABLE_BG_PARTICLES;
+(BOOL)GET_DRAW_HITBOX;
+(float)GET_TARGET_FPS;

@end

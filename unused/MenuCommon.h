#import "cocos2d.h"
#import "Common.h"

@interface MenuCommon : NSObject

+(CCMenuItem*)make_button_img:(NSString*)imgfile imgsel:(NSString*)imgselfile onclick_target:(NSObject*)tar selector:(SEL)sel;

+(CCMenuItem*)make_button_tex:(CCTexture2D*)tex seltex:(CCTexture2D*)seltex callback:(callback)cb;
+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale;

@end

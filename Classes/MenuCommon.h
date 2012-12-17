#import "cocos2d.h"

@interface MenuCommon : NSObject

+(CCMenuItem*)make_button_img:(NSString*)imgfile imgsel:(NSString*)imgselfile onclick_target:(NSObject*)tar selector:(SEL)sel;
+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale;

@end

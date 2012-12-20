#import "MenuCommon.h"

@implementation MenuCommon

+(CCMenuItem*)make_button_img:(NSString*)imgfile imgsel:(NSString*)imgselfile onclick_target:(NSObject*)tar selector:(SEL)sel {
    CCSprite *img = [CCSprite spriteWithFile:imgfile];
    CCSprite *img_zoom = [CCSprite spriteWithFile:imgselfile];
    [MenuCommon set_zoom_pos_align:img zoomed:img_zoom scale:1.2];
    return [CCMenuItemImage itemFromNormalSprite:img selectedSprite:img_zoom target:tar selector:sel];
}

+(CCMenuItem*)make_button_tex:(CCTexture2D*)tex seltex:(CCTexture2D*)seltex callback:(callback)cb {
    CCSprite *img = [CCSprite spriteWithTexture:tex];
    CCSprite *img_zoom = [CCSprite spriteWithTexture:seltex];
    [MenuCommon set_zoom_pos_align:img zoomed:img_zoom scale:1.2];
    return [CCMenuItemImage itemFromNormalSprite:img selectedSprite:img_zoom target:cb.target selector:cb.selector];
}

+(void)set_zoom_pos_align:(CCSprite*)normal zoomed:(CCSprite*)zoomed scale:(float)scale {
    zoomed.scale = scale;
    zoomed.position = ccp((-[zoomed contentSize].width * zoomed.scale + [zoomed contentSize].width)/2
                          ,(-[zoomed contentSize].height * zoomed.scale + [zoomed contentSize].height)/2);
}

@end

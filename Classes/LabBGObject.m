#import "LabBGObject.h"
#import "Resource.h"

@implementation LabBGObject

+(LabBGObject*)cons {
    float spdx = 0.7;
    float spdy = 0.4;
    
    LabBGObject* bg = [LabBGObject spriteWithTexture:[Resource get_tex:TEX_LAB_BG]];
    bg.scrollspd_x = spdx;
    bg.scrollspd_y = spdy;
    bg.anchorPoint = CGPointZero;
    bg.position = CGPointZero;
    ccTexParams par = {GL_LINEAR, GL_LINEAR, GL_REPEAT, GL_REPEAT};
    [bg.texture setTexParameters:&par];
    return bg;
}

-(void)update_posx:(float)posx posy:(float)posy {
    CGSize textureSize = [self textureRect].size;
    [self setTextureRect:CGRectMake(posx*scrollspd_x, -posy*scrollspd_y, [[UIScreen mainScreen] bounds].size.width*2 , textureSize.height)];
}

@end

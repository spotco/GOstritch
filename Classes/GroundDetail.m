#import "GroundDetail.h"

@implementation GroundDetail

+(GroundDetail*)init_x:(float)posx y:(float)posy type:(int)type{
    GroundDetail *d = [GroundDetail node];
    d.position = ccp(posx,posy);
    CCTexture2D *texture; 
    if (type == 1) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_1];
    } else if (type == 2) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_2];
    } else if (type == 3) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_3];
    } else if (type == 4) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_4];
    } else if (type == 5) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_5];
    } else if (type == 6) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_6];
    } else if (type == 7) {
        texture = [Resource get_tex:TEX_GROUND_DETAIL_7];
    } else {
        NSLog(@"GroundDetail init type error");
    }
    d.img = [CCSprite spriteWithTexture:texture];
    d.img.position = ccp(0,[d.img boundingBoxInPixels].size.height / 2.0);
    [d addChild:d.img];
    return d;
}

@end

#import "LabWall.h"

@implementation LabWall

+(LabWall*)init_x:(float)x y:(float)y width:(float)width height:(float)height {
    LabWall* n = [LabWall node];
    [n cons_x:x y:y width:width height:height];
    return n;
}

-(CCTexture2D*)get_tex {
    return [Resource get_tex:TEX_LAB_BG];
}

@end


#import "GameObject.h"

@interface CaveWall : GameObject {
    gl_render_obj tex;
    float wid,hei;
}

+(CaveWall*)init_x:(float)x y:(float)y width:(float)width height:(float)height;
-(void)cons_x:(float)x y:(float)y width:(float)width height:(float)height;
-(CCTexture2D*)get_tex;

@end

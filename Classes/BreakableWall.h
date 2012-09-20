#import "GameObject.h"
#import "PolyLib.h"

@interface BreakableWall : GameObject {
    Vec3D *dir_vec;
    gl_render_obj top,bottom,center;
    SATPoly r_hitbox;
}

+(BreakableWall*)init_x:(float)x y:(float)y x2:(float)x2 y2:(float)y2;

@end

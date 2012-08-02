#import "GameObject.h"
#import "SplashEffect.h"
#import "GameRenderImplementation.h"
#import "FishGenerator.h"

@interface Water : GameObject {
    gl_render_obj body;
    
    CGPoint* body_tex_offset;
    float bwidth,bheight,offset_ct;
    
    FishGenerator *fishes;
}

+(Water*)init_x:(float)x y:(float)y width:(float)width height:(float)height;

@end

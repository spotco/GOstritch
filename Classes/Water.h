#import "GameObject.h"
#import "SplashEffect.h"
#import "GameRenderImplementation.h"
#import "FishGenerator.h"

@interface Water : GameObject {
    GLRenderObject* body;
    
    CGPoint body_tex_offset[4];
    float bwidth,bheight,offset_ct;
    
    BOOL activated;
    
    FishGenerator *fishes;
}

+(Water*)init_x:(float)x y:(float)y width:(float)width height:(float)height;

@end

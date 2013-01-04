#import "GameObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"

@interface Spike : GameObject {
    gl_render_obj body;
    BOOL activated;
}

+(Spike*)init_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands;

@end

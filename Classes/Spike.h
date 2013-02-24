#import "GameObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"

@interface Spike : GameObject {
    GLRenderObject *body;
    BOOL activated;
}

+(Spike*)init_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands;

@end

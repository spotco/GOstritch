#import "CCSprite.h"
#import "Resource.h"
#import "Common.h"

@interface Particle : CCSprite {
    float vx,vy;
}

@property(readwrite,assign) float vx,vy;

-(void)update;
-(BOOL)should_remove;
-(int)get_render_ord;

@end

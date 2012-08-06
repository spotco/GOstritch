#import "Particle.h"
#import "GameRenderImplementation.h"

@implementation Particle
@synthesize vx,vy;

-(void)update {}
-(BOOL)should_remove { return YES; }
-(int)get_render_ord { return [GameRenderImplementation GET_RENDER_GAMEOBJ_ORD]; }


@end

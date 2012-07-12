#import "GameRenderState.h"

#define INIT_X 100
#define INIT_Y 40
#define INIT_Z 50

@implementation GameRenderState

@synthesize cx,cy,cz,ex,ey,ez;
@synthesize prevx,prevy;

- (id)init
{
    self = [super init];
    if (self) {
        cx = INIT_X;
        cy = INIT_Y;
        cz = 0;
        
        ex = INIT_X;
        ey = INIT_Y;
        ez = INIT_Z;
    }
    return self;
}

@end

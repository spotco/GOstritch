#import "PhysicsEnabledObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "BrokenMachineParticle.h"

@interface MinionRobot : PhysicsEnabledObject {
    BOOL busted;
}

+(MinionRobot*)cons_x:(float)x y:(float)y;

@property(readwrite,assign) CCSprite* body;

@end

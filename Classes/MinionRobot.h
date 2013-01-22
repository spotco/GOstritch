#import "PhysicsEnabledObject.h"
#import "HitEffect.h"
#import "DazedParticle.h"
#import "BrokenMachineParticle.h"

@interface MinionRobot : PhysicsEnabledObject {
    BOOL busted;
    BOOL has_shadow;
}

+(MinionRobot*)cons_x:(float)x y:(float)y;

@property(readwrite,assign) CCSprite* body;

@end

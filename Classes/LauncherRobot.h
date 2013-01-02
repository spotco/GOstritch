#import "GameObject.h"
#import "JumpPadParticle.h"
#import "PhysicsEnabledObject.h"

@interface LauncherRobot : PhysicsEnabledObject {
    CCSprite* body;
    int ct,animtoggle,recoilanim_timer;
    CGPoint starting_pos;
    BOOL busted;
}

+(LauncherRobot*)cons_x:(float)x y:(float)y;

@end


@interface LauncherRocket : GameObject {
    CGPoint v;
    BOOL kill;
    int ct;
}

+(LauncherRocket*)cons_at:(CGPoint)pt vel:(CGPoint)vel;

@end

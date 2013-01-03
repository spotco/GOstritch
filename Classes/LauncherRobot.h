#import "GameObject.h"
#import "JumpPadParticle.h"
#import "PhysicsEnabledObject.h"
#import "LauncherRocket.h"

@interface LauncherRobot : PhysicsEnabledObject {
    CCSprite* body;
    int ct,animtoggle,recoilanim_timer;
    float starting_rot;
    CGPoint starting_pos;
    BOOL busted;
    Vec3D* dir;
}

+(LauncherRobot*)cons_x:(float)x y:(float)y dir:(Vec3D*)dir;
+(void)explosion:(GameEngineLayer*)g at:(CGPoint)pt;

@end




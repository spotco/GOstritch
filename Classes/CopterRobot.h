#import "GameObject.h"
#import "LauncherRocket.h"

typedef enum {
    Side_Left,
    Side_Right
} Side;

typedef enum {
    CopterMode_IntroAnim,
    CopterMode_PlayerDeadToRemove,
    CopterMode_GotHit_FlyOff,
    CopterMode_Killed_Player,
    CopterMode_RightDash,
    CopterMode_LeftDash,
    CopterMode_SkyFireLeft
} CopterMode;

@interface CopterRobot : GameObject {
    CCSprite *body,*arm,*main_prop,*aux_prop,*main_nut,*aux_nut;
    CGPoint player_pos, rel_pos, actual_pos;
    int ct;
    float groundlevel;
    CopterMode cur_mode;
    
    float arm_r;
    BOOL arm_dir;
    
    CGPoint vibration;
    float vibration_theta;
    
    CGPoint flyoffdir;
}

+(CopterRobot*)cons_with_playerpos:(CGPoint)p;

@end

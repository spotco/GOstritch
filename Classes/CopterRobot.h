#import "GameObject.h"
#import "LauncherRocket.h"
#import "ExplosionParticle.h"

typedef enum {
    Side_Left,
    Side_Right
} Side;

typedef enum {
    CopterMode_IntroAnim,
    CopterMode_ToRemove,
    CopterMode_GotHit_FlyOff,
    CopterMode_Killed_Player,
    CopterMode_RightDash,
    CopterMode_LeftDash,
    CopterMode_SkyFireLeft,
    CopterMode_RapidFireRight,
    CopterMode_TrackingFireLeft,
    Coptermode_DeathExplode
} CopterMode;

@interface CopterRobot : GameObject {
    CCSprite *body,*arm,*main_prop,*aux_prop,*main_nut,*aux_nut;
    CGPoint player_pos, rel_pos, actual_pos;
    int ct;
    float groundlevel;
    CopterMode cur_mode;
    int hp;
    
    int lct,rct;
    
    float arm_r;
    BOOL arm_dir;
    
    CGPoint vibration;
    float vibration_theta;
    
    int recoil_ct;
    CGPoint recoil,recoil_tar;
    
    CGPoint flyoffdir;
}

+(CopterRobot*)cons_with_playerpos:(CGPoint)p;

@end

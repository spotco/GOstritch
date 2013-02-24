#import "PlayerEffectParams.h"

@interface DashEffect : PlayerEffectParams {
    float vx;
    float vy;
}

@property(readwrite,assign) float vx,vy;

+(DashEffect*)cons_from:(PlayerEffectParams*)base vx:(float)vx vy:(float)vy;

@end

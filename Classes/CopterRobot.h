
#import "GameObject.h"

@interface CopterRobot : GameObject {
    CCSprite *body,*arm,*main_prop,*aux_prop,*main_nut,*aux_nut;
}

+(CopterRobot*)cons_x:(float)x y:(float)y;

@end

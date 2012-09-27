#import "GameObject.h"

@interface SwingVine : GameObject {
    CCSprite* vine;
    CCSprite* loosevine;
    float vr;
    
    float cur_dist;
    
    int disable_timer;
}

+(SwingVine*)init_x:(float)x y:(float)y;
-(void)temp_disable;
-(CGPoint)get_tangent_vel;

@end

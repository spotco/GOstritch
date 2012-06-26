

#import "Island.h"

@interface CurveIsland : Island {
    float theta_i;
    float theta_f;
}

@property(readwrite,assign)  float theta_i,theta_f;

+(CurveIsland*) init_pt_i:(CGPoint)pt_i pt_f:(CGPoint)pt_f theta_i:(float)theta_i theta_f:(float)theta_f;

@end

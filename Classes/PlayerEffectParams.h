#import <Foundation/Foundation.h>

@interface PlayerEffectParams : NSObject {
    float cur_gravity;
    float cur_limit_speed;
    float cur_min_speed;
    
    int time_left;
}

@property(readwrite,assign) float cur_gravity,cur_limit_speed,cur_min_speed;
@property(readwrite,assign) int time_left;

+(PlayerEffectParams*)init_with_gravity:(float)gravity limitvel:(float)limitvel minvel:(float)minvel time:(int)time;
+(PlayerEffectParams*)init_copy:(PlayerEffectParams*)p;

@end

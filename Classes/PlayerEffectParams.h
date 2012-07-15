#import <Foundation/Foundation.h>

@interface PlayerEffectParams : NSObject {
    float cur_gravity;
    float cur_limit_speed;
    float cur_min_speed;
    float cur_accel_to_min;
    int   cur_airjump_count;
     
    
    int time_left;
}

@property(readwrite,assign) float cur_gravity,cur_limit_speed,cur_min_speed,cur_accel_to_min;
@property(readwrite,assign) int time_left,cur_airjump_count;

+(PlayerEffectParams*)init_copy:(PlayerEffectParams*)p;

-(void)update;

-(void)add_airjump_count;
-(void)decr_airjump_count;
-(NSString*)info;

@end

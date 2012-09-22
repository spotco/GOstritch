#import <Foundation/Foundation.h>
#import "Player.h"
@class GameEngineLayer;


@interface PlayerEffectParams : NSObject {
    float cur_gravity;
    float cur_limit_speed;
    float cur_min_speed;
    int   cur_airjump_count, cur_dash_count;
    BOOL noclip;
    
    int time_left;
    
    
    int TEST1;
}

@property(readwrite,assign) float cur_gravity,cur_limit_speed,cur_min_speed;
@property(readwrite,assign) int time_left,cur_airjump_count,cur_dash_count;
@property(readwrite,assign) BOOL noclip;

+(PlayerEffectParams*)init_copy:(PlayerEffectParams*)p;
+(void)copy_params_from:(PlayerEffectParams*)a to:(PlayerEffectParams*)b;
-(player_anim_mode)get_anim;
-(void)update:(Player*)p g:(GameEngineLayer *)g;

-(void)decrement_timer;
-(void)effect_begin:(Player*)p;
-(void)effect_end:(Player*)p g:(GameEngineLayer*)g;
-(void)add_airjump_count;
-(void)decr_airjump_count;
-(void)decr_dash_count;
-(NSString*)info;

-(void)f_dealloc;

@end

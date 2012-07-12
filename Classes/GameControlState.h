#import <Foundation/Foundation.h>

@interface GameControlState : NSObject {
    CGPoint last_touch;
    int last_touch_time;
    
    BOOL is_touch_down;
    int touch_timer;
    
    BOOL queue_jump, queue_roll;
}


@property(readwrite,assign) CGPoint last_touch;
@property(readwrite,assign) int touch_timer,last_touch_time;
@property(readwrite,assign) BOOL is_touch_down;

@property(readwrite,assign) BOOL queue_jump,queue_roll;


-(void)start_touch:(CGPoint)pt;
-(void)end_touch;
-(void)update;

@end

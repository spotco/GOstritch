#import <Foundation/Foundation.h>

@interface GameControlState : NSObject {
    CGPoint last_touch;
    int last_touch_time;
    
    BOOL is_touch_down;
    int touch_timer;
}


@property(readwrite,assign) CGPoint last_touch;
@property(readwrite,assign) int touch_timer,last_touch_time;
@property(readwrite,assign) BOOL is_touch_down;


-(void)start_touch:(CGPoint)pt;
-(void)end_touch;
-(BOOL)is_touch;
-(void)update;

@end

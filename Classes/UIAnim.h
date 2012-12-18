#import "CCSprite.h"
#import "Common.h"
#import "GEventDispatcher.h"

@interface UIAnim : CCSprite <GEventListener> {
    callback anim_complete;
}

@property(readwrite,assign) callback anim_complete;

-(void)update;
-(void)anim_finished;

@end

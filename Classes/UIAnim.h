#import "CCSprite.h"
#import "Common.h"
#import "GEventDispatcher.h"

@interface UIAnim : CCSprite <GEventListener>

@property(readwrite,assign) CallBack* anim_complete;

-(void)update;
-(void)anim_finished;

@end

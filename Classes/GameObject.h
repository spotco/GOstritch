
#import "CCNode.h"
#import "Player.h"

@interface GameObject : CCNode {
    BOOL active;
}

@property(readwrite,assign) BOOL active;

-(void)update:(Player*)player;
-(CGRect) get_hit_rect;
-(void)set_active:(BOOL)t_active;

@end

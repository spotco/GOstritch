
#import "CCNode.h"
#import "Player.h"

@interface GameObject : CCNode

-(void)update:(Player*)player;
-(CGRect) get_hit_rect; 

@end

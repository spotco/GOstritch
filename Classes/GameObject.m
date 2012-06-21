
#import "GameObject.h"

@implementation GameObject

@synthesize active;

-(void)update:(Player*)player  {
    return;
}

-(CGRect)get_hit_rect {
    return CGRectMake(0,0,0,0);
}

@end

#import "GameObject.h"
#import "HitEffect.h"

@interface Spike : GameObject

+(Spike*)init_x:(float)posx y:(float)posy islands:(NSMutableArray*)islands;

@end

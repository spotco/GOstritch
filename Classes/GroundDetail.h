
#import "Resource.h"
#import "GameObject.h"

@interface GroundDetail : GameObject

+(GroundDetail*)init_x:(float)posx y:(float)posy type:(int)type islands:(NSMutableArray*)islands;
@property(readwrite,assign) int imgtype;
@end

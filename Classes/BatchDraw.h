#import "CCSprite.h"
#import "Common.h"

@interface BatchDraw : CCSprite

+(void)cons;
+(void)add:(gl_render_obj)gl at_render_ord:(int)ord;
+(void)clear;

@end

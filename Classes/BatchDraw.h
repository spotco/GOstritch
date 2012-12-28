#import "CCSprite.h"
#import "Common.h"
#import "GameRenderImplementation.h"

@interface BatchDraw : CCSprite

+(void)init;
+(void)add:(gl_render_obj)gl key:(GLuint)tex z_ord:(int)ord draw_ord:(int)dord;
+(void)clear;
+(void)sort_jobs;

@end

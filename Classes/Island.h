#import <Foundation/Foundation.h>
#import "cocos2d.h"
#import "Common.h"

@class GameEngineLayer;

@interface Island : CCSprite {
	float startX, startY, endX, endY, ndir;
    float t_min,t_max;
    
    BOOL can_land,has_prev;
    Island* next;
    
    float fill_hei;
    
    Vec3D *cached_vec;
}


@property(readwrite,assign) float startX, startY, endX, endY, fill_hei, ndir, t_min, t_max;
@property(readwrite,assign) Island *next, *prev;
@property(readwrite,assign) BOOL can_land,has_prev;

+(float) NO_VALUE;
+(int)link_islands:(NSMutableArray*)islands;
-(void)update:(GameEngineLayer*)g;

-(void)link_finish;
-(Vec3D*)get_normal_vecC;
-(line_seg)get_line_seg;
-(float)get_t_given_position:(CGPoint)position;
-(CGPoint)get_position_given_t:(float)t;
-(Vec3D*)get_tangent_vec;
-(float)get_height:(float)pos;

-(int)get_render_ord;

-(void)cleanup_anims;





@end

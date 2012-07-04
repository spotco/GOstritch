#import "Island.h"


@implementation Island

static float NO_VAL = -99999.0;

+(float) NO_VALUE {
    return NO_VAL;
}

@synthesize startX, startY, endX, endY;
@synthesize next;

-(float)get_height:(float)pos {
	return [Island NO_VALUE];
}

-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x {
    float island_start_x = pre_x;
    float island_start_y = [self get_height:island_start_x];
    if (island_start_y == [Island NO_VALUE]) {
        island_start_x = startX;
        island_start_y = startY;
    }
    
    float island_end_x = post_x;
    float island_end_y = [self get_height:island_end_x];
    if (island_end_y == [Island NO_VALUE]) {
        island_end_x = endX;
        island_end_y = endY;
    }
    return [Common cons_line_seg_a:ccp(island_start_x,island_start_y) b:ccp(island_end_x,island_end_y)];
}

-(Vec3D*)get_tangent_vec {
    return [Vec3D init_x:0 y:0 z:0];
}

+(int) link_islands:(NSMutableArray*)islands {
    int ct = 0;
    for(Island *i in islands) {
        for(Island *j in islands) {
            if ([Common pt_fuzzy_eq:ccp(i.endX,i.endY) b:ccp(j.startX,j.startY)]) {
                i.next = j;
                ct++;
            }
        }
    }
    return ct;
}

-(float)get_t_given_position:(CGPoint)position {
    return [Island NO_VALUE];
}

-(CGPoint)get_position_given_t:(float)t {
    return ccp([Island NO_VALUE],[Island NO_VALUE]);
}

@end

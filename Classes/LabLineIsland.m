#import "LabLineIsland.h"

@implementation LabLineIsland

+(LabLineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LabLineIsland *new_island = [LabLineIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island init_tex];
	[new_island init_top];
	return new_island;
}

-(CCTexture2D*)get_corner_fill_color {
    return [Resource get_tex:TEX_LAB_GROUND_CORNER];
}

-(CCTexture2D*)get_tex_corner {
    return [Resource get_tex:TEX_LAB_GROUND_TOP_EDGE];
}
-(CCTexture2D*)get_tex_top {
    return [Resource get_tex:TEX_LAB_GROUND_TOP];
}
-(CCTexture2D*)get_tex_fill {
    if (fill_hei <= 150) {
        return [Resource get_tex:TEX_LAB_GROUND_2];
    } else {
        return [Resource get_tex:TEX_LAB_GROUND_2];
    }
    
}

@end

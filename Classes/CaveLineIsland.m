
#import "CaveLineIsland.h"

@implementation CaveLineIsland

+(CaveLineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	CaveLineIsland *new_island = [CaveLineIsland node];
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

-(NSString*)get_tex_corner {
    return TEX_CAVE_CORNER_TEX;
}
-(NSString*)get_tex_top {
    return TEX_CAVE_TOP_TEX;
}
-(NSString*)get_corner_fill_color {
    return TEX_GROUND_CORNER_TEX_1;
}


-(void)draw {
    [super draw];
}

@end

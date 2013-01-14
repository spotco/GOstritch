#import "LabLineIsland.h"
#import "BatchDraw.h"

@implementation LabLineIsland

@synthesize shift_mainfill;

#define OVERALL_OFFSET_Y 0.1

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

-(void)main_fill_tex_map {
    [self main_fill_tex_map_offset:ccp(0,0)];
}

-(void)corner_fill_tex_map {
    gl_render_obj* o = &corner_fill;
    for (int i = 0; i < 3; i++) {
        o->tex_pts[i] = ccp(((o->tri_pts[i].x)/o->texture.pixelsWide),
                            ((o->tri_pts[i].y)/o->texture.pixelsHigh+OVERALL_OFFSET_Y));
    }
}

-(void)main_fill_tex_map_offset:(CGPoint)offset {
    
    gl_render_obj* o = &main_fill;
    for (int i = 0; i < 4; i++) {
        o->tex_pts[i] = ccp((o->tri_pts[i].x+offset.x)/o->texture.pixelsWide, (o->tri_pts[i].y+offset.y)/o->texture.pixelsHigh+OVERALL_OFFSET_Y);
    }
}

-(void)corner_fill_set_tex:(LineIsland*)next {
    gl_render_obj* o = &corner_fill;
    
    if (o->isalloc == 0) {
        return;
    }
    
    corner_fill.tex_pts[0] = main_fill.tex_pts[2];
    corner_fill.tex_pts[1] = main_fill.tex_pts[0];
    corner_fill.tex_pts[2] = [next get_main_fill].tex_pts[1];
    
    //main_fill (assume is correctt for cur and next)
    // 3 2
    // 1 0
     
    // corner_fill
    // 0
    // 1 2
}


-(void)link_finish {
    [super link_finish];
    //must be called at this point, don't know why
    //first pass to move mail_fill
    if (self.prev == NULL || [self.prev class] != [LabLineIsland class]) {
        Island *i = self.next;
        while(i != NULL && [i class] == [LabLineIsland class]) {
            CGPoint offset = ccp(i.startX-self.startX,i.startY-self.startY);
            [((LabLineIsland*)i) main_fill_tex_map_offset:offset];
            i = i.next;
        }
    }
}

-(void)post_link_finish {
    //second pass to move corner_fill
    if (self.prev == NULL || [self.prev class] != [LabLineIsland class]) {
        Island *i = self.next;
        while(i != NULL && [i class] == [LabLineIsland class]) {
            if (i.next != NULL && [[i.next class] isSubclassOfClass:[LineIsland class]])
                [((LabLineIsland*)i) corner_fill_set_tex:(LineIsland*)i.next];
            i = i.next;
        }
    }
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
        return [Resource get_tex:TEX_LAB_GROUND_1];
    } else {
        return [Resource get_tex:TEX_LAB_GROUND_1];
    }
    
}

@end

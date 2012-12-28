
#import "LineIsland.h"
#import "GameEngineLayer.h"

@implementation LineIsland

#define HEI 56
#define OFFSET -40

#define MVR_ROUNDED_CORNER_SCALE 8
#define NORMAL_ROUNDED_CORNER_SCALE 20
#define BORDER_LINE_WIDTH 5
#define CORNER_TOP_FILL_SCALE 26
#define TL_DOWNOFFSET 20

@synthesize tl,bl,tr,br;
@synthesize force_draw_leftline,force_draw_rightline;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LineIsland *new_island = [LineIsland node];
    new_island.fill_hei = height;
    new_island.self.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island init_tex];
	[new_island init_top];
    
	return new_island;
}

-(void)update:(GameEngineLayer *)g {    
    
    if ([Common hitrect_touch:[g get_viewbox] b:[self get_hitrect]]) {
        do_draw = YES;
        if (!self.visible) {
            [self setVisible:YES];
        }
    } else {
        do_draw = NO;
        if (self.visible) {
            [self setVisible:NO];
        }
    }
        
    if (do_draw) {
        [BatchDraw add:top_fill key:top_fill.texture.name z_ord:[self get_render_ord] draw_ord:2];
        [BatchDraw add:main_fill key:main_fill.texture.name z_ord:[self get_render_ord] draw_ord:0];
        
        
        if (self.prev == NULL || force_draw_leftline) {
            [BatchDraw add:left_line_fill key:left_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:3];
        }
        if (self.next == NULL || force_draw_rightline) {
            [BatchDraw add:right_line_fill key:right_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:4];
        }
        if (bottom_line_fill.isalloc == 1) {
            [BatchDraw add:bottom_line_fill key:bottom_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:5];
        }
        
        if (self.prev == NULL || force_draw_leftline) {
             [BatchDraw add:tl_top_corner key:tl_top_corner.texture.name z_ord:[self get_render_ord] draw_ord:6];
        }
        if (self.next == NULL || force_draw_rightline) {
            [BatchDraw add:tr_top_corner key:tr_top_corner.texture.name z_ord:[self get_render_ord] draw_ord:7];
        }
        
        if (self.next != NULL && !(force_draw_leftline||force_draw_rightline)) {
            [BatchDraw add:corner_fill key:corner_fill.texture.name z_ord:[self get_render_ord] draw_ord:8];
            [BatchDraw add:toppts_fill key:toppts_fill.texture.name z_ord:[self get_render_ord] draw_ord:9];
            [BatchDraw add:corner_line_fill key:corner_line_fill.texture.name z_ord:[self get_render_ord] draw_ord:10];
        } 
        
    }
    
}

-(HitRect)get_hitrect {
    if (has_gen_hitrect == NO) {
        has_gen_hitrect = YES;
        int x_max = main_fill.tri_pts[0].x;
        int x_min = main_fill.tri_pts[0].x;
        int y_max = main_fill.tri_pts[0].y;
        int y_min = main_fill.tri_pts[0].y;
        for (int i = 0; i < 4; i++) {
            x_max = MAX(main_fill.tri_pts[i].x,x_max);
            x_min = MIN(main_fill.tri_pts[i].x,x_min);
            y_max = MAX(main_fill.tri_pts[i].y,y_max);
            y_min = MIN(main_fill.tri_pts[i].y,y_min);
        }
        cache_hitrect = [Common hitrect_cons_x1:x_min y1:y_min x2:x_max y2:y_max];
    }
    return cache_hitrect;
}

-(void)calc_init {
    self.t_min = 0;
    self.t_max = sqrtf(powf(self.endX - self.startX, 2) + powf(self.endY - self.startY, 2));
    do_draw = YES;
    force_draw_leftline = NO;
    force_draw_rightline = NO;
    has_gen_hitrect = NO;
}

-(void) draw {
    return;
    if (!do_draw) {
        return;
    }
	[super draw];    
}

-(CCTexture2D*)get_tex_fill {
    return [Resource get_tex:TEX_GROUND_TEX_1];
}
-(CCTexture2D*)get_tex_corner {
    return [Resource get_tex:TEX_TOP_EDGE];
}
-(CCTexture2D*)get_tex_border {
    return [Resource get_tex:TEX_ISLAND_BORDER];
}
-(CCTexture2D*)get_tex_top {
    return [Resource get_tex:TEX_GROUND_TOP_1];
}
-(CCTexture2D*)get_corner_fill_color {
    return [Resource get_tex:TEX_GROUND_CORNER_TEX_1];
}

-(void)scale_ndir:(Vec3D*)v {
    [v scale:self.ndir];
}

-(void)init_tex {
    //init islandfill
    main_fill = [Common init_render_obj:[self get_tex_fill] npts:4];
	
	CGPoint *tri_pts = main_fill.tri_pts;
    
    Vec3D *v3t2 = [Vec3D init_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    float taille = fill_hei;
    
    
    tri_pts[3] = ccp(0,0);
    tri_pts[2] = ccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = ccp(0+v3t1.x * taille,0+v3t1.y * taille);
    tri_pts[0] = ccp(self.endX-self.startX +v3t1.x * taille ,self.endY-self.startY +v3t1.y * taille);
	
    [Common tex_map_to_tri_loc:&main_fill len:4];
    [self init_LR_line_with_v3t1:v3t1 v3t2:v3t2];
    
    [v3t2 dealloc];
    [v3t1 dealloc];
}

-(void) init_LR_line_with_v3t1:(Vec3D*)v3t1 v3t2:(Vec3D*)v3t2 {
    /**
     TL TR
     BL BR
     **/
    bl = main_fill.tri_pts[1];
    br = main_fill.tri_pts[0];
    tl = main_fill.tri_pts[3];
    tr = main_fill.tri_pts[2];
    
    [v3t1 normalize];
    [v3t1 scale:TL_DOWNOFFSET];
    tl = ccp(tl.x + v3t1.x, tl.y + v3t1.y);
    tr = ccp(tr.x + v3t1.x, tr.y + v3t1.y);
    
    [self init_left_line_fill];
    [self init_right_line_fill];
}

-(void)init_top {
    //set top green bar
    //also initially sets toppts
    top_fill = [Common init_render_obj:[self get_tex_top] npts:4];
    
	CGPoint* tri_pts = top_fill.tri_pts;
	CGPoint* tex_pts = top_fill.tex_pts;
	CCTexture2D* texture = top_fill.texture;
	
	float dist = sqrt(pow(self.endX-self.startX, 2)+pow(self.endY-self.startY, 2));
    
    
    Vec3D *v3t2 = [Vec3D init_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    float hei = HEI;
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    
    tri_pts[2] = ccp(self.endX-self.startX + d_o_x              ,self.endY-self.startY + d_o_y);
    tri_pts[3] = ccp(d_o_x                            , d_o_y);
    tri_pts[0] = ccp(self.endX-self.startX+v3t1.x*hei  + d_o_x  ,self.endY-self.startY+v3t1.y*hei + d_o_y);
    tri_pts[1] = ccp(v3t1.x*hei + d_o_x               ,v3t1.y*hei + d_o_y);
    
    tex_pts[0] = ccp(dist/texture.pixelsWide,0);
    tex_pts[1] = ccp(0,0);
    tex_pts[2] = ccp(dist/texture.pixelsWide,1);
    tex_pts[3] = ccp(0,1);
    
    toppts_fill.tri_pts[0] = ccp(self.endX-self.startX,self.endY-self.startY);
    toppts_fill.tri_pts[1] = ccp(tri_pts[2].x,tri_pts[2].y);
    
    [v3t2 negate];
    [v3t2 normalize];
    [self init_tl_top:tri_pts[1] bot:tri_pts[3] vec:v3t2];
    [v3t2 negate];
    [self init_tr_top:tri_pts[2] bot:tri_pts[0] vec:v3t2];
    
    [self init_bottom_line_fill];
    
    [v3t1 dealloc];
    [v3t2 dealloc];
}

-(gl_render_obj)init_TRorTL_top:(CGPoint)top bot:(CGPoint)bot vec:(Vec3D*)vec {
    Vec3D *mvr = [Vec3D init_x:-vec.x y:-vec.y z:0];
    [mvr scale:MVR_ROUNDED_CORNER_SCALE];
    
    top = [mvr transform_pt:top];
    bot = [mvr transform_pt:bot];
    [mvr dealloc];
    
    gl_render_obj o = [Common init_render_obj:[self get_tex_corner] npts:4];
	
	CGPoint* tri_pts = o.tri_pts;
    
    [vec scale:NORMAL_ROUNDED_CORNER_SCALE];
    
    tri_pts[0] = ccp(top.x+vec.x,top.y+vec.y);
    tri_pts[1] = top;
    tri_pts[2] = ccp(bot.x+vec.x,bot.y+vec.y);
    tri_pts[3] = bot;
    [vec normalize];
    
    return o;
}

-(void)init_tl_top:(CGPoint)top bot:(CGPoint)bot vec:(Vec3D*)vec {
    tl_top_corner = [self init_TRorTL_top:top bot:bot vec:vec];
    CGPoint* tex_pts = tl_top_corner.tex_pts;
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[3] = ccp(1,1);
    tex_pts[2] = ccp(0,1);
}

-(void)init_tr_top:(CGPoint)top bot:(CGPoint)bot vec:(Vec3D*)vec {
    tr_top_corner = [self init_TRorTL_top:top bot:bot vec:vec];
    CGPoint* tex_pts = tr_top_corner.tex_pts;
    
    tex_pts[2] = ccp(0,0);
    tex_pts[3] = ccp(1,0);
    tex_pts[1] = ccp(1,1);
    tex_pts[0] = ccp(0,1);
}

-(gl_render_obj)line_from:(CGPoint)a to:(CGPoint)b scale:(float)scale {
    struct gl_render_obj n;
    n = [Common init_render_obj:[self get_tex_border] npts:4];
    n.isalloc = 1;
    CGPoint* tri_pts = n.tri_pts;
	CGPoint* tex_pts = n.tex_pts;
    
    Vec3D *v = [Vec3D init_x:b.x-a.x y:b.y-a.y z:0];
    Vec3D *dirv;
    
    if (self.ndir == -1) {
        dirv = [[Vec3D Z_VEC] crossWith:v];
    } else {
        dirv = [v crossWith:[Vec3D Z_VEC]];
    }
    
    [dirv normalize];
    [dirv scale:BORDER_LINE_WIDTH];
    [dirv scale:scale];
    
    tri_pts[0] = a;
    tri_pts[1] = b;
    tri_pts[2] = ccp(a.x+dirv.x,a.y+dirv.y);
    tri_pts[3] = ccp(b.x+dirv.x,b.y+dirv.y);
    
    tex_pts[0] = ccp(0,0);
    tex_pts[1] = ccp(1,0);
    tex_pts[2] = ccp(0,1);
    tex_pts[3] = ccp(1,1);
    
    [v dealloc];
    [dirv dealloc];
    return n;
}

-(void)init_bottom_line_fill {
    bottom_line_fill = [self line_from:bl to:br scale:1];
}

-(void)init_corner_line_fill {
    //if next is island, set force_draw_rightline
    if (self.next == NULL) {
        return;
    } else if (![self.next isKindOfClass:[LineIsland class]]){
        force_draw_rightline = YES;
        return;
    }
    
    LineIsland *n = (LineIsland*)self.next;
    corner_line_fill = [self line_from:br to:ccp(n.bl.x-self.startX+n.self.startX,n.bl.y-self.startY+n.self.startY) scale:1];
}

-(void)init_left_line_fill {    
    left_line_fill = [self line_from:tl to:bl scale:1];
}

-(void)init_right_line_fill {    
    right_line_fill = [self line_from:tr to:br scale:-1];
}

-(void)link_finish {
    if (self.next != NULL) {
        if (corner_fill.isalloc == 0) {
            [self init_corner_tex];
            corner_fill = [Common transform_obj:corner_fill by:position_];
        }
        if (toppts_fill.isalloc == 0) {
            [self init_corner_top];
            toppts_fill = [Common transform_obj:toppts_fill by:position_];
        }
        if (corner_line_fill.isalloc == 0) {
            [self init_corner_line_fill];
            corner_line_fill = [Common transform_obj:corner_line_fill by:position_];
        }
    }
    
    if (!has_transformed_renderpts) {
        has_transformed_renderpts = YES;
        main_fill = [Common transform_obj:main_fill by:position_];
        top_fill = [Common transform_obj:top_fill by:position_];
        tl_top_corner = [Common transform_obj:tl_top_corner by:position_];
        tr_top_corner = [Common transform_obj:tr_top_corner by:position_];
        bottom_line_fill = [Common transform_obj:bottom_line_fill by:position_];
        left_line_fill = [Common transform_obj:left_line_fill by:position_];
        right_line_fill = [Common transform_obj:right_line_fill by:position_];
        
    }
    
}

-(void)init_corner_top {
    //called from link_finish, position greenwedge
    Vec3D *v3t2 = [Vec3D init_x:(self.next.endX - self.next.startX) y:(self.next.endY - self.next.startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    toppts_fill.tri_pts[2] = ccp( d_o_x+self.next.startX-self.startX ,d_o_y+self.next.startY-self.startY );

    float corner_top_scale = CORNER_TOP_FILL_SCALE;
    
    /*cur 0  next
          1 2
     */
    //toppts[0,1] already set, set[2] and scale
    Vec3D *reduce_left = [Vec3D init_x:toppts_fill.tri_pts[1].x-toppts_fill.tri_pts[0].x y:toppts_fill.tri_pts[1].y-toppts_fill.tri_pts[0].y z:0];
    [reduce_left normalize];
    [reduce_left scale:corner_top_scale];
    toppts_fill.tri_pts[1] = ccp( toppts_fill.tri_pts[0].x + reduce_left.x, toppts_fill.tri_pts[0].y + reduce_left.y);
    
    Vec3D *reduce_right = [Vec3D init_x:toppts_fill.tri_pts[2].x-toppts_fill.tri_pts[0].x y:toppts_fill.tri_pts[2].y-toppts_fill.tri_pts[0].y z:0];
    [reduce_right normalize];
    [reduce_right scale:corner_top_scale];
    toppts_fill.tri_pts[2] = ccp( toppts_fill.tri_pts[0].x + reduce_right.x, toppts_fill.tri_pts[0].y + reduce_right.y);
    
    toppts_fill.texture = [self get_corner_fill_color];
    toppts_fill.pts = 3;
    toppts_fill.isalloc = 1;
    toppts_fill.tex_pts[0] = ccp(0,0);
    toppts_fill.tex_pts[1] = ccp(1,0);
    toppts_fill.tex_pts[2] = ccp(1,1);
    
    [v3t2 dealloc];
    [v3t1 dealloc];
    [reduce_left dealloc];
    [reduce_right dealloc];
}

-(void)init_corner_tex {
    corner_fill = [Common init_render_obj:[self get_tex_fill] npts:3];
    
    CGPoint* tri_pts = corner_fill.tri_pts;
    
    Vec3D *v3t2 = [Vec3D init_x:(self.endX - self.startX) y:(self.endY - self.startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    tri_pts[0] = ccp(self.endX-self.startX,self.endY-self.startY);
    tri_pts[1] = ccp(self.endX+v3t1.x*fill_hei-self.startX,self.endY+v3t1.y*fill_hei-self.startY);
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    v3t2 = [Vec3D init_x:(self.next.endX - self.next.startX) y:(self.next.endY - self.next.startY) z:0];
    v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    tri_pts[2] = ccp(self.next.startX+v3t1.x*self.next.fill_hei-self.startX, self.next.startY+v3t1.y*self.next.fill_hei-self.startY);
    [v3t2 dealloc];
    [v3t1 dealloc];

    [Common tex_map_to_tri_loc:&corner_fill len:3];
}

@end

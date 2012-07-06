
#import "LineIsland.h"
#import "GameEngineLayer.h"

@implementation LineIsland

#define HEI 56
#define OFFSET -40
static float INF = INFINITY;

@synthesize min_range,max_range,t_min,t_max,slope;
@synthesize main_fill,top_fill,corner_fill;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end height:(float)height ndir:(float)ndir can_land:(BOOL)can_land {
	LineIsland *new_island = [LineIsland node];
    new_island.fill_hei = height;
    new_island.ndir = ndir;
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
    new_island.can_land = can_land;
	[new_island init_tex];
	[new_island init_top];
    [new_island calculate_normal];
	return new_island;
	
}

-(void)calculate_normal {
    Vec3D *line_vec = [Vec3D init_x:endX-startX y:endY-startY z:0];
    normal_vec = [[Vec3D Z_VEC] crossWith:line_vec];
    [normal_vec normalize];
    [line_vec dealloc];
    [normal_vec scale:ndir];
}

-(void)set_pt1:(CGPoint)start pt2:(CGPoint)end {
	startX = start.x;
	startY = start.y;
	endX = end.x;
	endY = end.y;
}

-(void)calc_init {
	min_range = startX;
	max_range = endX;
    t_min = 0;
    t_max = sqrtf(powf(endX - startX, 2) + powf(endY - startY, 2));
    if (startX == endX) {
        if (startY > endY){
            slope = -INF;
        } else {
            slope = INF;
        }
    } else {
        slope = (endY - startY)/(endX - startX);
    }
}

-(float)get_height:(float)pos {
	if (pos < min_range || pos > max_range) {
		return [Island NO_VALUE];
	} else {
		return startY+(pos-startX)*slope;
	}
}

-(Vec3D*)get_tangent_vec {
    Vec3D *v = [Vec3D init_x:endX-startX y:endY-startY z:0];
    [v normalize];
    return v;
}

-(line_seg)get_line_seg_a:(float)pre_x b:(float)post_x {
    return [Common cons_line_seg_a:ccp(startX,startY) b:ccp(endX,endY)];
}

-(float)get_t_given_position:(CGPoint)position {
    float dx = powf(position.x - startX, 2);
    float dy = powf(position.y - startY, 2);
    float f = sqrtf( dx+dy );
    return f;
}

-(CGPoint)get_position_given_t:(float)t {
    if (t > t_max || t < t_min) {
         return ccp([Island NO_VALUE],[Island NO_VALUE]);
    } else {
        float frac = t/t_max;
        Vec3D *dir_vec = [Vec3D init_x:endX-startX y:endY-startY z:0];
        [dir_vec scale:frac];
        CGPoint pos = ccp(startX+dir_vec.x,startY+dir_vec.y);
        [dir_vec dealloc];
        return pos;
    }
}

-(void) draw {
	if (endX < [GameEngineLayer get_cur_pos_x]-800 ||
		startY > [GameEngineLayer get_cur_pos_y]+800) { //TODO -- FIXME
		return;
	} 
	[super draw];

    
    
	glBindTexture(GL_TEXTURE_2D, main_fill.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, main_fill.tri_pts); //coord per vertex, type, stride, pointer to array
	glTexCoordPointer(2, GL_FLOAT, 0, main_fill.tex_pts);
	glDrawArrays(GL_TRIANGLES, 0, 3); //drawtype,offset,pts
	glDrawArrays(GL_TRIANGLES, 1, 3);
    
    glBindTexture(GL_TEXTURE_2D, top_fill.texture.name);
    glVertexPointer(2,GL_FLOAT,0,top_fill.tri_pts);
    glTexCoordPointer(2,GL_FLOAT,0,top_fill.tex_pts);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawArrays(GL_TRIANGLES, 1, 3);
    
    if (next != NULL) {

        glBindTexture(GL_TEXTURE_2D, corner_fill.texture.name);
        glVertexPointer(2,GL_FLOAT,0,corner_fill.tri_pts);
        glTexCoordPointer(2,GL_FLOAT,0,corner_fill.tex_pts);
        glDrawArrays(GL_TRIANGLES, 0, 3);
        
        glColor4f(0.29, 0.69, 0.03, 1.0);
        ccDrawSolidPoly(toppts, 3, YES);
    }
}

-(void)scale_ndir:(Vec3D*)v {
    [v scale:ndir];
}

-(void)init_tex {	
    main_fill.texture = [Resource get_tex:TEX_GROUND_TEX_1];
    
	main_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	main_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = main_fill.tri_pts;
	CGPoint* tex_pts = main_fill.tex_pts;
	CCTexture2D* texture = main_fill.texture;
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    float taille = fill_hei;
    
    tri_pts[3] = ccp(0,0);
    tri_pts[2] = ccp(endX-startX,endY-startY);
    tri_pts[1] = ccp(0+v3t1.x * taille,0+v3t1.y * taille);
    tri_pts[0] = ccp(endX-startX +v3t1.x * taille ,endY-startY +v3t1.y * taille);
	
	tex_pts[2] = ccp(tri_pts[2].x/texture.pixelsWide, tri_pts[2].y/texture.pixelsHigh);
	tex_pts[3] = ccp(tri_pts[3].x/texture.pixelsWide, tri_pts[3].y/texture.pixelsWide);
	tex_pts[0] = ccp(tri_pts[0].x/texture.pixelsWide, tri_pts[0].y/texture.pixelsWide);
	tex_pts[1] = ccp(tri_pts[1].x/texture.pixelsWide, tri_pts[1].y/texture.pixelsWide);
    
    [v3t2 dealloc];
    [v3t1 dealloc];
}

-(void)init_top {
    top_fill.texture = [Resource get_tex:TEX_GROUND_TOP_1];
    
	top_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	top_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = top_fill.tri_pts;
	CGPoint* tex_pts = top_fill.tex_pts;
	CCTexture2D* texture = top_fill.texture;
	
	float dist = sqrt(pow(endX-startX, 2)+pow(endY-startY, 2));
    
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D init_x:0 y:0 z:1];
    
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    
    float hei = HEI;
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    
    tri_pts[2] = ccp(endX-startX + d_o_x              ,endY-startY + d_o_y);
    tri_pts[3] = ccp(0 + d_o_x                        ,0  + d_o_y);
    tri_pts[0] = ccp(endX-startX+v3t1.x*hei  + d_o_x  ,endY-startY+v3t1.y*hei + d_o_y);
    tri_pts[1] = ccp(v3t1.x*hei + d_o_x               ,v3t1.y*hei + d_o_y);
    
    tex_pts[0] = ccp(dist/texture.pixelsWide,0);
    tex_pts[1] = ccp(0,0);
    tex_pts[2] = ccp(dist/texture.pixelsWide,1);
    tex_pts[3] = ccp(0,1);
    
    toppts[0] = ccp(endX-startX,endY-startY);
    toppts[1] = ccp(tri_pts[2].x,tri_pts[2].y);
}

-(void)link_finish {
    if (next != NULL) {
        [self init_corner_tex];
        [self init_corner_top];
    }
}

-(void)init_corner_top {
    Vec3D *v3t2 = [Vec3D init_x:(next.endX - next.startX) y:(next.endY - next.startY) z:0];
    Vec3D *vZ = [Vec3D init_x:0 y:0 z:1];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [v3t1 negate];
    [self scale_ndir:v3t1];
    
    float offset = OFFSET;
    float d_o_x = offset * v3t1.x;
    float d_o_y = offset * v3t1.y;
    toppts[2] = ccp( d_o_x+next.startX-startX ,d_o_y+next.startY-startY );
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    float corner_top_scale = 0.65;
    
    Vec3D *reduce_left = [Vec3D init_x:toppts[1].x-toppts[0].x y:toppts[1].y-toppts[0].y z:0];
    float leftlen = [reduce_left length];
    [reduce_left normalize];
    leftlen = leftlen * corner_top_scale;
    toppts[1] = ccp( toppts[0].x + reduce_left.x * leftlen, toppts[0].y + reduce_left.y * leftlen);
    [reduce_left dealloc];
    
    Vec3D *reduce_right = [Vec3D init_x:toppts[2].x-toppts[0].x y:toppts[2].y-toppts[0].y z:0];
    float rightlen = [reduce_right length];
    [reduce_right normalize];
    rightlen = rightlen * corner_top_scale;
    toppts[2] = ccp( toppts[0].x + reduce_right.x * rightlen, toppts[0].y + reduce_right.y * rightlen);
    [reduce_right dealloc];
    
    
}

-(void)init_corner_tex {
    corner_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*3);
    corner_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*3);
    corner_fill.texture = [Resource get_tex:TEX_GROUND_TEX_1];
    
    CGPoint* tri_pts = corner_fill.tri_pts;
    CGPoint* tex_pts = corner_fill.tex_pts;
    CCTexture2D* texture = corner_fill.texture;
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D Z_VEC];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    
    tri_pts[0] = ccp(endX-startX,endY-startY);
    tri_pts[1] = ccp(endX+v3t1.x*fill_hei-startX,endY+v3t1.y*fill_hei-startY);
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    v3t2 = [Vec3D init_x:(next.endX - next.startX) y:(next.endY - next.startY) z:0];
    v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    [self scale_ndir:v3t1];
    tri_pts[2] = ccp(next.startX+v3t1.x*next.fill_hei-startX, next.startY+v3t1.y*next.fill_hei-startY);
    [v3t2 dealloc];
    [v3t1 dealloc];
    
    tex_pts[0] = ccp(tri_pts[0].x/texture.pixelsWide, tri_pts[0].y/texture.pixelsHigh);
    tex_pts[1] = ccp(tri_pts[1].x/texture.pixelsWide, tri_pts[1].y/texture.pixelsHigh);
    tex_pts[2] = ccp(tri_pts[2].x/texture.pixelsWide, tri_pts[2].y/texture.pixelsHigh);  
}


@end

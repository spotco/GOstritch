
#import "LineIsland.h"
#import "PRFilledPolygon.h"
#import "GameEngineLayer.h"

@implementation LineIsland

@synthesize min_range,max_range,slope;
@synthesize main_fill;

+(LineIsland*)init_pt1:(CGPoint)start pt2:(CGPoint)end {
	LineIsland *new_island = [LineIsland node];
	[new_island set_pt1:start pt2:end];
	[new_island calc_init];
	new_island.anchorPoint = ccp(0,0);
	new_island.position = ccp(new_island.startX,new_island.startY);
	
	[new_island init_tex];
	[new_island init_top];
	
	return new_island;
	
}

/*NOTE2: rotate uv coords
 (0,1)--(1,1)        (0,0)--(1,0)
 |      |     -->    |      |
 (0,0)--(1,0)        (0,1)--(1,1)*/

/*NOTE3: to draw quad, this order
 vertex:       uv:
 (4)--(3)      (2)--(1)
 |    |   -->  |    |
 (2)--(1)      (4)--(3)
 then glDrawArrays(offset++)*/
-(void)init_tex {	
    main_fill.texture = [Resource get_tex:@"level1_island1_tex"];
    
	main_fill.tri_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	main_fill.tex_pts = (CGPoint*) malloc(sizeof(CGPoint)*4);
	
	CGPoint* tri_pts = main_fill.tri_pts;
	CGPoint* tex_pts = main_fill.tex_pts;
	CCTexture2D* texture = main_fill.texture;
    
    Vec3D *v3t2 = [Vec3D init_x:(endX - startX) y:(endY - startY) z:0];
    Vec3D *vZ = [Vec3D init_x:0 y:0 z:1];
    Vec3D *v3t1 = [v3t2 crossWith:vZ];
    [v3t1 normalize];
    
    tri_pts[3] = ccp(0,0);
    tri_pts[2] = ccp(endX-startX,endY-startY);
    tri_pts[1] = ccp(0+v3t1.x * 10,0+v3t1.y * 10);
    tri_pts[0] = ccp(endX-startX +v3t1.x * 10 ,endY-startY +v3t1.y * 10);
	
	tex_pts[2] = ccp(tri_pts[2].x/texture.pixelsWide, tri_pts[2].y/texture.pixelsHigh);
	tex_pts[3] = ccp(tri_pts[3].x/texture.pixelsWide, tri_pts[3].y/texture.pixelsWide);
	tex_pts[0] = ccp(tri_pts[0].x/texture.pixelsWide, tri_pts[0].y/texture.pixelsWide);
	tex_pts[1] = ccp(tri_pts[1].x/texture.pixelsWide, tri_pts[1].y/texture.pixelsWide);
    
    [v3t2 dealloc];
    [vZ dealloc];
    [v3t1 dealloc];
}

-(void)init_top {
    top_fill.texture = [Resource get_tex:@"level1_island1_top"];
    //top_fill.texture = [Resource get_tex:@"bg_sky"];
    
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
    
    float hei = 300;
    
    tri_pts[2] = ccp(endX-startX,endY-startY);
    tri_pts[3] = ccp(0,0);
    tri_pts[0] = ccp(endX-startX+v3t1.x*hei,endY-startY+v3t1.y*hei);
    tri_pts[1] = ccp(v3t1.x*hei,v3t1.y*hei);
    
    tex_pts[0] = ccp(dist/texture.pixelsWide,0);
    tex_pts[1] = ccp(0,0);
    tex_pts[2] = ccp(dist/texture.pixelsWide,1);
    tex_pts[3] = ccp(0,1);
}

-(void) draw {
	if (endX < [GameEngineLayer get_cur_pos_x]-400 ||
		startY > [GameEngineLayer get_cur_pos_y]+400) {
		return;
	} 
	[super draw];
	
	glPushMatrix();
	glBindTexture(GL_TEXTURE_2D, main_fill.texture.name);
	glVertexPointer(2, GL_FLOAT, 0, main_fill.tri_pts); //coord per vertex, type, stride, pointer to array
	glTexCoordPointer(2, GL_FLOAT, 0, main_fill.tex_pts);
	glDrawArrays(GL_TRIANGLES, 0, 3); //drawtype,offset,pts
	glDrawArrays(GL_TRIANGLES, 1, 3);
	glPopMatrix();
	
	glPushMatrix();
    glBindTexture(GL_TEXTURE_2D, top_fill.texture.name);
    glVertexPointer(2,GL_FLOAT,0,top_fill.tri_pts);
    glTexCoordPointer(2,GL_FLOAT,0,top_fill.tex_pts);
    glDrawArrays(GL_TRIANGLES, 0, 3);
    glDrawArrays(GL_TRIANGLES, 1, 3);
    glPopMatrix();
	
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
	slope = (endY - startY)/(endX - startX);
	rot = atan((endY-startY)/(endX-startX))*(180/M_PI);
}

-(float)get_height:(float)pos {
	if (pos < min_range || pos > max_range) {
		return -1;
	} else {
		return startY+(pos-startX)*slope;
	}
}

-(float)get_angle:(float)pos {
    return atan((endY-startY)/(endX-startX))*(180/M_PI);
}

@end
